#!/usr/bin/env python3
"""
Unlock Egypt Content Sync Script

This script fetches content from Google Sheets and converts it to JSON
format that the iOS app can consume.

Usage:
    python sync_content.py

The script will:
1. Fetch all sheets from the Google Spreadsheet
2. Convert to the app's JSON structure
3. Save to ../content/unlock_egypt_content.json
"""

import csv
import json
import urllib.request
import os
from datetime import datetime

# Google Sheets configuration
SPREADSHEET_ID = "17ENW_6JgdmL6ulsDUMNlJugyYAVBr9b4znCIJkwkvzs"

# Sheet names and their GIDs (from your Google Sheet URL)
# You can find GID by clicking on each tab - it's in the URL after #gid=
SHEETS = {
    "Sites": 79400402,
    "SubLocations": 1721763584,
    "Cards": 1780906563,
    "Tips": 1000130052,
    "ArabicPhrases": 2026607677,
}

def get_csv_url(spreadsheet_id: str, gid: int) -> str:
    """Generate CSV export URL for a specific sheet (using gviz format which works better)"""
    return f"https://docs.google.com/spreadsheets/d/{spreadsheet_id}/gviz/tq?tqx=out:csv&gid={gid}"

def fetch_sheet_as_csv(spreadsheet_id: str, gid: int) -> list[dict]:
    """Fetch a Google Sheet tab as CSV and return as list of dicts"""
    url = get_csv_url(spreadsheet_id, gid)
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            content = response.read().decode('utf-8')
            reader = csv.DictReader(content.splitlines())
            return list(reader)
    except Exception as e:
        print(f"Error fetching sheet (gid={gid}): {e}")
        return []

