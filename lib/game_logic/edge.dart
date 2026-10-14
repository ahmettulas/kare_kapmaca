enum EdgeType { horizontal, vertical }

/// Identifies a single claimable line segment on the grid.
///
/// A [EdgeType.horizontal] edge at (row, col) connects dot (row, col) to
/// dot (row, col + 1). A [EdgeType.vertical] edge at (row, col) connects
/// dot (row, col) to dot (row + 1, col).
class EdgeId {
  const EdgeId(this.type, this.row, this.col);

  final EdgeType type;
  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is EdgeId &&
      other.type == type &&
      other.row == row &&
      other.col == col;

  @override
  int get hashCode => Object.hash(type, row, col);
}
