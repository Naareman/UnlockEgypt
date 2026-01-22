# Unlock Egypt - Google Sheets Content Template

This document describes how to set up and use Google Sheets to manage content for the Unlock Egypt app.

## Overview

The content is organized into **5 sheets** (tabs) in one Google Spreadsheet:

1. **Sites** - Main historical sites
2. **SubLocations** - Places within each site
3. **Cards** - Story cards for each sub-location
4. **Tips** - Visitor tips for each site
5. **ArabicPhrases** - Useful phrases for each site

---

## Sheet 1: Sites

The main table containing all historical sites.

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| id | Text | Yes | Unique identifier (lowercase, underscores) | `abu_simbel` |
| name | Text | Yes | Site name in English | `Abu Simbel` |
| arabicName | Text | Yes | Site name in Arabic | `أبو سمبل` |
| era | Dropdown | Yes | Historical era | `New Kingdom` |
| tourismType | Dropdown | Yes | Type of tourism | `Pharaonic` |
| placeType | Dropdown | Yes | Type of place | `Temple` |
| city | Dropdown | Yes | City/region | `Aswan` |
| shortDescription | Text | Yes | One-line description | `Ramesses II's monumental temple...` |
| latitude | Number | Yes | GPS latitude | `22.3372` |
| longitude | Number | Yes | GPS longitude | `31.6258` |
| imageUrl | URL | No | Main image URL | `https://...` |
| isUnlocked | Boolean | Yes | Available by default | `TRUE` |
| estimatedDuration | Text | Yes | Visit duration | `2-3 hours` |
| bestTimeToVisit | Text | Yes | Best time to visit | `Early morning` |

### Dropdown Values for Sites:

**era:**
- Pre-Dynastic
- Old Kingdom
- Middle Kingdom
- New Kingdom
- Late Period
- Ptolemaic
- Roman
- Islamic
- Modern

**tourismType:**
- Pharaonic
- Greco-Roman
- Coptic
- Islamic
- Modern

**placeType:**
- Pyramid
- Temple
- Tomb
- Museum
- Mosque
- Church
- Fortress
- Market
- Monument
- Ruins

**city:**
- Cairo
- Giza
- Luxor
- Aswan
- Alexandria
- Sinai
- Fayoum
- Dahab
- Hurghada
- Sharm El Sheikh

---

## Sheet 2: SubLocations

Places to explore within each site (one-to-many relationship).

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| id | Text | Yes | Unique identifier | `great_pyramid` |
| siteId | Text | Yes | Links to Sites.id | `giza` |
| name | Text | Yes | Name in English | `Great Pyramid of Khufu` |
| arabicName | Text | Yes | Name in Arabic | `هرم خوفو الأكبر` |
| shortDescription | Text | Yes | One-line description | `The largest and oldest...` |
| imageUrl | URL | No | Image URL | `https://...` |
| order | Number | Yes | Display order | `1` |

---

## Sheet 3: Cards

Story cards for each sub-location (one-to-many relationship).

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| id | Text | Yes | Unique identifier | `khufu_1` |
| subLocationId | Text | Yes | Links to SubLocations.id | `great_pyramid` |
| order | Number | Yes | Card order (1, 2, 3...) | `1` |
| type | Dropdown | Yes | Card type | `story` |
| imageUrl | URL | No | Image for this card | `https://...` |
| content | Text | Conditional | Story/intro text | `Standing 481 feet tall...` |
| funFact | Text | Conditional | Fun fact text | `The pyramid contains...` |
| quizQuestion | Text | Conditional | Quiz question | `Who built the pyramid?` |
| quizOption1 | Text | Conditional | First answer option | `Pharaoh Khufu` |
| quizOption2 | Text | Conditional | Second answer option | `Cleopatra` |
| quizOption3 | Text | Conditional | Third answer option | `Ramesses II` |
| quizOption4 | Text | Conditional | Fourth answer option | `Tutankhamun` |
| quizCorrectAnswer | Number | Conditional | Correct option (1-4) | `1` |
| quizExplanation | Text | Conditional | Explanation after answer | `The Great Pyramid was built...` |

### Card Types:

| Type | Required Fields |
|------|-----------------|
| `intro` | content |
| `story` | content |
| `fact` | funFact |
| `quiz` | quizQuestion, quizOption1-4, quizCorrectAnswer, quizExplanation |
| `summary` | content |

---

## Sheet 4: Tips

Visitor tips for each site (one-to-many relationship).

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| id | Text | Yes | Unique identifier | `giza_tip_1` |
| siteId | Text | Yes | Links to Sites.id | `giza` |
| order | Number | Yes | Display order | `1` |
| tip | Text | Yes | The tip text | `Bring plenty of water...` |

---

## Sheet 5: ArabicPhrases

Useful Arabic phrases for each site (one-to-many relationship).

| Column | Type | Required | Description | Example |
|--------|------|----------|-------------|---------|
| id | Text | Yes | Unique identifier | `giza_phrase_1` |
| siteId | Text | Yes | Links to Sites.id | `giza` |
| english | Text | Yes | English phrase | `Pyramid` |
| arabic | Text | Yes | Arabic phrase | `هرم` |
| pronunciation | Text | Yes | How to say it | `haram` |

---

## How to Set Up

### Step 1: Create Google Sheet
1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new blank spreadsheet
3. Name it "Unlock Egypt Content"

### Step 2: Create the 5 Sheets
1. Rename "Sheet1" to "Sites"
2. Click + to add new sheets: "SubLocations", "Cards", "Tips", "ArabicPhrases"

### Step 3: Add Headers
Copy the column headers from each table above into the first row of each sheet.

### Step 4: Add Data Validation (Dropdowns)
For the Sites sheet:
1. Select the "era" column (excluding header)
2. Data → Data validation → Dropdown
3. Add all era options
4. Repeat for tourismType, placeType, city

### Step 5: Import Existing Data
Use the CSV files in the `ContentManagement/data/` folder to import existing content.

---

## How to Export for the App

### Option 1: Publish as CSV (Simple)
1. File → Share → Publish to web
2. Select each sheet → CSV format
3. Copy the URL for each sheet

### Option 2: Export as JSON (Better)
1. Use a Google Apps Script to export as JSON
2. Or use a tool like [SheetJS](https://sheetjs.com)

---

## Relationship Diagram

```
Sites (1)
  │
  ├── SubLocations (many)
  │     │
  │     └── Cards (many)
  │
  ├── Tips (many)
  │
  └── ArabicPhrases (many)
```

---

## Example: Adding a New Site

1. **Sites sheet**: Add a new row with site details
2. **SubLocations sheet**: Add rows for each place within the site (use the site's id)
3. **Cards sheet**: Add story cards for each sub-location (use the sublocation's id)
4. **Tips sheet**: Add visitor tips (use the site's id)
5. **ArabicPhrases sheet**: Add useful phrases (use the site's id)

---

## Image Hosting

Since Google Sheets only stores text, images need to be hosted elsewhere:

**Free Options:**
- [Imgur](https://imgur.com) - Free image hosting
- [Cloudinary](https://cloudinary.com) - Free tier available
- Google Drive - Make image public, use direct link
- GitHub - Store in repository

**Image URL Format:**
```
https://i.imgur.com/xxxxx.jpg
https://drive.google.com/uc?id=FILE_ID
https://raw.githubusercontent.com/user/repo/main/images/photo.jpg
```
