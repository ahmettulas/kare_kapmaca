import 'dart:math';

/// Generates a short numeric room code (e.g. "482913").
String generateRoomCode({int length = 6}) {
  final random = Random();
  return List.generate(length, (_) => random.nextInt(10)).join();
}
