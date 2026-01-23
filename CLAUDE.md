# Unlock Egypt - Project Context for Claude

## App Overview
**Unlock Egypt** is an iOS tourism app built with SwiftUI that gamifies exploring Egyptian historical sites. Users earn points and badges by learning about sites and physically visiting them.

### Two-Badge System (Keys)
1. **Knowledge Key** (gold) - Earned by reading ALL story cards for a sublocation
2. **Discovery Key** (gold) - Earned by physically visiting a site (location verified = 50pts, self-reported = 30pts)

Both badges use **gold color** for Egyptian theme consistency. Icons differentiate them (key.fill vs mappin.circle.fill).

### Points System
- Reading story cards: 1 point per sublocation completed
- Quiz correct answer: 10 points
- Location-verified visit: 50 points
- Self-reported visit: 30 points
- Upgrading self-report to verified: +20 bonus

## Project Structure
```
UnlockEgypt/
├── Sources/
│   ├── Models/           # Site, SubLocation, StoryCard, Achievement
│   ├── ViewModels/       # HomeViewModel (main state management)
│   ├── Views/
│   │   ├── Home/         # HomeView, FavoritesView
│   │   ├── Explore/      # SiteDetailView, StoryCardView
│   │   ├── Components/   # BadgeView, SiteCard
│   │   └── ...
│   └── Services/         # ContentService, LocationManager, ImageCacheService
├── ContentManagement/
│   ├── sync_content.py   # Converts Google Sheets → JSON with validation
│   └── data/             # Downloaded CSV files
├── Resources/
│   └── unlock_egypt_content.json  # Bundled content
├── content/
│   └── unlock_egypt_content.json  # For GitHub hosting
└── UpdateContent.command  # Double-click to update content from Google Sheets
```

## Content Management System

### Google Sheets Structure
- **Sheet 1 (Sites)**: id, name, arabicName, era, tourismType, placeType, city, latitude, longitude, shortDescription, imageNames, estimatedDuration, bestTimeToVisit
- **Sheet 2 (SubLocations)**: id, siteId, name, arabicName, shortDescription, imageName
- **Sheet 3 (Cards)**: id, subLocationId, order, type, imageUrl, content, funFact, quizQuestion, quizOption1-4, quizCorrectAnswer, quizExplanation
- **Sheet 4 (Tips)**: siteId, tip
- **Sheet 5 (ArabicPhrases)**: siteId, english, arabic, pronunciation

### Content Validation (sync_content.py)
Comprehensive validation before JSON generation:
- Required fields check
- Valid enum values (era, city, placeType, tourismType, cardType)
- Egypt coordinate bounds (lat 21-32, lon 24-37)
- Arabic text detection in arabicName fields
- Foreign key validation (siteId, subLocationId references)
- Quiz completeness (all 4 options, answer 1-4, explanation)
- URL existence check (HTTP HEAD request)
- Duplicate content detection
- Minimum content length checks
- Orphaned sublocation detection (no cards = can't earn Knowledge Key)

### Updating Content
1. Edit Google Sheet: https://docs.google.com/spreadsheets/d/17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs
2. Double-click `UpdateContent.command`
3. Script downloads CSVs → validates → generates JSON → pushes to GitHub

## Key Technical Decisions

### Architecture
- MVVM with `HomeViewModel` as central state manager
- `@MainActor` for UI thread safety
- `[weak self]` in all async closures to prevent retain cycles
- Combine for reactive updates from ContentService

### Location Verification
- Uses callback-based location requests with 10-second timeout
- Checks `isAuthorized` and `isDenied` before requesting location
- 200-meter radius for verification
- 30-day cooldown before earning points again at same site

### Image Caching (ImageCacheService)
- 100MB cache limit with LRU eviction
- 30-day expiration
- 3 retries with exponential backoff
- HTTPS enforcement

## Recent Session Work (Jan 2026)

### QA/QC Fixes Applied
- Race condition in location verification → callback-based approach
- Location permission checks before verification
- ShareService thread safety (@MainActor)
- Quiz empty options crash guard
- Image loading retry logic

### iOS Lead Review Fixes
- Memory leak in LocationManager → [weak self] in delegate Tasks
- Made CLLocationManager optional with proper deinit cleanup

### UX Improvements
- Unified badge colors (both gold)
- Adventure-focused copy for discovery flow:
  - "PROVE YOU WERE HERE" instead of "DISCOVERY KEY"
  - "I'm Here Now" instead of "Verify My Location"
  - "I've Been Here Before" instead of "Mark as Visited"
- Knowledge badge only shows when ALL stories read (not just one)

## Valid Enum Values

### Era
Pre-Dynastic, Old Kingdom, Middle Kingdom, New Kingdom, Late Period, Ptolemaic, Roman, Islamic, Modern

### Tourism Type
Pharaonic, Greco-Roman, Coptic, Islamic, Modern

### Place Type
Pyramid, Temple, Tomb, Museum, Mosque, Church, Fortress, Market, Monument, Ruins

### City
Cairo, Giza, Luxor, Aswan, Alexandria, Sinai, Fayoum, Dahab, Hurghada, Sharm El Sheikh

### Card Type
intro, story, fact, quiz, image
