# Unlock Egypt

An iOS tourism app that helps visitors discover and learn about Egypt's 5,000 years of history through immersive storytelling, gamification, and location-based features.

## Features

### Core Experience
- **Storytelling Cards**: Bite-sized educational content about historical sites with images, facts, and embedded quizzes
- **Dual Key System**: Earn Knowledge Keys by completing stories and Discovery Keys by visiting sites
- **Achievement System**: 12 unlockable achievements across Exploration, Knowledge, and Mastery categories
- **Rank Progression**: Rise from Tourist to Pharaoh based on earned Ankh Points

### Discovery
- **Search & Filter**: Find sites by name, city, historical period, or type
- **Nearby Sites**: Location-based discovery of historical sites around you
- **Timeline View**: Navigate Egypt's history chronologically from Pre-Dynastic to Modern era
- **Favorites**: Save sites for quick access

### Gamification
- **Ankh Points**: Earn points through stories (+1), quizzes (+10), verified visits (+50), and achievements
- **Ranks**: Tourist → Traveler → Explorer → Historian → Archaeologist → Pharaoh
- **Achievements**: Unlock badges for exploration milestones, knowledge gained, and mastery

### Sharing
- **Share Sites**: Share site information with friends
- **Share Achievements**: Celebrate unlocked achievements
- **Profile Card**: Shareable journey summary with rank and stats

### Offline Support
- **Content Caching**: Download sites and images for offline access
- **Bundled Fallback**: App works without internet using bundled content

## Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **iOS 17+**: Minimum deployment target
- **MVVM Architecture**: Clean separation of concerns
- **CoreLocation**: Location verification for Discovery Keys
- **Async/Await**: Modern concurrency for network operations

## Project Structure

```
UnlockEgypt/
├── Sources/
│   ├── App/                    # App entry point
│   ├── Models/                 # Data models (Site, Achievement)
│   ├── ViewModels/             # View models (HomeViewModel)
│   ├── Views/                  # SwiftUI views
│   │   ├── Components/         # Reusable UI components
│   │   ├── Explore/            # Site detail and story views
│   │   ├── Home/               # Main tab views
│   │   ├── Nearby/             # Location-based views
│   │   ├── Onboarding/         # First-launch experience
│   │   ├── Profile/            # Shareable profile card
│   │   ├── Settings/           # Settings and achievements
│   │   └── Timeline/           # Historical timeline
│   ├── Services/               # Business logic services
│   ├── Extensions/             # Swift extensions
│   └── Preview/                # SwiftUI preview data
├── Resources/                  # Assets and bundled content
├── ContentManagement/          # Google Sheets sync tools
└── content/                    # JSON content for GitHub hosting
```

## Content Management

Site content is managed via Google Sheets and synced to JSON:

1. Edit content in Google Sheets
2. Run `python ContentManagement/sync_content.py`
3. Content is fetched from GitHub on app launch

See `ContentManagement/README.md` for detailed setup.

## Building

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen):
   ```bash
   brew install xcodegen
   ```

2. Generate Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open `UnlockEgypt.xcodeproj` in Xcode

4. Build and run on simulator or device

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## License

Private project - All rights reserved.
