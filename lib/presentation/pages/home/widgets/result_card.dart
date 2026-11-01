import 'package:flutter/material.dart';

import '../../../../core/formatting.dart';
import '../../../../domain/entities/alignment_result.dart';
import '../../../../domain/entities/channel_side.dart';
import '../../../../i18n/strings.g.dart';
import '../../../localization/domain_l10n.dart';

/// Result in plain language; technical data is folded under "Details".
class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.result});

  final AlignmentResult result;

  String _bandsLine(Map<Band, double?> deltas) {
    String f(Band b) => deltas[b] == null ? '—' : formatTrimmed(deltas[b]!, digits: 3);
    return t.home.result.bandsLine(low: f(Band.low), mid: f(Band.mid), high: f(Band.high));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final r = result;
    final (color, icon) = switch (r.status) {
      ResultStatus.ok => (colors.primary, Icons.check_circle),
      ResultStatus.warn => (const Color(0xFFB26A00), Icons.warning_rounded),
      ResultStatus.fail => (colors.error, Icons.error),
    };
    final delay = r.delay;
    final headline = delay == null
        ? t.home.result.nothingApplied
        : delay.side == ChannelSide.left
            ? t.home.result.delayLeft(ms: formatMs(delay.milliseconds))
            : t.home.result.delayRight(ms: formatMs(delay.milliseconds));
    final sourceLine = r.source.measuredLine;
    final messages = [for (final m in r.messages) m.localized];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 10),
          Expanded(child: Text(headline, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 4),
        if (sourceLine.isNotEmpty) Text(sourceLine, style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
        if (!r.apply || r.status != ResultStatus.ok)
          for (final m in messages)
            Padding(padding: const EdgeInsets.only(top: 6), child: Text('• $m', style: text.bodyLarge)),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(t.home.result.details),
            children: [
              if (r.apply)
                _DetailLine(t.home.result.verified(
                  residual: r.residualUs.toStringAsFixed(0),
                  sigma: r.sigmaUs.toStringAsFixed(0),
                  valid: r.validRepetitions,
                  reps: r.repetitions,
                  band: r.band?.label ?? '?',
                )),
              if (r.status == ResultStatus.ok)
                for (final m in messages) _DetailLine('• $m'),
              if (r.bandDeltasMs != null) _DetailLine(_bandsLine(r.bandDeltasMs!)),
              _DetailLine(r.source.raw.isEmpty
                  ? t.home.result.output(name: r.source.name)
                  : t.home.result.outputRaw(name: r.source.name, raw: r.source.raw)),
              _DetailLine(t.home.result.microphone(name: r.inputDevice)),
              _DetailLine(t.home.result.noise(db: r.noiseDbfs.toStringAsFixed(0))),
            ],
          ),
        ),
      ]),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}
