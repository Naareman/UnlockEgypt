# Content Update Workflow

This guide explains how to update the Unlock Egypt app content.

## Overview

```
Google Sheets (edit content) → Export CSV → Run sync script → Push to GitHub → App fetches update
```

## Step-by-Step Guide

### 1. Edit Content in Google Sheets

Open your Google Sheet:
https://docs.google.com/spreadsheets/d/17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs/edit

Make your changes to any of the 5 sheets:
- **Sites** - Main locations (pyramids, temples, etc.)
- **SubLocations** - Areas within each site
- **Cards** - Story content and quizzes
- **Tips** - Visitor tips
- **ArabicPhrases** - Useful phrases

### 2. Export Updated CSV Files

For each sheet you modified:

1. Click on the sheet tab (e.g., "Sites")
2. Go to **File → Download → Comma Separated Values (.csv)**
3. Save to `ContentManagement/data/` folder:
   - Sites → `1_sites.csv`
   - SubLocations → `2_sublocations.csv`
   - Cards → `3_cards.csv`
   - Tips → `4_tips.csv`
   - ArabicPhrases → `5_arabicphrases.csv`

### 3. Run the Sync Script

Open Terminal in the project folder and run:

```bash
cd ContentManagement
python3 sync_content.py
```

This will:
- Read all CSV files
- Convert to app JSON format
- Save to `content/unlock_egypt_content.json`

### 4. Push to GitHub

```bash
cd ..
git add content/unlock_egypt_content.json
git commit -m "Update content"
git push
```

### 5. App Updates Automatically

The app will fetch the new content from:
```
https://raw.githubusercontent.com/Naareman/UnlockEgypt/main/content/unlock_egypt_content.json
```

Users will see the new content next time they open the app (with internet connection).

---

## Quick Reference

### Adding a New Site

1. **Sites sheet**: Add a row with site details
2. **SubLocations sheet**: Add sub-locations for the site
3. **Cards sheet**: Add story cards for each sub-location
4. **Tips sheet**: Add visitor tips
5. **ArabicPhrases sheet**: Add useful phrases
6. Run sync script and push

### Adding a Quiz

In the **Cards sheet**, add a row with:
- `type` = `quiz`
- Fill in `quizQuestion`, `quizOption1-4`, `quizCorrectAnswer` (1-4), `quizExplanation`

### Column Reference

**Sites columns:**
| Column | Description | Example |
|--------|-------------|---------|
| id | Unique identifier | `egyptian_museum` |
| name | Display name | `Egyptian Museum` |
| arabicName | Arabic name | `المتحف المصري` |
| era | Historical era | `Modern` |
| tourismType | Category | `Pharaonic` |
| placeType | Type of place | `Museum` |
| city | Location | `Cairo` |
| shortDescription | Brief description | `Home to the world's largest...` |
| latitude | GPS latitude | `30.0478` |
| longitude | GPS longitude | `31.2336` |
| imageNames | Comma-separated images | `museum_1,museum_2` |
| estimatedDuration | Visit time | `2-3 hours` |
| bestTimeToVisit | Timing advice | `Morning` |

**Cards columns:**
| Column | Description |
|--------|-------------|
| id | Unique card ID |
| subLocationId | Links to SubLocation |
| order | Display order (1, 2, 3...) |
| type | `intro`, `story`, `fact`, `quiz`, `summary` |
| content | Text content (for intro/story) |
| funFact | Fun fact text (for fact type) |
| quizQuestion | Question text |
| quizOption1-4 | Answer options |
| quizCorrectAnswer | Correct option (1-4) |
| quizExplanation | Explanation after answering |

---

## File Locations

```
UnlockEgypt/
├── ContentManagement/
│   ├── data/                    # CSV files from Google Sheets
│   │   ├── 1_sites.csv
│   │   ├── 2_sublocations.csv
│   │   ├── 3_cards.csv
│   │   ├── 4_tips.csv
│   │   └── 5_arabicphrases.csv
│   ├── sync_content.py          # Conversion script
│   └── UPDATE_WORKFLOW.md       # This file
│
├── content/
│   └── unlock_egypt_content.json  # Generated JSON (hosted on GitHub)
│
└── Sources/
    └── Services/
        └── ContentService.swift   # App fetches from GitHub
```

---

## Troubleshooting

**Content not updating in app?**
- Check internet connection
- The app caches content - try force-quitting and reopening
- Verify the JSON file is on GitHub: check the raw URL

**Sync script error?**
- Make sure Python 3 is installed
- Check CSV files are in the correct location
- Ensure CSV format matches expected columns

**Quiz not working?**
- `quizCorrectAnswer` should be 1, 2, 3, or 4 (not 0-based)
- All four `quizOption` fields must be filled
- `type` must be exactly `quiz`
