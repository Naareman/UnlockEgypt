# Content Management

This folder contains tools to manage Unlock Egypt app content via Google Sheets.

## Quick Start

1. **Share your Google Sheet** (one-time):
   - Open: https://docs.google.com/spreadsheets/d/17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs/edit
   - Click **Share** → Change to **"Anyone with the link can view"**

2. **Update content**: Double-click `UpdateContent.command` in the project root

That's it! The script downloads from Google Sheets, converts to JSON, and pushes to GitHub.

---

## Google Sheets Structure

Your spreadsheet has **5 sheets**:

### 1. Sites
Main historical sites.

| Column | Description | Example |
|--------|-------------|---------|
| id | Unique ID (lowercase) | `abu_simbel` |
| name | English name | `Abu Simbel` |
| arabicName | Arabic name | `أبو سمبل` |
| era | Historical era | `New Kingdom` |
| tourismType | Category | `Pharaonic` |
| placeType | Type | `Temple` |
| city | Location | `Aswan` |
| shortDescription | Brief description | `Ramesses II's temple...` |
| latitude | GPS latitude | `22.3372` |
| longitude | GPS longitude | `31.6258` |
| imageNames | Comma-separated | `abu_1,abu_2` |
| estimatedDuration | Visit time | `2-3 hours` |
| bestTimeToVisit | Timing tip | `Early morning` |

**Dropdown values:**
- era: `Pre-Dynastic, Old Kingdom, Middle Kingdom, New Kingdom, Late Period, Ptolemaic, Roman, Islamic, Modern`
- tourismType: `Pharaonic, Greco-Roman, Coptic, Islamic, Modern`
- placeType: `Pyramid, Temple, Tomb, Museum, Mosque, Church, Fortress, Market, Monument, Ruins`
- city: `Cairo, Giza, Luxor, Aswan, Alexandria, Sinai, Fayoum, Dahab, Hurghada, Sharm El Sheikh`

### 2. SubLocations
Places within each site.

| Column | Description |
|--------|-------------|
| id | Unique ID |
| siteId | Links to Sites.id |
| name | English name |
| arabicName | Arabic name |
| shortDescription | Brief description |
| imageName | Image name |

### 3. Cards
Story cards for each sub-location.

| Column | Description |
|--------|-------------|
| id | Unique ID |
| subLocationId | Links to SubLocations.id |
| order | Display order (1, 2, 3...) |
| type | `intro`, `story`, `fact`, `quiz`, `summary` |
| content | Text (for intro/story/summary) |
| funFact | Text (for fact type) |
| quizQuestion | Question text |
| quizOption1-4 | Answer options |
| quizCorrectAnswer | Correct option (1-4) |
| quizExplanation | Shown after answering |

### 4. Tips
Visitor tips for each site.

| Column | Description |
|--------|-------------|
| id | Unique ID |
| siteId | Links to Sites.id |
| order | Display order |
| tip | Tip text |

### 5. ArabicPhrases
Useful phrases for each site.

| Column | Description |
|--------|-------------|
| id | Unique ID |
| siteId | Links to Sites.id |
| english | English phrase |
| arabic | Arabic phrase |
| pronunciation | How to say it |

---

## Adding New Content

### New Site
1. **Sites**: Add row with site details
2. **SubLocations**: Add places within the site (use site's id)
3. **Cards**: Add story cards (use sublocation's id)
4. **Tips**: Add visitor tips (use site's id)
5. **ArabicPhrases**: Add phrases (use site's id)

### New Quiz
In Cards sheet, add a row with:
- `type` = `quiz`
- Fill `quizQuestion`, `quizOption1-4`, `quizCorrectAnswer` (1-4), `quizExplanation`

---

## Files

```
ContentManagement/
├── README.md           # This file
├── sync_content.py     # Converts CSV → JSON
└── data/               # CSV exports from Google Sheets
    ├── 1_sites.csv
    ├── 2_sublocations.csv
    ├── 3_cards.csv
    ├── 4_tips.csv
    └── 5_arabicphrases.csv
```

---

## Manual Update (if needed)

If the double-click script doesn't work:

```bash
cd ContentManagement
python3 sync_content.py
cd ..
git add content/ Resources/
git commit -m "Update content"
git push
```
