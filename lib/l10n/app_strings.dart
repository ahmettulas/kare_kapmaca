/// Supported in-app UI languages. Independent from the device locale —
/// selectable from the Settings screen and persisted there.
enum AppLanguage { en, tr }

/// Hand-rolled string table for the two supported languages. Every
/// user-facing string in the app should be read from here (via
/// `context.watch<SettingsService>().strings`) rather than hardcoded,
/// so the whole app follows the language chosen in Settings.
class AppStrings {
  const AppStrings._(this.language);

  final AppLanguage language;

  static const en = AppStrings._(AppLanguage.en);
  static const tr = AppStrings._(AppLanguage.tr);

  bool get _isTr => language == AppLanguage.tr;
  String _t(String english, String turkish) => _isTr ? turkish : english;

  // Main menu
  String get appTitleLine1 => _t('DOTS', 'KARE');
  String get appTitleLine2 => _t('BOXES', 'KAPMACA');
  String get appTagline =>
      _t('Draw lines, claim boxes!', 'Çizgileri çek, kareleri kap!');
  String get createRoomTitle => _t('CREATE ROOM', 'ODA KUR');
  String get createRoomSubtitle => _t('Start a new room', 'Yeni oda oluştur');
  String get joinRoomTitle => _t('JOIN ROOM', 'ODAYA KATIL');
  String get joinRoomSubtitle => _t('Join with an ID', 'ID ile odaya katıl');
  String get samePhoneTitle => _t('SAME PHONE', 'AYNI TELEFON');
  String get samePhoneSubtitle => _t('Take turns', 'Sırayla oyna');
  String get howToPlayTitle => _t('How to Play?', 'Nasıl Oynanır?');
  String get howToPlaySubtitle => _t('Learn the rules', 'Kuralları öğren');

  // Shared setup sections
  String get sectionBoardSize =>
      _t('CHOOSE BOARD SIZE', 'ALAN BOYUTU SEÇ');
  String get sectionPlayerSettings =>
      _t('PLAYER SETTINGS', 'OYUNCU AYARLARI');
  String get player1YouLabel => _t('Player 1 (You)', 'Oyuncu 1 (Sen)');
  String get player1Label => _t('Player 1', 'Oyuncu 1');
  String get player2Label => _t('Player 2', 'Oyuncu 2');
  String get nameHint => _t('Enter your name', 'Adını yaz');
  String get lineColorLabel => _t('Line Color', 'Çizgi Rengi');
  String get customSizeLabel => _t('Custom', 'Özel');

  // Create room screen
  String get createRoomButton => _t('CREATE ROOM', 'ODA OLUŞTUR');
  String get opponentWillPickColor =>
      _t('Opponent will pick a color', 'Rakip rengi seçecek');
  String get createRoomInfoNote => _t(
    "After creating the room you'll get an ID — share it with your "
        'friend so they can join.',
    'Oda oluşturduktan sonra bir ID alacak ve arkadaşın bu ID ile '
        'katılacak.',
  );
  String get defaultYouName => _t('You', 'Sen');

  // Join room screen
  String get invalidRoomIdError =>
      _t('Enter a valid room ID.', 'Geçerli bir oda ID girin.');
  String get joinRoomIntro => _t(
    "Enter the room ID your friend gave you\nand join the game.",
    "Arkadaşının verdiği oda ID'sini gir\nve oyuna katıl.",
  );
  String get roomIdLabel => _t('ROOM ID', 'ODA ID');
  String get roomIdHint => _t('e.g. 482913', 'Örn: 482913');
  String get howToFindTitle => _t('HOW DO I FIND IT?', 'NASIL BULURUM?');
  String get howToFindBody => _t(
    'The room creator gives you an ID. Enter it here to join the '
        'same room.',
    "Oda kuran kişi sana bir ID verir. Bu ID'yi buraya girerek aynı "
        'odaya katılabilirsin.',
  );
  String get joinButton => _t('JOIN', 'KATIL');

  // Local (same-phone) setup screen
  String get samePhoneScreenTitle =>
      _t('PLAY ON SAME PHONE', 'AYNI TELEFONDA OYNA');
  String get startGameButton => _t('START GAME', 'OYUNA BAŞLA');
  String get player1Fallback => _t('Player 1', 'Oyuncu 1');
  String get player2Fallback => _t('Player 2', 'Oyuncu 2');

  // Game screen
  String get quitDialogTitle => _t('Quit game?', 'Oyundan çık?');
  String get quitDialogBody => _t(
    'Your progress in this game will be lost.',
    'Bu oyundaki ilerleme kaybolacak.',
  );
  String get cancelLabel => _t('Cancel', 'Vazgeç');
  String get quitLabel => _t('Quit', 'Çık');
  String get turnPrefix => _t('TURN', 'SIRADA');
  String get undoLabel => _t('UNDO', 'GERİ AL');
  String get quitGameLabel => _t('QUIT GAME', 'OYUNDAN ÇIK');

