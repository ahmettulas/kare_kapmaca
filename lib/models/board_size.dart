/// Dot-grid dimensions for a board: [dotsWide] x [dotsHigh] dots, yielding
/// (dotsWide - 1) x (dotsHigh - 1) boxes. Most boards are square (the
/// preset sizes), but a custom board may be rectangular.
class BoardSize {
  const BoardSize(this.dotsWide, this.dotsHigh);

  final int dotsWide;
  final int dotsHigh;

  static const minDots = 2;

  int get boxesWide => dotsWide - 1;
  int get boxesHigh => dotsHigh - 1;

  String get label => '$dotsWide x $dotsHigh';

  bool matches(BoardSize other) =>
      dotsWide == other.dotsWide && dotsHigh == other.dotsHigh;

  static const presets = [BoardSize(4, 4), BoardSize(6, 6), BoardSize(8, 8)];

  bool get isPreset => presets.any(matches);
}
