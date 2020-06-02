class Piece {
  int position;
  double safetyProbability = 0;

  Piece(int pos) {
    this.position = pos;
    this.safetyProbability = 1;
  }

  setPosition(int position) => this.position = position;

  int getCurrentPosition() => this.position;

  bool isSafe(int pos) {
    if (pos == -1 ||
        pos == 0 ||
        pos == 8 ||
        pos == 13 ||
        pos == 21 ||
        pos == 26 ||
        pos == 34 ||
        pos == 39 ||
        pos == 47 ||
        pos > 50) return true;
    return false;
  }
}