  // Game over screen
  String get gameOverTitle => _t('GAME OVER!', 'OYUN BİTTİ!');
  String get vsLabel => 'VS';
  String get statBoxesCreated => _t('Boxes Created', 'Oluşturulan Kareler');
  String get statLongestStreak => _t('Longest Streak', 'En Uzun Seri');
  String get statMoveCount => _t('Move Count', 'Hamle Sayısı');
  String get newGameButton => _t('NEW GAME', 'YENİ OYUN');
  String get rematchButton => _t('PLAY AGAIN', 'TEKRAR OYNA');
  String get mainMenuButton => _t('BACK TO MENU', 'ANA MENÜYE DÖN');
  String get roomIdPrefix => _t('Room ID', 'Oda ID');

  // How to play screen
  String get howToPlayScreenTitle => _t('HOW TO PLAY?', 'NASIL OYNANIR?');
  String get step1Title => _t('Connect the Dots', 'Noktaları Birleştir');
  String get step1Body => _t(
    "On your turn, tap between two neighboring dots to draw a line.",
    'Sıra sende iken iki komşu nokta arasına dokunarak bir çizgi çek.',
  );
  String get step2Title => _t('Complete a Box', 'Kareyi Tamamla');
  String get step2Body => _t(
    'Draw the line that completes all four sides of a box and it '
        "fills with your color (and photo, if you set one).",
    'Bir karenin dört kenarını da tamamlayan çizgiyi çekersen o kare '
        'senin rengin ve fotoğrafınla (varsa) dolar.',
  );
  String get step3Title => _t('Earn an Extra Turn', 'Ekstra Hamle Kazan');
  String get step3Body => _t(
    'Completing a box means you go again — chain boxes together for '
        'a streak.',
    'Bir kare tamamladığında sıra sende kalır — art arda kare '
        'yaparak seri yapabilirsin.',
  );
  String get step4Title => _t('Turn Passes', 'Sıra Geçer');
  String get step4Body => _t(
    "If your move doesn't complete a box, the turn passes to your "
        'opponent.',
    'Kare tamamlamayan bir hamle yaparsan sıra rakibine geçer.',
  );
  String get step5Title => _t('Determine the Winner', 'Kazananı Belirle');
  String get step5Body => _t(
    'Once every box is filled, whoever owns the most boxes wins.',
    'Tüm kareler dolduğunda en çok kareye sahip oyuncu oyunu kazanır.',
  );

  // Stats screen
  String get statsScreenTitle => _t('STATISTICS', 'İSTATİSTİKLER');
  String get gamesPlayedLabel => _t('Games Played', 'Oynanan Oyun');
  String get totalBoxesLabel => _t('Total Boxes', 'Toplam Kare');
  String get bestStreakLabel =>
      _t('Longest Streak (all time)', 'En Uzun Seri (tüm zamanlar)');
  String get historyLabel => _t('HISTORY', 'GEÇMİŞ');
  String get noHistoryYet =>
      _t('No completed games yet.', 'Henüz tamamlanmış bir oyun yok.');

  // Settings screen
  String get settingsScreenTitle => _t('SETTINGS', 'AYARLAR');
  String get soundEffectsLabel => _t('Sound Effects', 'Ses Efektleri');
  String get musicLabel => _t('Background Music', 'Arka Plan Müziği');
  String get hapticsLabel => _t('Vibration', 'Titreşim');
  String get languageLabel => _t('Language', 'Dil');
  String get languageEnglish => _t('English', 'İngilizce');
  String get languageTurkish => _t('Turkish', 'Türkçe');
  String get themeLabel => _t('Theme', 'Tema');
  String get themeSheetTitle => _t('Choose a theme', 'Bir tema seç');
  String get versionFooter => 'Kare Kapmaca v1.0.0';

  // Online rooms
  String get roomPrefix => _t('Room', 'Oda');
  String get waitingRoomTitle => _t('WAITING FOR OPPONENT', 'RAKİP BEKLENİYOR');
  String get waitingForOpponentBody => _t(
    "Share this code with your friend so they can join.",
    'Bu kodu arkadaşınla paylaş, katılmasını bekle.',
  );
  String get roomCreateError => _t(
    "Couldn't create the room. Check your connection and try again.",
    'Oda oluşturulamadı. Bağlantını kontrol edip tekrar dene.',
  );
  String get roomNotFoundError =>
      _t('No room found with that ID.', 'Bu ID ile bir oda bulunamadı.');
  String get roomFullError => _t(
    'This room already has two players.',
    'Bu odada zaten iki oyuncu var.',
  );
  String get opponentLeftMessage =>
      _t('Your opponent left the room.', 'Rakibin odadan ayrıldı.');
  String get roomJoinError => _t(
    "Couldn't join the room. Check your connection and try again.",
    'Odaya katılınamadı. Bağlantını kontrol edip tekrar dene.',
  );
  String get moveSyncError => _t(
    "Couldn't send your move. Check your connection.",
    'Hamlen gönderilemedi. Bağlantını kontrol et.',
  );
  String get connectionLostError => _t(
    'Connection to the room was lost.',
    'Odayla bağlantı koptu.',
  );

  // Custom board size dialog
  String get customSizeDialogTitle =>
      _t('Custom Board Size', 'Özel Alan Boyutu');
  String customSizeDialogHint(int min, int max) => _t(
    'Enter dot counts (min $min, max $max).',
    'Nokta sayısını gir (en az $min, en fazla $max).',
  );
  String get widthLabel => _t('WIDTH', 'GENİŞLİK');
  String get heightLabel => _t('HEIGHT', 'YÜKSEKLİK');
  String get applyLabel => _t('Apply', 'Uygula');
}
