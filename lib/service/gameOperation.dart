import 'playerClass.dart';

class GameOperations {
  List<PlayerClass> players;
  int noOnDice;
  Map<int, int> currPieceKillPiecePosMap = new Map<int, int>();

  GameOperations(this.players, this.noOnDice);

  int piecePositionDifferenceForDying(int PIx, int PIy, int x, int y) {
    //if withPlayer Piece Position  is in Initial Box
    if (y == -1) y = -6;
    int z = (PIy - PIx) * 13 + y;
    int posDiff = x - z;

    if (PIy > PIx && x < z) posDiff = posDiff + 52;
    return posDiff;
  }

  double singlePieceDyingProbability(
      int currentChancePlayerNo,
      int currentChancePlayerPieceNo,
      int currPlayerPiecePos,
      int withPlayerNo,
      int withPlayerPieceNo,
      int withPlayerPiecePos,
      {bool hasNoOnDice = false}) {
    int noOnDice = 0;
//     print("Current Chance PlayerNo : $currentChancePlayerNo  Current PlayerPieceNo : $currentChancePlayerPieceNo  CurrPlayerPiecePos : ${currPlayerPiecePos+noOnDice} withPlayerNo : $withPlayerNo  witPlayerPieceNo : $withPlayerPieceNo  withPlayerPiecePos $withPlayerPiecePos");
    if (hasNoOnDice) noOnDice = this.noOnDice;
    //Piece number 0 doesn't have any significance as player position is passed in isSafe function. piece[0] is just used to call isSafe function;

    if ((currPlayerPiecePos == -1) ||
        players[currentChancePlayerNo]
            .pieces[0]
            .isSafe(currPlayerPiecePos + noOnDice) ||
        withPlayerPiecePos > 50)
      return 0.0;
    else {
      int playerNoDiff = currentChancePlayerNo - withPlayerNo;
      //Dying From Piece In Home Way  dying from itself
      if (withPlayerPiecePos > 50 || playerNoDiff == 0) return 0.0;

      if (!hasNoOnDice && withPlayerPiecePos == -1) withPlayerPiecePos = 0;

      int posDiff = piecePositionDifferenceForDying(currentChancePlayerNo,
          withPlayerNo, currPlayerPiecePos + noOnDice, withPlayerPiecePos);
//        print("Player no Diff :  $playerNoDiff  Piece Diff $posDiff");

      if (posDiff > 0 && posDiff <= 6)
        return 1 / 6;
      else if (posDiff > 6 && posDiff <= 12)
        return 1 / 36;
      else if (posDiff > 12 && posDiff <= 17)
        return 1 / 216;
      else
        return 0;
    }
  }

  double calculateDyingProbability(int currentChancePlayerNo,
      int currentChancePlayerPieceNo, int currPlayerPiecePos, int withPlayerNo,
      {bool hasNoOnDice = false}) {
    double probability = 0.0;
    Map<int, int> mapForProbDyingCorrection = {};
//Avoiding dying probability of current Piece with More than One Piece of same player at same position
    for (int withPlayerPieceNo = 0;
        withPlayerPieceNo < 4;
        withPlayerPieceNo++) {
      mapForProbDyingCorrection[
          players[withPlayerNo].pieces[withPlayerPieceNo].position] = 1;
    }

    for (int withPlayerPieceNo = 0;
        withPlayerPieceNo < 4;
        withPlayerPieceNo++) {
      if (mapForProbDyingCorrection.containsKey(
          players[withPlayerNo].pieces[withPlayerPieceNo].position)) {
        mapForProbDyingCorrection
            .remove(players[withPlayerNo].pieces[withPlayerPieceNo].position);
        probability = probability +
            singlePieceDyingProbability(
                currentChancePlayerNo,
                currentChancePlayerPieceNo,
                currPlayerPiecePos,
                withPlayerNo,
                withPlayerPieceNo,
                players[withPlayerNo].pieces[withPlayerPieceNo].position,
                hasNoOnDice: hasNoOnDice);
      }
    }
    return probability;
  }

