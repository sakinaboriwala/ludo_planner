import 'dart:core';
import 'gameSuggestion.dart';
import 'playerClass.dart';



List<PlayerClass> setHomeAndInitVariables(List<PlayerClass> players) {
  for (int i = 0; i < players.length; i++) {
    if (players[i].pieces[0].position == -1)
      players[i].noOfPiecesInInitialBox += 1;
    if (players[i].pieces[0].position >= 56) players[i].noOfPiecesInHome += 1;

    if (players[i].pieces[1].position == -1)
      players[i].noOfPiecesInInitialBox += 1;
    if (players[i].pieces[1].position >= 56) players[i].noOfPiecesInHome += 1;

    if (players[i].pieces[2].position == -1)
      players[i].noOfPiecesInInitialBox += 1;
    if (players[i].pieces[2].position >= 56) players[i].noOfPiecesInHome += 1;

    if (players[i].pieces[3].position == -1)
      players[i].noOfPiecesInInitialBox += 1;
    if (players[i].pieces[3].position >= 56) players[i].noOfPiecesInHome += 1;
  }
  return players;
}

int startGameSuggestion(Map map) {
  // Initializing Players State
  List<PlayerClass> players = new List<PlayerClass>();
  PlayerClass player0 = map["0"] != null
      ? new PlayerClass(
          map["0"]["0"], map["0"]["1"], map["0"]["2"], map["0"]["3"])
      : PlayerClass(-2, -2, -2, -2);
  if (player0.getPiecePosition(0) == -2) player0.playerNotInGame = true;
  players.add(player0);

  PlayerClass player1 = map["1"] != null
      ? new PlayerClass(
          map["1"]["0"], map["1"]["1"], map["1"]["2"], map["1"]["3"])
      : PlayerClass(-2, -2, -2, -2);
  if (player1.getPiecePosition(0) == -2) player1.playerNotInGame = true;
  players.add(player1);

  PlayerClass player2 = map["2"] != null
      ? new PlayerClass(
          map["2"]["0"], map["2"]["1"], map["2"]["2"], map["2"]["3"])
      : PlayerClass(-2, -2, -2, -2);
  if (player2.pieces[0].position == -2) player2.playerNotInGame = true;
  players.add(player2);

  PlayerClass player3 = map["3"] != null
      ? new PlayerClass(
          map["3"]["0"], map["3"]["1"], map["3"]["2"], map["3"]["3"])
      : PlayerClass(-2, -2, -2, -2);
  if (player3.pieces[0].position == -2) player3.playerNotInGame = true;
  players.add(player3);

  int noOnDice = map["noOnDice"] != null ? map["noOnDice"] : 0;

  players = setHomeAndInitVariables(
      players); //Initializing No of Pieces in Home and In Initial Box
  GameConfiguration gameConfiguration =
      new GameConfiguration(players: players, noOnDice: noOnDice);
  gameConfiguration.printPlayersPosition();

  return gameConfiguration.pieceNoToMove();
}



