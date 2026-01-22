#!/bin/bash

# ============================================================
# Unlock Egypt Content Update Script
# Double-click this file to update app content from Google Sheets
# ============================================================

# Configuration - Change this URL if you use a different spreadsheet
SPREADSHEET_ID="17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs"
# Full URL: https://docs.google.com/spreadsheets/d/17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs/edit
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/ContentManagement/data"
CONTENT_DIR="$SCRIPT_DIR/content"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "============================================================"
echo "       Unlock Egypt Content Update"
echo "============================================================"
echo ""

# Change to project directory
cd "$SCRIPT_DIR"

# Step 1: Download CSV files from Google Sheets
echo -e "${YELLOW}Step 1: Downloading from Google Sheets...${NC}"

# Sheet GIDs - Update these if your sheet structure changes
# To find GID: click on each tab, look at URL for #gid=NUMBER
declare -A SHEETS
SHEETS["1_sites.csv"]=0
SHEETS["2_sublocations.csv"]=1
SHEETS["3_cards.csv"]=2
SHEETS["4_tips.csv"]=3
SHEETS["5_arabicphrases.csv"]=4

# Create data directory if needed
mkdir -p "$DATA_DIR"

# Download each sheet
DOWNLOAD_SUCCESS=true
for filename in "${!SHEETS[@]}"; do
    gid="${SHEETS[$filename]}"
    url="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/export?format=csv&gid=$gid"

    echo "  Downloading $filename..."

    if curl -sL "$url" -o "$DATA_DIR/$filename"; then
        # Check if file has content (not an error page)
        if head -1 "$DATA_DIR/$filename" | grep -q "<!DOCTYPE"; then
            echo -e "  ${RED}✗ Failed - Sheet may not be shared publicly${NC}"
            DOWNLOAD_SUCCESS=false
        else
            echo -e "  ${GREEN}✓ Downloaded${NC}"
        fi
    else
        echo -e "  ${RED}✗ Download failed${NC}"
        DOWNLOAD_SUCCESS=false
    fi
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo ""
    echo -e "${RED}Some downloads failed!${NC}"
    echo "Make sure your Google Sheet is shared:"
    echo "1. Open the sheet"
    echo "2. Click 'Share' button"
    echo "3. Change to 'Anyone with the link can view'"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""

# Step 2: Convert to JSON
echo -e "${YELLOW}Step 2: Converting to JSON...${NC}"

cd "$SCRIPT_DIR/ContentManagement"

if python3 sync_content.py; then
    echo -e "${GREEN}✓ JSON generated${NC}"
else
    echo -e "${RED}✗ Conversion failed${NC}"
    read -p "Press Enter to exit..."
    exit 1
fi

echo ""

# Step 3: Commit and push to GitHub
echo -e "${YELLOW}Step 3: Pushing to GitHub...${NC}"

cd "$SCRIPT_DIR"

# Check if there are changes
if git diff --quiet content/unlock_egypt_content.json Resources/unlock_egypt_content.json 2>/dev/null; then
    echo -e "${YELLOW}No content changes detected.${NC}"
else
    git add content/unlock_egypt_content.json
    git add Resources/unlock_egypt_content.json
    git add ContentManagement/data/*.csv

    TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
    git commit -m "Update content - $TIMESTAMP"

    if git push origin main; then
        echo -e "${GREEN}✓ Pushed to GitHub${NC}"
    else
        echo -e "${RED}✗ Push failed - check your git credentials${NC}"
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

echo ""
echo "============================================================"
echo -e "${GREEN}✓ Content updated successfully!${NC}"
echo "============================================================"
echo ""
echo "The app will fetch the new content automatically."
echo "Raw URL: https://raw.githubusercontent.com/Naareman/UnlockEgypt/main/content/unlock_egypt_content.json"
echo ""
read -p "Press Enter to close..."