  List<double> returnDyingProbabilityList(int currentChancePlayerNo,
      {bool hasNoOnDice = false}) {
    List<double> dyingProbability = new List<double>(4);
    dyingProbability[0] = 0.0;
    dyingProbability[1] = 0.0;
    dyingProbability[2] = 0.0;
    dyingProbability[3] = 0.0;

    double dyingProb = 0.0;

    for (int playerNo = 0; playerNo < players.length; playerNo++) {
      //Ingnoring Players Not in Game or dying with itself in dying Probability Calculation
      if (players[playerNo].playerNotInGame ||
          playerNo == currentChancePlayerNo)
        continue;
      else {
        for (int currPlayerPieceNo = 0;
            currPlayerPieceNo < 4;
            currPlayerPieceNo++) {
          dyingProbability[currPlayerPieceNo] =
              dyingProbability[currPlayerPieceNo] +
                  calculateDyingProbability(
                      currentChancePlayerNo,
                      currPlayerPieceNo,
                      players[currentChancePlayerNo]
                          .pieces[currPlayerPieceNo]
                          .position,
                      playerNo,
                      hasNoOnDice: hasNoOnDice);
        }
      }
    }
    return dyingProbability;
  }


  double isSafeProbability(int playerNo, int pieceNo,
      {bool hasNoOnDice = false}) {
    int pos = players[playerNo].pieces[pieceNo].position;
    if (hasNoOnDice) {
      if (pos == -1)
        return 1;
      else if (players[playerNo].pieces[pieceNo].isSafe(pos + noOnDice))
        return 1;
      else
        return 0;
    }

    return players[playerNo].pieces[pieceNo].isSafe(pos) ? 1.0 : 0.0;
  }

  List<double> returnIsSafeProbabilityList(int playerNo,
      {bool hasNoOnDice = false}) {
    List<double> isSafeProbList = new List<double>(4);
    for (int currPlayerPieceNo = 0; currPlayerPieceNo < 4; currPlayerPieceNo++)
      isSafeProbList[currPlayerPieceNo] = isSafeProbability(
          playerNo, currPlayerPieceNo,
          hasNoOnDice: hasNoOnDice);
    print("Is safe prob List");
    print(isSafeProbList);
    return isSafeProbList;
  }

  List<double> returnIsSafeWeighedProbabilityList(int currentChancePlayerNo,
      {bool hasNoOnDice = false}) {
    List<double> isSafeProbList = returnIsSafeProbabilityList(
        currentChancePlayerNo,
        hasNoOnDice: hasNoOnDice);
    for (int pieceNo = 0; pieceNo < 4; pieceNo++) {
      if (isSafeProbList[pieceNo] == 1.0) {
//          if(players[playerNo].pieces[pieceNo].position==-1)
//            {
//              isSafeProbList[pieceNo]=0;
//            }
//          else
        {
          isSafeProbList[pieceNo] = isSafeProbList[pieceNo] *
              players[currentChancePlayerNo].pieces[pieceNo].position /
              56;
        }
      }
    }
    return isSafeProbList;
  }

  double distanceCoveredProbability(int pos, {bool hasNoOnDice = false}) {
    if (pos >= 56)
      return 1;
    else if (hasNoOnDice && pos == -1 && noOnDice == 6)
      return 0;
    else if (!hasNoOnDice && pos == -1)
      return pos.toDouble() / 56;
    else if (hasNoOnDice)
      return (pos + noOnDice).toDouble() / 56;
    else
      return pos.toDouble() / 56;
  }

  List<double> returnDistanceCoveredProbabilityList(int currentPlayerNo,
      {bool hasNoOnDice = false}) {
    List<double> distProbList = new List<double>(4);
    for (int currPlayerPieceNo = 0; currPlayerPieceNo < 4; currPlayerPieceNo++)
      distProbList[currPlayerPieceNo] = distanceCoveredProbability(
          players[currentPlayerNo].pieces[currPlayerPieceNo].position);
    return distProbList;
  }

