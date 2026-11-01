enum GuardState { idle, auth, shizuku, starting, alive, error }

/// Machine-readable reason attached to a guard error.
enum GuardDetailCode { adbInactiveNoShizuku, adbFailedNoShizuku, shizukuFailed, notStarted }

class GuardDetail {
  const GuardDetail(this.code, [this.argument = '']);

  final GuardDetailCode code;
  final String argument;

  @override
  bool operator ==(Object other) => other is GuardDetail && other.code == code && other.argument == argument;

  @override
  int get hashCode => Object.hash(code, argument);
}

/// State of the shell-privileged guard process that mutes the original app.
class GuardStatus {
  const GuardStatus({this.alive = false, this.state = GuardState.idle, this.detail});

  final bool alive;
  final GuardState state;
  final GuardDetail? detail;

  /// True while the guard is being set up and the user may have to accept a prompt.
  bool get isConnecting =>
      !alive && (state == GuardState.auth || state == GuardState.starting || state == GuardState.shizuku);

  @override
  bool operator ==(Object other) =>
      other is GuardStatus && other.alive == alive && other.state == state && other.detail == detail;

  @override
  int get hashCode => Object.hash(alive, state, detail);
}