def fetch_all_sheets_manually() -> dict:
    """
    Fetch sheets using the published CSV URLs.

    IMPORTANT: To make this work, you need to:
    1. In Google Sheets, go to File → Share → Publish to web
    2. Select each sheet and publish as CSV
    3. Update the GIDs below with your actual values
    """
    # For now, read from local CSV files as fallback
    data_dir = os.path.join(os.path.dirname(__file__), 'data')

    sheets_data = {}
    file_mapping = {
        "Sites": "1_sites.csv",
        "SubLocations": "2_sublocations.csv",
        "Cards": "3_cards.csv",
        "Tips": "4_tips.csv",
        "ArabicPhrases": "5_arabicphrases.csv"
    }

    for sheet_name, filename in file_mapping.items():
        filepath = os.path.join(data_dir, filename)
        if os.path.exists(filepath):
            with open(filepath, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                sheets_data[sheet_name] = list(reader)
        else:
            sheets_data[sheet_name] = []

    return sheets_data

def convert_to_app_json(sheets_data: dict) -> dict:
    """Convert the sheets data to the app's JSON structure"""

    sites_raw = sheets_data.get("Sites", [])
    sublocations_raw = sheets_data.get("SubLocations", [])
    cards_raw = sheets_data.get("Cards", [])
    tips_raw = sheets_data.get("Tips", [])
    phrases_raw = sheets_data.get("ArabicPhrases", [])

    # Build lookup maps
    tips_by_site = {}
    for tip in tips_raw:
        site_id = tip.get("siteId", "")
        if site_id not in tips_by_site:
            tips_by_site[site_id] = []
        tips_by_site[site_id].append(tip.get("tip", ""))

    phrases_by_site = {}
    for phrase in phrases_raw:
        site_id = phrase.get("siteId", "")
        if site_id not in phrases_by_site:
            phrases_by_site[site_id] = []
        phrases_by_site[site_id].append({
            "english": phrase.get("english", ""),
            "arabic": phrase.get("arabic", ""),
            "pronunciation": phrase.get("pronunciation", "")
        })

    cards_by_sublocation = {}
    for card in cards_raw:
        subloc_id = card.get("subLocationId", "")
        if subloc_id not in cards_by_sublocation:
            cards_by_sublocation[subloc_id] = []

        card_data = {
            "id": card.get("id", ""),
            "type": card.get("type", "story"),
            "imageName": card.get("imageUrl") if card.get("imageUrl") else None,
            "content": card.get("content") if card.get("content") else None,
            "funFact": card.get("funFact") if card.get("funFact") else None,
        }

        # Add quiz data if present
        if card.get("quizQuestion"):
            card_data["quizQuestion"] = {
                "id": f"q_{card.get('id', '')}",
                "question": card.get("quizQuestion", ""),
                "options": [
                    card.get("quizOption1", ""),
                    card.get("quizOption2", ""),
                    card.get("quizOption3", ""),
                    card.get("quizOption4", "")
                ],
                "correctAnswerIndex": int(card.get("quizCorrectAnswer", 1)) - 1,  # Convert 1-based to 0-based
                "explanation": card.get("quizExplanation", ""),
                "funFact": None
            }
        else:
            card_data["quizQuestion"] = None

        # Store order for sorting
        card_data["_order"] = int(card.get("order", 0) or 0)
        cards_by_sublocation[subloc_id].append(card_data)

    # Sort cards by order and remove temporary _order field
    for subloc_id in cards_by_sublocation:
        cards_by_sublocation[subloc_id].sort(key=lambda x: x.get("_order", 0))
        for card in cards_by_sublocation[subloc_id]:
            card.pop("_order", None)

    sublocations_by_site = {}
    for subloc in sublocations_raw:
        site_id = subloc.get("siteId", "")
        if site_id not in sublocations_by_site:
            sublocations_by_site[site_id] = []

        subloc_id = subloc.get("id", "")
        sublocations_by_site[site_id].append({
            "id": subloc_id,
            "name": subloc.get("name", ""),
            "arabicName": subloc.get("arabicName", ""),
            "shortDescription": subloc.get("shortDescription", ""),
            "imageName": subloc.get("imageName") if subloc.get("imageName") else None,
            "storyCards": cards_by_sublocation.get(subloc_id, [])
        })

    # Build sites
    sites = []
    for site in sites_raw:
        site_id = site.get("id", "")

        # Parse coordinates
        lat = float(site.get("latitude", 0) or 0)
        lon = float(site.get("longitude", 0) or 0)

        # Parse image names (comma-separated)
        image_names = [img.strip() for img in site.get("imageNames", "").split(",") if img.strip()]

        site_data = {
            "id": site_id,
            "name": site.get("name", ""),
            "arabicName": site.get("arabicName", ""),
            "era": convert_era(site.get("era", "")),
            "tourismType": convert_tourism_type(site.get("tourismType", "")),
            "placeType": convert_place_type(site.get("placeType", "")),
            "city": convert_city(site.get("city", "")),
            "shortDescription": site.get("shortDescription", ""),
            "coordinates": {
                "latitude": lat,
                "longitude": lon
            },
            "imageNames": image_names,
            "subLocations": sublocations_by_site.get(site_id, []),
            "visitInfo": {
                "estimatedDuration": site.get("estimatedDuration", ""),
                "bestTimeToVisit": site.get("bestTimeToVisit", ""),
                "tips": tips_by_site.get(site_id, []),
                "arabicPhrases": phrases_by_site.get(site_id, [])
            },
            "isUnlocked": True
        }
        sites.append(site_data)

    return {
        "version": "1.0",
        "lastUpdated": datetime.now().isoformat(),
        "sites": sites
    }

def convert_era(era_str: str) -> str:
    """Convert era string to enum raw value"""
    era_map = {
        "Pre-Dynastic": "Pre-Dynastic",
        "Old Kingdom": "Old Kingdom",
        "Middle Kingdom": "Middle Kingdom",
        "New Kingdom": "New Kingdom",
        "Late Period": "Late Period",
        "Ptolemaic": "Ptolemaic",
        "Roman": "Roman",
        "Islamic": "Islamic",
        "Modern": "Modern"
    }
    return era_map.get(era_str, era_str)

def convert_tourism_type(tourism_str: str) -> str:
    """Convert tourism type string to enum raw value"""
    tourism_map = {
        "Pharaonic": "Pharaonic",
        "Greco-Roman": "Greco-Roman",
        "Coptic": "Coptic",
        "Islamic": "Islamic",
        "Modern": "Modern"
    }
    return tourism_map.get(tourism_str, tourism_str)

def convert_place_type(place_str: str) -> str:
    """Convert place type string to enum raw value"""
    place_map = {
        "Pyramid": "Pyramid",
        "Temple": "Temple",
        "Tomb": "Tomb",
        "Museum": "Museum",
        "Mosque": "Mosque",
        "Church": "Church",
        "Fortress": "Fortress",
        "Market": "Market",
        "Monument": "Monument",
        "Ruins": "Ruins"
    }
    return place_map.get(place_str, place_str)

def convert_city(city_str: str) -> str:
    """Convert city string to enum raw value"""
    city_map = {
        "Cairo": "Cairo",
        "Giza": "Giza",
        "Luxor": "Luxor",
        "Aswan": "Aswan",
        "Alexandria": "Alexandria",
        "Sinai": "Sinai",
        "Fayoum": "Fayoum",
        "Dahab": "Dahab",
        "Hurghada": "Hurghada",
        "Sharm El Sheikh": "Sharm El Sheikh"
    }
    return city_map.get(city_str, city_str)

def main():
    print("=" * 50)
    print("Unlock Egypt Content Sync")
    print("=" * 50)

    # Fetch from local CSV files (or Google Sheets when configured)
    print("\n1. Reading content from data files...")
    sheets_data = fetch_all_sheets_manually()

    print(f"   - Sites: {len(sheets_data.get('Sites', []))} records")
    print(f"   - SubLocations: {len(sheets_data.get('SubLocations', []))} records")
    print(f"   - Cards: {len(sheets_data.get('Cards', []))} records")
    print(f"   - Tips: {len(sheets_data.get('Tips', []))} records")
    print(f"   - ArabicPhrases: {len(sheets_data.get('ArabicPhrases', []))} records")

    print("\n2. Converting to app JSON format...")
    app_json = convert_to_app_json(sheets_data)

    # Ensure output directories exist
    project_dir = os.path.dirname(os.path.dirname(__file__))
    content_dir = os.path.join(project_dir, 'content')
    resources_dir = os.path.join(project_dir, 'Resources')
    os.makedirs(content_dir, exist_ok=True)

    json_filename = 'unlock_egypt_content.json'
    content_path = os.path.join(content_dir, json_filename)
    resources_path = os.path.join(resources_dir, json_filename)

    print(f"\n3. Saving JSON files...")

    # Save to content folder (for GitHub)
    with open(content_path, 'w', encoding='utf-8') as f:
        json.dump(app_json, f, indent=2, ensure_ascii=False)
    print(f"   ✓ {content_path}")

    # Also copy to Resources folder (bundled with app)
    with open(resources_path, 'w', encoding='utf-8') as f:
        json.dump(app_json, f, indent=2, ensure_ascii=False)
    print(f"   ✓ {resources_path}")

    print(f"\n✓ Done! Generated JSON with {len(app_json['sites'])} sites.")

    return app_json

if __name__ == "__main__":
    main()
