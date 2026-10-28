import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  Profile(this.name, this.delayMs, this.left);

  final String name;
  final double delayMs;
  final bool left;

  Map<String, dynamic> toJson() => {'name': name, 'ms': delayMs, 'left': left};

  factory Profile.fromJson(Map<String, dynamic> j) =>
      Profile(j['name'] as String, (j['ms'] as num).toDouble(), j['left'] as bool);
}

enum AutoPhase { idle, countdown, running, done }

/// Estado y lógica de la app; habla con Android por el canal `caralign`.
class AlignController extends ChangeNotifier {
  static const _channel = MethodChannel('caralign');
  static const maxMs = 10.0;
  static const cmPerMs = 34.3; // velocidad del sonido ~343 m/s

  /// Aviso breve para la interfaz (SnackBar).
  void Function(String)? onNotice;

  double delayMs = 1.0;
  bool left = true;
  bool hasDelay = false; // hay un retraso guardado o ajustado alguna vez
  bool active = false;
  bool hideGuide = false;
  List<Profile> profiles = [];
  Timer? _poll;
  bool _disposed = false;

  // vigilante y permisos
  bool guard = false;
  String guardState = 'idle', guardDetail = '';
  bool mic = true;

  // demostracion 0 -> perfil
  bool demoRunning = false;
  String demoLabel = '';
  double demoShown = 0;
  double demoSeconds = 12;
  double demoSteps = 6;
  int demoProfile = 0;

  // alineacion automatica
  AutoPhase auto = AutoPhase.idle;
  int countdown = 0;
  String phase = '';
  double frac = 0;
  Map<String, dynamic>? result;

