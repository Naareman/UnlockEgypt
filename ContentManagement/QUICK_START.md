# Quick Start: Setting Up Google Sheets

## Step 1: Create the Google Sheet

1. Go to [sheets.google.com](https://sheets.google.com)
2. Click **+ Blank** to create a new spreadsheet
3. Name it **"Unlock Egypt Content"**

## Step 2: Create 5 Tabs

At the bottom, rename and add tabs:
1. Rename "Sheet1" → **Sites**
2. Click **+** → **SubLocations**
3. Click **+** → **Cards**
4. Click **+** → **Tips**
5. Click **+** → **ArabicPhrases**

## Step 3: Import the CSV Data

For each tab:
1. Click on the tab (e.g., "Sites")
2. Go to **File → Import**
3. Click **Upload** → drag the corresponding CSV file:
   - `1_sites.csv` → Sites tab
   - `2_sublocations.csv` → SubLocations tab
   - `3_cards.csv` → Cards tab
   - `4_tips.csv` → Tips tab
   - `5_arabicphrases.csv` → ArabicPhrases tab
4. Choose **"Replace current sheet"**
5. Click **Import data**

## Step 4: Add Dropdown Validation (Optional but Recommended)

### For the Sites sheet:

**Era dropdown:**
1. Select cells in the "era" column (B2:B100)
2. **Data → Data validation → Add rule**
3. Criteria: **Dropdown (from a list)**
4. Enter: `Pre-Dynastic, Old Kingdom, Middle Kingdom, New Kingdom, Late Period, Ptolemaic, Roman, Islamic, Modern`
5. Click **Done**

**TourismType dropdown:**
- Values: `Pharaonic, Greco-Roman, Coptic, Islamic, Modern`

**PlaceType dropdown:**
- Values: `Pyramid, Temple, Tomb, Museum, Mosque, Church, Fortress, Market, Monument, Ruins`

**City dropdown:**
- Values: `Cairo, Giza, Luxor, Aswan, Alexandria, Sinai, Fayoum, Dahab, Hurghada, Sharm El Sheikh`

### For the Cards sheet:

**Type dropdown:**
1. Select the "type" column
2. Values: `intro, story, fact, quiz, summary`

## Step 5: Share the Sheet (Optional)

To let others edit:
1. Click **Share** (top right)
2. Add their email or get a shareable link
3. Set permission to **Editor**

---

## How to Add New Content

### Adding a New Site (e.g., "Egyptian Museum"):

1. **Sites tab**: Add a new row:
   | id | name | arabicName | era | ... |
   |---|---|---|---|---|
   | egyptian_museum | Egyptian Museum | المتحف المصري | Modern | ... |

2. **SubLocations tab**: Add places within it:
   | id | siteId | name | ... |
   |---|---|---|---|
   | tut_gallery | egyptian_museum | Tutankhamun Gallery | ... |
   | mummy_room | egyptian_museum | Royal Mummy Room | ... |

3. **Cards tab**: Add story cards for each sub-location:
   | id | subLocationId | order | type | content |
   |---|---|---|---|---|
   | tut_g_1 | tut_gallery | 1 | intro | Welcome to the most famous... |
   | tut_g_2 | tut_gallery | 2 | story | The golden mask weighs... |

4. **Tips tab**: Add visitor tips
5. **ArabicPhrases tab**: Add useful phrases

---

## File Locations

```
ContentManagement/
├── GOOGLE_SHEETS_TEMPLATE.md   (Full documentation)
├── QUICK_START.md              (This file)
└── data/
    ├── 1_sites.csv             (5 sites)
    ├── 2_sublocations.csv      (8 sub-locations)
    ├── 3_cards.csv             (32 story cards)
    ├── 4_tips.csv              (16 tips)
    └── 5_arabicphrases.csv     (11 phrases)
```

---

## Current Content Summary

| Sheet | Records |
|-------|---------|
| Sites | 5 |
| SubLocations | 8 |
| Cards | 32 |
| Tips | 16 |
| ArabicPhrases | 11 |

**Sites included:**
1. Pyramids of Giza (4 sub-locations, 17 cards)
2. Luxor Temple (1 sub-location, 3 cards)
3. Valley of the Kings (1 sub-location, 4 cards)
4. Karnak Temple Complex (1 sub-location, 3 cards)
5. Abu Simbel (1 sub-location, 4 cards)
