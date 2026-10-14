import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/local_identity_service.dart';
import 'services/room_service.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/space_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter's default behavior for an uncaught error is a red error
  // screen in debug builds and total silence in release ones — neither
  // says *why* the app froze/crashed. Logging both channels means every
  // crash leaves something in the device console to diagnose from.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KareKapmacaApp());
}

class KareKapmacaApp extends StatefulWidget {
  const KareKapmacaApp({super.key});

  @override
  State<KareKapmacaApp> createState() => _KareKapmacaAppState();
}

class _KareKapmacaAppState extends State<KareKapmacaApp> with WidgetsBindingObserver {
  final _settings = SettingsService();
  final _stats = StatsService();
  final _audio = AudioService();
  final _rooms = RoomService();
  final _identity = LocalIdentityService();
  final _ads = AdService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stats.load();
    _settings.load().then((_) {
      if (_settings.musicEnabled) _audio.setMusicEnabled(true);
    });
    _ads.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audio.dispose();
    _ads.dispose();
    super.dispose();
  }

  // App backgrounded/paused (home button, task switcher, phone locked, ...):
  // pause music so it doesn't keep playing while the app isn't visible.
  // Resume on return, but only if the user's setting still has music on —
  // they may have toggled it off in Settings from another surface while away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _audio.setMusicEnabled(false);
        break;
      case AppLifecycleState.resumed:
        if (_settings.musicEnabled) _audio.setMusicEnabled(true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _stats),
        ChangeNotifierProvider.value(value: _settings),
        Provider.value(value: _audio),
        Provider.value(value: _rooms),
        Provider.value(value: _identity),
        Provider.value(value: _ads),
      ],
      // Rebuilds the whole app (picking up the fresh AppColors palette)
      // whenever the selected theme changes in Settings.
      child: AnimatedBuilder(
        animation: _settings,
        builder: (context, _) => MaterialApp(
          title: 'Kare Kapmaca',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const SplashScreen(),
          // Paints the current theme's backdrop behind every screen — a
          // photo if the theme has one, the procedural cinematic space
          // scene for the premium (Uzay) theme, or nothing for Classic
          // (which keeps its own plain Scaffold background).
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            final bgPath = AppColors.backgroundImagePath;
            Widget? backdrop;
            if (bgPath != null) {
              backdrop = Image.asset(bgPath, fit: BoxFit.cover);
            } else if (AppColors.isPremium) {
              backdrop = const SpaceBackground();
            }
            if (backdrop == null) return child;
            return Stack(
              fit: StackFit.expand,
              children: [backdrop, child],
            );
          },
        ),
      ),
    );
  }
}