  int piecePositionDifferenceForKilling(int PIx, int PIy, int x, int y) {
    int z = (PIy - PIx) * 13 + y;
    int posDiff = (x - z);

    if (posDiff <= -52) posDiff = 52 + posDiff;
    posDiff = -posDiff;
    return posDiff;
  }

  double singlePieceKillingProbability(int currentChancePlayerNo,
      int currentChancePlayerPieceNo, int withPlayerNo, int withPlayerPieceNo,
      {bool hasNumberOnDice = false}) {
    //if withPlayer's Piece is Safe
    if (players[withPlayerNo].pieces[withPlayerPieceNo].isSafe(
        players[withPlayerNo].pieces[withPlayerPieceNo].getCurrentPosition()))
      return 0.0;

    int noOnDice = hasNumberOnDice ? this.noOnDice : 0;

    int currPlayerPos = players[currentChancePlayerNo]
        .pieces[currentChancePlayerPieceNo]
        .position;
    int withPlayerPos =
        players[withPlayerNo].pieces[withPlayerPieceNo].position;

    if (withPlayerNo - currentChancePlayerNo == 0 || currPlayerPos > 50)
      return 0.0;
//    print(
//        "Current Chance PlayerNo : $currentChancePlayerNo  Current PlayerPieceNo : $currentChancePlayerPieceNo  CurrPlayerPiecePos : $currPlayerPos withPlayerNo : $withPlayerNo  witPlayerPieceNo : $withPlayerPieceNo  withPlayerPiecePos $withPlayerPos");

    //If current player is in initial box then he need to first open dice to kill
    if (currPlayerPos == -1) return 0;

    int posDiff = piecePositionDifferenceForKilling(currentChancePlayerNo,
        withPlayerNo, currPlayerPos + noOnDice, withPlayerPos);

//    print("Player no Diff :  Piece Diff $posDiff");

    if (hasNumberOnDice) {
      if (posDiff == 0) {
        this.currPieceKillPiecePosMap[currentChancePlayerPieceNo] =
            withPlayerPos;
        return 1;
      } else
        return 0;
    }
    if (posDiff == 0) {
      this.currPieceKillPiecePosMap[currentChancePlayerPieceNo] = withPlayerPos;
      return 1;
    } else
      return 0.0;
  }

  //Calculates killing probability currentChance player's current piece with all the pieces of withPlayer
  double calculateKillingProbability(int currentChancePlayerNo,
      int currentChancePlayerPieceNo, int currPlayerPiecePos, int withPlayerNo,
      {bool hasNoOnDice = false}) {
    double probability = 0.0;

    for (int withPlayerPieceNo = 0;
        withPlayerPieceNo < 4;
        withPlayerPieceNo++) {
      probability = probability +
          singlePieceKillingProbability(currentChancePlayerNo,
              currentChancePlayerPieceNo, withPlayerNo, withPlayerPieceNo,
              hasNumberOnDice: hasNoOnDice);
    }

    return probability;
  }

  List<double> returnKillingProbabilityList(int currentChancePlayerNo,
      {bool hasNoOnDice = false}) {
    List<double> killingProbability = new List<double>(4);
    killingProbability[0] = 0.0;
    killingProbability[1] = 0.0;
    killingProbability[2] = 0.0;
    killingProbability[3] = 0.0;

    for (int withPlayerNo = 0; withPlayerNo < players.length; withPlayerNo++) {
      //Ingnoring Players Not in Game or killing with itself in killing Probability Calculation
      if (players[withPlayerNo].playerNotInGame ||
          withPlayerNo == currentChancePlayerNo)
        continue;
      else {
        for (int currentPlayerPieceNo = 0;
            currentPlayerPieceNo < 4;
            currentPlayerPieceNo++) {
          killingProbability[currentPlayerPieceNo] =
              killingProbability[currentPlayerPieceNo] +
                  calculateKillingProbability(
                      currentChancePlayerNo,
                      currentPlayerPieceNo,
                      players[currentChancePlayerNo]
                          .pieces[currentPlayerPieceNo]
                          .position,
                      withPlayerNo,
                      hasNoOnDice: hasNoOnDice);
        }
      }
    }
    return killingProbability;
  }

