import 'package:flutter/foundation.dart' show Uint8List;

/// Remembers the last avatar photo the player picked, for this app run
/// only — never written to disk. It carries the photo across creating or
/// joining multiple rooms in the same session (so they only have to pick
/// it once and can still change it any time), but resets to nothing on a
/// full app restart, same as the display name.
class LocalIdentityService {
  String? avatarPath;
  Uint8List? avatarBytes;

  void setAvatar({String? path, Uint8List? bytes}) {
    avatarPath = path;
    avatarBytes = bytes;
  }
}
