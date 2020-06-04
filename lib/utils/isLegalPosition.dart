bool isLegal(row, col, moveItem) {
  if ((row == 7 && col == 7) ||
      (row == 8 && col == 8) ||
      (row == 6 && col == 8) ||
      (row == 6 && col == 6) ||
      (row == 8 && col == 6)) {
    return false;
  }

  // for player at bottom left
  if (moveItem == 0 || moveItem == 10 || moveItem == 20 || moveItem == 30) {
    if (row == 7 && col <= 6 && col >= 1) {
      return false;
    }
    if (col == 7 && row <= 13 && row >= 8) {
      return false;
    }
    if (row == 7 && col <= 13 && col >= 8) {
      return false;
    }
  }

  // for player at top left
  if (moveItem == 1 || moveItem == 11 || moveItem == 21 || moveItem == 31) {
    if (col == 7 && row <= 13 && row >= 8) {
      return false;
    }
    if (row == 7 && col <= 13 && col >= 8) {
      return false;
    }
    if (col == 7 && row <= 6 && row >= 1) {
      return false;
    }
  }

  // for player at top right
  if (moveItem == 2 || moveItem == 12 || moveItem == 22 || moveItem == 32) {
    if (row == 7 && col <= 6 && col >= 1) {
      return false;
    }
    if (row == 7 && col <= 13 && col >= 8) {
      return false;
    }
    if (col == 7 && row <= 6 && row >= 1) {
      return false;
    }
  }

  // for player at top right
  if (moveItem == 3 || moveItem == 13 || moveItem == 23 || moveItem == 33) {
    if (row == 7 && col <= 6 && col >= 1) {
      return false;
    }
    if (col == 7 && row <= 13 && row >= 8) {
      return false;
    }
    if (col == 7 && row <= 6 && row >= 1) {
      return false;
    }
  }
  return true;
}
