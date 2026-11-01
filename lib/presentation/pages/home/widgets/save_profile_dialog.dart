import 'package:flutter/material.dart';

import '../../../../i18n/strings.g.dart';

/// Asks for a profile name; resolves to the trimmed name, or null when cancelled.
Future<String?> showSaveProfileDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(t.home.profiles.dialogTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: t.home.profiles.dialogHint),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog), child: Text(t.common.cancel)),
        FilledButton(onPressed: () => Navigator.pop(dialog, controller.text.trim()), child: Text(t.common.save)),
      ],
    ),
  );
}