  List<double> returnDyingProbabilityWeightedList(int currentChancePlayerNo,
      {bool hasNoOnDice = false}) {
    List<double> dyingProbList = returnDyingProbabilityList(
        currentChancePlayerNo,
        hasNoOnDice: hasNoOnDice);

    int noOnDice = hasNoOnDice ? this.noOnDice : 0;

    print("Dying Probability");
    print(dyingProbList);

    for (int pieceNo = 0; pieceNo < 4; pieceNo++) {
      dyingProbList[pieceNo] = dyingProbList[pieceNo] *
          ((players[currentChancePlayerNo].pieces[pieceNo].position +
                  noOnDice) /
              56);
    }
    return dyingProbList;
  }

  List<double> returnKillingProbabilityWeightedList(int currentChancePlayerNo,
      {bool hasNoOnDice = false}) {
    List<double> killingProbList = returnKillingProbabilityList(
        currentChancePlayerNo,
        hasNoOnDice: hasNoOnDice);

    print("killing Probability");
    print(killingProbList);
    if (this.currPieceKillPiecePosMap.isNotEmpty) {
      currPieceKillPiecePosMap.forEach((currPlayerPieceNo, withPlayerPiecePos) {
        killingProbList[currPlayerPieceNo] =
            killingProbList[currPlayerPieceNo] * (withPlayerPiecePos / 56)*3;
      });
    }

    return killingProbList;
  }

  List<double> returnValueOfPiece(int currentChancePlayerNo,
      {bool hasNoOnDice = false}) {
    //A Seperate function to weight dying probability and killing probability is implemented and called here
    List<double> valueOfPieces = [0.0, 0.0, 0.0, 0.0];
    List<double> dyingProbList = returnDyingProbabilityWeightedList(
        currentChancePlayerNo,
        hasNoOnDice: hasNoOnDice);
    List<double> killingProbabilityList = returnKillingProbabilityWeightedList(
        currentChancePlayerNo,
        hasNoOnDice: hasNoOnDice);

    List<double> isSafeProbList = returnIsSafeWeighedProbabilityList(
        currentChancePlayerNo,
        hasNoOnDice: hasNoOnDice);

    for (int i = 0; i < 4; i++) {
      valueOfPieces[i] =
          killingProbabilityList[i] - dyingProbList[i] + isSafeProbList[i];

    }

    print("Dying Probability Weighted ");
    print(dyingProbList);
    print("Killing Probability Weighted ");
    print(killingProbabilityList);
    print("IsSafe robability Weighed");
    print(isSafeProbList);
    print("Piece Values");
    print(valueOfPieces);
    return valueOfPieces;
  }

  List<double> returnValueListOfBoardOnOneMove(int currentChancePlayerNo) {
    List<double> moveWithDiceNoValueList =
        returnValueOfPiece(currentChancePlayerNo, hasNoOnDice: true);
    print("##################Without Dice No###################");
    List<double> withoutDiceNoValueList =
        returnValueOfPiece(currentChancePlayerNo, hasNoOnDice: false);
    List<double> boardImproveValueList = [0.0, 0.0, 0.0, 0.0];

    for (int i = 0; i < 4; i++) {
      if (players[currentChancePlayerNo].pieces[i].position >= 56) {
        withoutDiceNoValueList[i] = 0;
      }
    }
    for (int pieceMoved = 0; pieceMoved < 4; pieceMoved++) {
      for (int otherPiece = 0; otherPiece < 4; otherPiece++) {
        if (pieceMoved != otherPiece) {
          boardImproveValueList[pieceMoved] =
              boardImproveValueList[pieceMoved] +
                  withoutDiceNoValueList[otherPiece] / 4;
        }
      }
      boardImproveValueList[pieceMoved] = boardImproveValueList[pieceMoved] +
          moveWithDiceNoValueList[pieceMoved] / 4;
    }
    print("Board Improve probability");
//print(boardImproveValueList);
    return boardImproveValueList;
  }
}
