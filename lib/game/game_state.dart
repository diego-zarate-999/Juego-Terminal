class GameState {
  int _remainingAttempts;
  final int _secretNumber;

  GameState(this._remainingAttempts, this._secretNumber);

  int get remainingAttemps => _remainingAttempts;
  int get secretNumber => _secretNumber;

  set remainingAttempts(value) => _remainingAttempts = value;
}
