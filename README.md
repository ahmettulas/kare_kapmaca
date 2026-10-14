# Kare Kapmaca

Klasik **Noktalar ve Kutular (Dots & Boxes)** oyununun Flutter sürümü. Aynı cihazda iki kişilik yerel oyun ve Firebase Firestore üzerinden oda kodu ile çevrimiçi oyun destekler.

**Canlı demo:** https://ahmettulas.github.io/kare_kapmaca/

## Özellikler

- Yerel (aynı cihaz) iki oyunculu mod
- Oda kodu ile çevrimiçi oyun (Firestore)
- Farklı tahta boyutları ve özel boyut
- Temalar, müzik ve ses efektleri
- İstatistikler ve ayarlar (cihazda saklanır)

## Yerelde çalıştırma

```bash
flutter pub get
flutter run -d chrome
```

Testler:

```bash
flutter test
```

## Web demosu (GitHub Pages)

`main` dalına her push'ta [.github/workflows/deploy-web.yml](.github/workflows/deploy-web.yml) uygulamayı web için derleyip GitHub Pages'e yayınlar.

İlk kurulumda bir kez: **Settings → Pages → Build and deployment → Source: GitHub Actions** seçin.

Not: Reklamlar (AdMob) yalnızca Android'de gösterilir; web demosunda reklam yoktur.