  AlignController() {
    _load();
    _channel.invokeMethod('perms');
    _poll = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('profiles') ?? [];
    profiles = raw.map((s) => Profile.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
    hasDelay = prefs.containsKey('delayMs');
    delayMs = prefs.getDouble('delayMs') ?? delayMs;
    left = prefs.getBool('left') ?? left;
    hideGuide = prefs.getBool('hideGuide') ?? false;
    _notify();
    refreshActive();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('delayMs', delayMs);
    await prefs.setBool('left', left);
    await prefs.setStringList('profiles', profiles.map((p) => jsonEncode(p.toJson())).toList());
  }

  Future<void> setHideGuide(bool v) async {
    hideGuide = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hideGuide', v);
    _notify();
  }

  /// Sondeo de 1 s: estado de la captura, del vigilante y del permiso de micrófono.
  Future<void> refresh() async {
    await refreshActive();
    await refreshGuard();
    try {
      final n = await _channel.invokeMethod<String>('captureNotice') ?? '';
      if (n.isNotEmpty) onNotice?.call(n);
    } catch (_) {}
    try {
      final m = await _channel.invokeMethod<bool>('hasMic') ?? true;
      if (m != mic) {
        mic = m;
        _notify();
      }
    } catch (_) {}
  }

  Future<void> requestPerms() => _channel.invokeMethod('perms');

  Future<void> guardEnsure() => _channel.invokeMethod('guardEnsure');

  Future<void> refreshActive() async {
    final a = await _channel.invokeMethod<bool>('active') ?? false;
    if (a != active) {
      active = a;
      _notify();
    }
  }

  Future<void> refreshGuard() async {
    final g = await _channel.invokeMethod<Map<dynamic, dynamic>>('guardInfo') ?? {};
    final alive = g['alive'] == true;
    final st = g['state'] as String? ?? 'idle';
    final det = g['detail'] as String? ?? '';
    if (alive != guard || st != guardState || det != guardDetail) {
      guard = alive;
      guardState = st;
      guardDetail = det;
      _notify();
    }
  }

  Future<void> _sleep(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

  // ---- demostracion ----

  /// Espera `hold` ms salvo que se detenga la demostracion.
  Future<void> _holdAt(double ms, String label, int hold) async {
    demoShown = ms;
    demoLabel = label;
    _notify();
    for (var t = 0; t < hold && demoRunning; t += 100) {
      await _sleep(100);
    }
  }

  /// Escalones hacia `target` ms: en cada uno el retraso cambia con un deslizamiento corto (sin chasquido) y se
  /// queda quieto para que el cambio se note. La duracion total se reparte entre los pasos.
  Future<void> _rampTo(double target, Profile p, String label) async {
    final from = demoShown;
    final span = p.delayMs <= 0 ? 1.0 : (target - from).abs() / p.delayMs;
    final secs = (demoSeconds * span).clamp(0.5, 120.0);
    final n = demoSteps.round().clamp(2, 20);
    final holdMs = (secs * 1000 / n).round();
    for (var k = 1; k <= n && demoRunning; k++) {
      final v = from + (target - from) * k / n;
      demoShown = v;
      demoLabel = '$label  (paso $k de $n)';
      _notify();
      await _channel.invokeMethod('set', {'delayMs': v, 'left': p.left, 'seconds': 0.15});
      for (var t = 0; t < holdMs && demoRunning; t += 100) {
        await _sleep(100);
      }
    }
  }

  void stopDemo() {
    demoRunning = false;
    _notify();
  }

  void setDemoProfile(int i) {
    demoProfile = i;
    _notify();
  }

  void setDemoSeconds(double v) {
    demoSeconds = v;
    _notify();
  }

  void setDemoSteps(double v) {
    demoSteps = v;
    _notify();
  }

  /// Muestra el efecto: 0 ms -> perfil (y de vuelta si `loop`), con la musica sonando.
  Future<void> demo({required bool loop}) async {
    if (profiles.isEmpty || demoRunning) return;
    if (!guard) {
      onNotice?.call('Sin el vigilante no se puede silenciar el original; ábrelo de nuevo o usa el cable.');
      return;
    }
    final p = profiles[demoProfile.clamp(0, profiles.length - 1)];
    demoRunning = true;
    demoLabel = 'Preparando';
    demoShown = 0;
    _notify();
    await _channel.invokeMethod('keepScreenOn', true);
    try {
      if (!active) {
        await _channel.invokeMethod('start', {'delayMs': 0.0, 'left': p.left});
        await _sleep(4000); // el vigilante tarda ~1 s en silenciar el original
        refreshActive();
      } else {
        await _channel.invokeMethod('set', {'delayMs': 0.0, 'left': p.left, 'seconds': 0.5});
        await _sleep(1500);
      }
      do {
        await _holdAt(0, 'Sin alineación', 3500);
        if (!demoRunning) break;
        await _rampTo(p.delayMs, p, 'Centrando');
        if (!demoRunning) break;
        await _holdAt(p.delayMs, 'Alineado', 4000);
        if (loop && demoRunning) await _rampTo(0, p, 'Quitando');
      } while (loop && demoRunning);
    } finally {
      // si se detuvo a media rampa, congelar donde esta
      if (active) {
        await _channel.invokeMethod('set', {'delayMs': demoShown, 'left': p.left});
      }
      await _channel.invokeMethod('keepScreenOn', false);
      demoRunning = false;
      delayMs = (demoShown * 50).round() / 50;
      left = p.left;
      hasDelay = true;
      _notify();
      _saveState();
    }
  }

  // ---- alineacion automatica ----

  Future<void> _earcon(int type) => _channel.invokeMethod('earcon', type);

  /// Cuenta atras con avisos sonoros, medicion automatica y aplicacion del resultado.
  /// La guia de colocacion se muestra antes, desde la interfaz.
  Future<void> autoAlign() async {
    if (auto == AutoPhase.countdown || auto == AutoPhase.running) return;
    await _channel.invokeMethod('keepScreenOn', true);
    auto = AutoPhase.countdown;
    result = null;
    countdown = 10;
    _notify();
    while (countdown > 0 && !_disposed) {
      await Future<void>.delayed(const Duration(seconds: 1));
      countdown--;
      _notify();
      if (countdown > 0 && countdown <= 3) _earcon(0);
    }
    if (_disposed) return;
    _earcon(1);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    auto = AutoPhase.running;
    phase = 'Preparando';
    frac = 0;
    _notify();
    final started = await _channel.invokeMethod<bool>('autoStart') ?? false;
    if (!started) {
      auto = AutoPhase.idle;
      _notify();
      await _channel.invokeMethod('keepScreenOn', false);
      return;
    }
    Map<dynamic, dynamic> st;
    do {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      st = await _channel.invokeMethod<Map<dynamic, dynamic>>('autoStatus') ?? {};
      if (_disposed) return;
      phase = st['phase'] as String? ?? '';
      frac = (st['frac'] as num?)?.toDouble() ?? 0;
      _notify();
    } while (st['done'] != true);
    await _channel.invokeMethod('keepScreenOn', false);
    final res = jsonDecode(st['result'] as String) as Map<String, dynamic>;
    final apply = res['apply'] == true;
    _earcon(apply ? 2 : 3);
    if (!apply && res['wasPlaying'] == true) {
      await Future<void>.delayed(const Duration(milliseconds: 1200)); // dejar sonar el aviso
      await _channel.invokeMethod('mediaPlay'); // la medicion pauso la musica; devolverla
    }
    auto = AutoPhase.done;
    result = res;
    _notify();
    if (apply) {
      final l = (res['delayLeftMs'] as num) > 0;
      final ms = ((l ? res['delayLeftMs'] : res['delayRightMs']) as num).toDouble();
      left = l;
      delayMs = (ms * 50).round() / 50;
      hasDelay = true;
      final now = DateTime.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      profiles.add(Profile('Auto $hh:$mm', delayMs, left));
      _notify();
      _saveState();
      if (guard) {
        await _channel.invokeMethod('start', _args);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        refreshActive();
        if (res['wasPlaying'] == true) {
          // el vigilante tarda ~1 s en silenciar el original: reanudar despues para no oir doble
          await Future<void>.delayed(const Duration(milliseconds: 2500));
          await _channel.invokeMethod('mediaPlay');
        }
      }
    }
  }

  // ---- ajuste manual, captura y perfiles ----

  Map<String, dynamic> get _args => {'delayMs': delayMs, 'left': left};

  void _apply() {
    hasDelay = true;
    _saveState();
    if (active) _channel.invokeMethod('set', _args);
    _notify();
  }

  void setDelay(double ms) {
    delayMs = ((ms.clamp(0, maxMs)) * 50).round() / 50;
    _apply();
  }

  void setLeft(bool v) {
    left = v;
    _apply();
  }

  Future<void> toggle() async {
    if (active) {
      await _channel.invokeMethod('stop');
    } else {
      await _channel.invokeMethod('start', _args);
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    refreshActive();
  }

  void addProfile(String name) {
    profiles.add(Profile(name, delayMs, left));
    _notify();
    _saveState();
  }

  void removeProfile(Profile p) {
    profiles.remove(p);
    _notify();
    _saveState();
  }

  void loadProfile(Profile p) {
    delayMs = p.delayMs;
    left = p.left;
    _apply();
  }
}
