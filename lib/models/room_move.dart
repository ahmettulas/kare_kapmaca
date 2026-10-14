import '../game_logic/edge.dart';

/// One claimed edge as stored in a Firestore room document's `moves`
/// array, in the order it was played.
class RoomMove {
  const RoomMove({required this.edge, required this.player});

  final EdgeId edge;
  final int player;

  Map<String, dynamic> toMap() => {
    't': edge.type == EdgeType.horizontal ? 'h' : 'v',
    'r': edge.row,
    'c': edge.col,
    'p': player,
  };

  factory RoomMove.fromMap(Map<String, dynamic> map) => RoomMove(
    edge: EdgeId(
      map['t'] == 'h' ? EdgeType.horizontal : EdgeType.vertical,
      map['r'] as int,
      map['c'] as int,
    ),
    player: map['p'] as int,
  );
}
