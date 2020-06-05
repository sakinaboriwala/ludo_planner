import 'piece.dart';

class PlayerClass {
  List<Piece> pieces;
  int noOfPiecesInHome;
  int noOfPiecesInInitialBox;
  bool playerNotInGame;

  PlayerClass(int a, int b, int c, int d) {
    pieces = new List<Piece>();

    pieces.add(new Piece(a));
    pieces.add(new Piece(b));
    pieces.add(new Piece(c));
    pieces.add(new Piece(d));

    this.playerNotInGame = false;
    this.noOfPiecesInInitialBox = 0;
    this.noOfPiecesInHome = 0;
  }

  int getNoOfPiecesInHome() => this.noOfPiecesInHome;

  int getNoOfPiecesBox() => this.noOfPiecesInInitialBox;

  int getPiecePosition(int pieceNo) {
    return this.pieces[pieceNo].getCurrentPosition();
  }
}
