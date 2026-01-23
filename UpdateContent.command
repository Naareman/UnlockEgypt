#!/bin/bash

# ============================================================
# Unlock Egypt Content Update Script
# Double-click this file to update app content from Google Sheets
# ============================================================

# Configuration
SPREADSHEET_ID="17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs"
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

# Create data directory if needed
mkdir -p "$DATA_DIR"

# Download each sheet (using gviz format which works better)
DOWNLOAD_SUCCESS=true

download_sheet() {
    local filename=$1
    local gid=$2
    local url="https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID/gviz/tq?tqx=out:csv&gid=$gid"

    echo "  Downloading $filename..."

    if curl -sL -A "Mozilla/5.0" "$url" -o "$DATA_DIR/$filename"; then
        # Check if file has content (not an error page)
        if head -1 "$DATA_DIR/$filename" | grep -q "<!DOCTYPE"; then
            echo -e "  ${RED}✗ Failed - Sheet may not be shared publicly${NC}"
            return 1
        else
            echo -e "  ${GREEN}✓ Downloaded${NC}"
            return 0
        fi
    else
        echo -e "  ${RED}✗ Download failed${NC}"
        return 1
    fi
}

# Download all sheets (using correct GIDs from Google Sheets)
download_sheet "1_sites.csv" 79400402 || DOWNLOAD_SUCCESS=false
download_sheet "2_sublocations.csv" 1721763584 || DOWNLOAD_SUCCESS=false
download_sheet "3_cards.csv" 1780906563 || DOWNLOAD_SUCCESS=false
download_sheet "4_tips.csv" 1000130052 || DOWNLOAD_SUCCESS=false
download_sheet "5_arabicphrases.csv" 2026607677 || DOWNLOAD_SUCCESS=false

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
echo "Or rebuild in Xcode to include in the bundled app."
echo ""
read -p "Press Enter to close..."
