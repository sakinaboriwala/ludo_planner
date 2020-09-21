import 'dart:math';

import 'playerClass.dart';
import 'gameOperation.dart';

class GameConfiguration {
  List<PlayerClass> players;
  int noOnDice;

  GameConfiguration({this.players, this.noOnDice});

  void printPlayersPosition() {
    print("No. On Dice : ${this.noOnDice}");
    for (int i = 0; i < this.players.length; i++) {
      print(
          "player $i Piece 0: ${players[i].pieces[0].position} Piece 1 : ${players[i].pieces[1].position} "
          "Piece 2:  ${players[i].pieces[2].position} Piece 3 : ${players[i].pieces[3].position}");
    }
  }

  int autoMovePieceNo() {
    print("Automove : ");
    if (players[0].pieces[0].position >= 0 &&
        players[0].pieces[0].position + noOnDice <= 56)
      return 0;
    else if (players[0].pieces[1].position >= 0 &&
        players[0].pieces[1].position + noOnDice <= 56)
      return 1;
    else if (players[0].pieces[2].position >= 0 &&
        players[0].pieces[2].position + noOnDice <= 56)
      return 2;
    else if (players[0].pieces[3].position >= 0 &&
        players[0].pieces[3].position + noOnDice <= 56)
      return 3;
    else
      return -1;
  }

  int pieceNoForAnyPieceWithinInitialBox() {
    if (players[0].pieces[0].position == -1)
      return 0;
    else if (players[0].pieces[1].position == -1)
      return 1;
    else if (players[0].pieces[2].position == -1)
      return 2;
    else if (players[0].pieces[3].position == -1) return 3;
    return -1;
  }

  int returnOnlyOneActivePieceCanMove(int forPlayer) {
    int index = -1;
    for (int pieceNo = 0; pieceNo < 4; pieceNo++) {
      int pos = players[forPlayer].pieces[pieceNo].position;
      if (pos != -1 && pos + noOnDice <= 56) {
        index = pieceNo;
        break;
      }
    }
    return index;
  }

  bool canOnlyOneActivePieceMove(int forPlayer) {
    int count = 0;
    for (int pieceNo = 0; pieceNo < 4; pieceNo++) {
      if ((players[forPlayer].pieces[pieceNo].position == -1 &&
              noOnDice != 6) ||
          (players[forPlayer].pieces[pieceNo].position + noOnDice > 56))
        continue;
      else
        count = count + 1;
    }
    if (count == 1) return true;
    return false;
  }

  int returnIndexWithHighestProb(List<double> list) {
    double max = -999;
    int index = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i] >= max) {
        max = list[i];
        index = i;
      }
    }
    return index;
  }

  bool canCutAnyBody(List<double> list) {
    for (int i = 0; i < 4; i++) {
      if (list[i] != 0) return true;
    }
    return false;
  }

  int pieceNoToMove() {
    int pieceNo = -1;

    int inHomeNo = players[0].noOfPiecesInHome;
    int inBoxNo = players[0].noOfPiecesInInitialBox;

    // If  all the Pieces are in Initial box and Home.number on dice is not six
    if (((inHomeNo + inBoxNo) == 4 && noOnDice != 6)) return -1;

    //No piece is in active field .All pieces are either in Initial Box Or in Home.Number on dice is 6
    if ((4 - inHomeNo) == inBoxNo && noOnDice == 6)
      return pieceNoForAnyPieceWithinInitialBox();

    //Only One Piece is in Active field & Number on dice is not Six
    if ((4 - inHomeNo - inBoxNo == 1) && noOnDice != 6)
      return autoMovePieceNo();

    //Only one of the several Active Pieces can move
    if (canOnlyOneActivePieceMove(0)) return returnOnlyOneActivePieceCanMove(0);

    GameOperations gameOperationsObj = GameOperations(players, noOnDice);

    //can Cut AnyBody
    List<double> canCutList = gameOperationsObj
        .returnKillingProbabilityWeightedList(0, hasNoOnDice: true);
    if (canCutAnyBody(canCutList)) {
      print("From can cut anybody");
      print("Weighed killProb");
      print(canCutList);
      return returnIndexWithHighestProb(canCutList);
    }

    //can open any piece if cannot cut
    if (noOnDice == 6 && pieceNoForAnyPieceWithinInitialBox() != -1) {
      return pieceNoForAnyPieceWithinInitialBox();
    }

    // TODO: if all the opponents goti are in the home or home grid then move the goti which is the farthest.


    List<double> values = gameOperationsObj.returnValueListOfBoardOnOneMove(0);
    print(values);

    pieceNo = returnIndexWithHighestProb(values);
    int count = 0;
    //For avoiding returning  pieces already in home or when currentPos + noOnDIce>56 and cannot move  or piece not opened and noOnDice!=6
    while ((players[0].pieces[pieceNo].position >= 56 ||
            players[0].pieces[pieceNo].position + noOnDice > 56 ||
            (players[0].pieces[pieceNo].position == -1 && noOnDice != 6)) &&
        count < 4) {
      values[pieceNo] = -999;
      pieceNo = returnIndexWithHighestProb(values);
      count++;
    }
    print("Borad Improve Probility After removing piece cannot move");
    print(values);
    return pieceNo;
  }
}
