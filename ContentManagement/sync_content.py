#!/usr/bin/env python3
"""
Unlock Egypt Content Sync Script

This script fetches content from Google Sheets and converts it to JSON
format that the iOS app can consume.

Usage:
    python sync_content.py

The script will:
1. Fetch all sheets from the Google Spreadsheet
2. VALIDATE all data for structural issues
3. Convert to the app's JSON structure
4. Save to ../content/unlock_egypt_content.json
"""

import csv
import json
import urllib.request
import urllib.error
import os
import sys
from datetime import datetime
from typing import List, Tuple

# =============================================================================
# VALIDATION CONFIGURATION
# =============================================================================

VALID_ERAS = [
    "Pre-Dynastic", "Old Kingdom", "Middle Kingdom", "New Kingdom",
    "Late Period", "Ptolemaic", "Roman", "Islamic", "Modern"
]

VALID_TOURISM_TYPES = [
    "Pharaonic", "Greco-Roman", "Coptic", "Islamic", "Modern"
]

VALID_PLACE_TYPES = [
    "Pyramid", "Temple", "Tomb", "Museum", "Mosque",
    "Church", "Fortress", "Market", "Monument", "Ruins"
]

VALID_CITIES = [
    "Cairo", "Giza", "Luxor", "Aswan", "Alexandria",
    "Sinai", "Fayoum", "Dahab", "Hurghada", "Sharm El Sheikh"
]

VALID_CARD_TYPES = ["intro", "story", "fact", "quiz", "image"]

# Egypt geographic bounds (with some padding for edge cases)
EGYPT_LAT_MIN = 21.0
EGYPT_LAT_MAX = 32.0
EGYPT_LON_MIN = 24.0
EGYPT_LON_MAX = 37.0

# Content length limits
MAX_SHORT_DESCRIPTION_LENGTH = 500
MAX_CARD_CONTENT_LENGTH = 2000
MAX_TIP_LENGTH = 500

# Arabic character range (basic Arabic block)
ARABIC_CHAR_RANGES = [
    (0x0600, 0x06FF),  # Arabic
    (0x0750, 0x077F),  # Arabic Supplement
    (0x08A0, 0x08FF),  # Arabic Extended-A
    (0xFB50, 0xFDFF),  # Arabic Presentation Forms-A
    (0xFE70, 0xFEFF),  # Arabic Presentation Forms-B
]


def contains_arabic(text: str) -> bool:
    """Check if text contains at least one Arabic character"""
    for char in text:
        code = ord(char)
        for start, end in ARABIC_CHAR_RANGES:
            if start <= code <= end:
                return True
    return False


def is_valid_url(url: str) -> bool:
    """Basic URL validation"""
    if not url:
        return True  # Empty is OK (optional field)
    url = url.strip().lower()
    return url.startswith(('http://', 'https://')) or url.endswith(('.jpg', '.jpeg', '.png', '.webp', '.gif'))


def check_url_exists(url: str, timeout: int = 5) -> Tuple[bool, str]:
    """
    Check if a URL is accessible.
    Returns (success, error_message)
    """
    if not url or not url.strip():
        return True, ""

    url = url.strip()
    if not url.startswith(('http://', 'https://')):
        return True, ""  # Skip non-URL image names (local assets)

    try:
        req = urllib.request.Request(url, method='HEAD', headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=timeout) as response:
            if response.status == 200:
                return True, ""
            else:
                return False, f"HTTP {response.status}"
    except urllib.error.HTTPError as e:
        return False, f"HTTP {e.code}"
    except urllib.error.URLError as e:
        return False, f"Connection failed: {str(e.reason)[:30]}"
    except Exception as e:
        return False, f"Error: {str(e)[:30]}"


# Minimum content lengths for meaningful content
MIN_CONTENT_LENGTH = 10
MIN_DESCRIPTION_LENGTH = 10  # Lowered to allow short but valid descriptions


class ValidationError:
    """Represents a single validation error"""
    def __init__(self, sheet: str, row: int, field: str, message: str):
        self.sheet = sheet
        self.row = row  # 1-based row number (including header)
        self.field = field
        self.message = message

    def __str__(self):
        return f"[{self.sheet}] Row {self.row}, '{self.field}': {self.message}"


def validate_all_sheets(sheets_data: dict) -> List[ValidationError]:
    """
    Validate all sheets for structural and data integrity issues.
    Returns a list of all validation errors found.
    """
    errors = []

    # First, collect all valid IDs for foreign key validation
    site_ids = set()
    sublocation_ids = set()

    sites = sheets_data.get("Sites", [])
    sublocations = sheets_data.get("SubLocations", [])
    cards = sheets_data.get("Cards", [])
    tips = sheets_data.get("Tips", [])
    phrases = sheets_data.get("ArabicPhrases", [])

    # ==========================================================================
    # VALIDATE SITES SHEET
    # ==========================================================================
    print("   Validating Sites...")
    for idx, site in enumerate(sites):
        row_num = idx + 2  # +2 because idx is 0-based and row 1 is header

        # Required fields
        if not site.get("id", "").strip():
            errors.append(ValidationError("Sites", row_num, "id", "Missing required field"))
        else:
            site_id = site.get("id", "").strip()
            if site_id in site_ids:
                errors.append(ValidationError("Sites", row_num, "id", f"Duplicate site ID: '{site_id}'"))
            site_ids.add(site_id)

        if not site.get("name", "").strip():
            errors.append(ValidationError("Sites", row_num, "name", "Missing required field"))

        arabic_name = site.get("arabicName", "").strip()
        if not arabic_name:
            errors.append(ValidationError("Sites", row_num, "arabicName", "Missing required field"))
        elif not contains_arabic(arabic_name):
            errors.append(ValidationError("Sites", row_num, "arabicName",
                f"Should contain Arabic characters: '{arabic_name}'"))

        # Validate era
        era = site.get("era", "").strip()
        if not era:
            errors.append(ValidationError("Sites", row_num, "era", "Missing required field"))
        elif era not in VALID_ERAS:
            errors.append(ValidationError("Sites", row_num, "era",
                f"Invalid value '{era}'. Must be one of: {', '.join(VALID_ERAS)}"))

        # Validate tourismType
        tourism = site.get("tourismType", "").strip()
        if not tourism:
            errors.append(ValidationError("Sites", row_num, "tourismType", "Missing required field"))
        elif tourism not in VALID_TOURISM_TYPES:
            errors.append(ValidationError("Sites", row_num, "tourismType",
                f"Invalid value '{tourism}'. Must be one of: {', '.join(VALID_TOURISM_TYPES)}"))

        # Validate placeType
        place = site.get("placeType", "").strip()
        if not place:
            errors.append(ValidationError("Sites", row_num, "placeType", "Missing required field"))
        elif place not in VALID_PLACE_TYPES:
            errors.append(ValidationError("Sites", row_num, "placeType",
                f"Invalid value '{place}'. Must be one of: {', '.join(VALID_PLACE_TYPES)}"))

        # Validate city
        city = site.get("city", "").strip()
        if not city:
            errors.append(ValidationError("Sites", row_num, "city", "Missing required field"))
        elif city not in VALID_CITIES:
            errors.append(ValidationError("Sites", row_num, "city",
                f"Invalid value '{city}'. Must be one of: {', '.join(VALID_CITIES)}"))

        # Validate coordinates
        lat_str = site.get("latitude", "").strip()
        lon_str = site.get("longitude", "").strip()

        lat_valid = False
        lon_valid = False
        lat = 0
        lon = 0

        if not lat_str:
            errors.append(ValidationError("Sites", row_num, "latitude", "Missing required field"))
        else:
            try:
                lat = float(lat_str)
                lat_valid = True
                if lat < -90 or lat > 90:
                    errors.append(ValidationError("Sites", row_num, "latitude",
                        f"Invalid latitude {lat}. Must be between -90 and 90"))
                    lat_valid = False
            except ValueError:
                errors.append(ValidationError("Sites", row_num, "latitude",
                    f"Invalid number format: '{lat_str}'"))

        if not lon_str:
            errors.append(ValidationError("Sites", row_num, "longitude", "Missing required field"))
        else:
            try:
                lon = float(lon_str)
                lon_valid = True
                if lon < -180 or lon > 180:
                    errors.append(ValidationError("Sites", row_num, "longitude",
                        f"Invalid longitude {lon}. Must be between -180 and 180"))
                    lon_valid = False
            except ValueError:
                errors.append(ValidationError("Sites", row_num, "longitude",
                    f"Invalid number format: '{lon_str}'"))

        # Check if coordinates are within Egypt (catches copy/paste errors)
        if lat_valid and lon_valid:
            if not (EGYPT_LAT_MIN <= lat <= EGYPT_LAT_MAX and EGYPT_LON_MIN <= lon <= EGYPT_LON_MAX):
                errors.append(ValidationError("Sites", row_num, "coordinates",
                    f"Location ({lat}, {lon}) is outside Egypt. Expected lat {EGYPT_LAT_MIN}-{EGYPT_LAT_MAX}, lon {EGYPT_LON_MIN}-{EGYPT_LON_MAX}"))

        # Validate shortDescription
        short_desc = site.get("shortDescription", "").strip()
        if not short_desc:
            errors.append(ValidationError("Sites", row_num, "shortDescription", "Missing required field"))
        elif len(short_desc) > MAX_SHORT_DESCRIPTION_LENGTH:
            errors.append(ValidationError("Sites", row_num, "shortDescription",
                f"Too long ({len(short_desc)} chars). Max {MAX_SHORT_DESCRIPTION_LENGTH} chars"))

        # Validate image names format
        image_names = site.get("imageNames", "").strip()
        if image_names:
            for img_name in image_names.split(","):
                img_name = img_name.strip()
                if img_name and not is_valid_url(img_name):
                    if " " in img_name:
                        errors.append(ValidationError("Sites", row_num, "imageNames",
                            f"Image name contains spaces: '{img_name}'"))

    # ==========================================================================
    # VALIDATE SUBLOCATIONS SHEET
    # ==========================================================================
    print("   Validating SubLocations...")
    for idx, subloc in enumerate(sublocations):
        row_num = idx + 2

        # Required fields
        if not subloc.get("id", "").strip():
            errors.append(ValidationError("SubLocations", row_num, "id", "Missing required field"))
        else:
            subloc_id = subloc.get("id", "").strip()
            if subloc_id in sublocation_ids:
                errors.append(ValidationError("SubLocations", row_num, "id",
                    f"Duplicate sublocation ID: '{subloc_id}'"))
            sublocation_ids.add(subloc_id)

        if not subloc.get("name", "").strip():
            errors.append(ValidationError("SubLocations", row_num, "name", "Missing required field"))

        # Validate foreign key to Sites
        site_id = subloc.get("siteId", "").strip()
        if not site_id:
            errors.append(ValidationError("SubLocations", row_num, "siteId", "Missing required field"))
        elif site_id not in site_ids:
            errors.append(ValidationError("SubLocations", row_num, "siteId",
                f"References non-existent site: '{site_id}'"))

    # ==========================================================================
    # VALIDATE CARDS SHEET
    # ==========================================================================
    print("   Validating Cards...")
    card_ids = set()
    for idx, card in enumerate(cards):
        row_num = idx + 2

        # Required fields
        card_id = card.get("id", "").strip()
        if not card_id:
            errors.append(ValidationError("Cards", row_num, "id", "Missing required field"))
        else:
            if card_id in card_ids:
                errors.append(ValidationError("Cards", row_num, "id",
                    f"Duplicate card ID: '{card_id}'"))
            card_ids.add(card_id)

        # Validate foreign key to SubLocations
        subloc_id = card.get("subLocationId", "").strip()
        if not subloc_id:
            errors.append(ValidationError("Cards", row_num, "subLocationId", "Missing required field"))
        elif subloc_id not in sublocation_ids:
            errors.append(ValidationError("Cards", row_num, "subLocationId",
                f"References non-existent sublocation: '{subloc_id}'"))

        # Validate card type
        card_type = card.get("type", "").strip().lower()
        if card_type and card_type not in VALID_CARD_TYPES:
            errors.append(ValidationError("Cards", row_num, "type",
                f"Invalid value '{card_type}'. Must be one of: {', '.join(VALID_CARD_TYPES)}"))

        # Validate order
        order_str = card.get("order", "").strip()
        if order_str:
            try:
                order = int(order_str)
                if order < 0:
                    errors.append(ValidationError("Cards", row_num, "order",
                        f"Order must be a positive number, got: {order}"))
            except ValueError:
                errors.append(ValidationError("Cards", row_num, "order",
                    f"Invalid number format: '{order_str}'"))

        # Validate quiz fields if quiz question exists
        quiz_question = card.get("quizQuestion", "").strip()
        if quiz_question:
            # Check all quiz options are present
            options = [
                card.get("quizOption1", "").strip(),
                card.get("quizOption2", "").strip(),
                card.get("quizOption3", "").strip(),
                card.get("quizOption4", "").strip()
            ]

            empty_options = [i+1 for i, opt in enumerate(options) if not opt]
            if empty_options:
                errors.append(ValidationError("Cards", row_num, "quizOptions",
                    f"Quiz has question but missing options: {empty_options}"))

            # Check correct answer
            correct_str = card.get("quizCorrectAnswer", "").strip()
            if not correct_str:
                errors.append(ValidationError("Cards", row_num, "quizCorrectAnswer",
                    "Quiz has question but missing correct answer"))
            else:
                try:
                    correct = int(correct_str)
                    if correct < 1 or correct > 4:
                        errors.append(ValidationError("Cards", row_num, "quizCorrectAnswer",
                            f"Must be 1-4, got: {correct}"))
                except ValueError:
                    errors.append(ValidationError("Cards", row_num, "quizCorrectAnswer",
                        f"Invalid number format: '{correct_str}'"))

            # Check explanation
            if not card.get("quizExplanation", "").strip():
                errors.append(ValidationError("Cards", row_num, "quizExplanation",
                    "Quiz has question but missing explanation"))

        # Validate content length
        content = card.get("content", "").strip()
        if content and len(content) > MAX_CARD_CONTENT_LENGTH:
            errors.append(ValidationError("Cards", row_num, "content",
                f"Too long ({len(content)} chars). Max {MAX_CARD_CONTENT_LENGTH} chars"))

        # Validate image URL format
        image_url = card.get("imageUrl", "").strip()
        if image_url and not is_valid_url(image_url):
            errors.append(ValidationError("Cards", row_num, "imageUrl",
                f"Invalid URL format: '{image_url[:50]}...'"))

        # Check for empty content on story/fact cards (should have something)
        fun_fact = card.get("funFact", "").strip()
        if card_type == "story" and not content and not image_url:
            errors.append(ValidationError("Cards", row_num, "content",
                f"Story card should have content or image"))
        if card_type == "fact" and not fun_fact and not content:
            errors.append(ValidationError("Cards", row_num, "funFact",
                f"Fact card should have funFact or content"))

    # Check card order consistency per sublocation
    cards_by_subloc = {}
    for idx, card in enumerate(cards):
        subloc_id = card.get("subLocationId", "").strip()
        if subloc_id:
            if subloc_id not in cards_by_subloc:
                cards_by_subloc[subloc_id] = []
            order_str = card.get("order", "0").strip()
            try:
                order = int(order_str) if order_str else 0
                cards_by_subloc[subloc_id].append((order, idx + 2))
            except ValueError:
                pass

    for subloc_id, order_list in cards_by_subloc.items():
        orders = [o[0] for o in order_list]
        if len(orders) != len(set(orders)):
            # Find duplicates
            seen = set()
            for order, row_num in order_list:
                if order in seen:
                    errors.append(ValidationError("Cards", row_num, "order",
                        f"Duplicate order {order} in sublocation '{subloc_id}'"))
                seen.add(order)

    # ==========================================================================
    # VALIDATE TIPS SHEET
    # ==========================================================================
    print("   Validating Tips...")
    for idx, tip in enumerate(tips):
        row_num = idx + 2

        # Validate foreign key to Sites
        site_id = tip.get("siteId", "").strip()
        if not site_id:
            errors.append(ValidationError("Tips", row_num, "siteId", "Missing required field"))
        elif site_id not in site_ids:
            errors.append(ValidationError("Tips", row_num, "siteId",
                f"References non-existent site: '{site_id}'"))

        tip_text = tip.get("tip", "").strip()
        if not tip_text:
            errors.append(ValidationError("Tips", row_num, "tip", "Missing required field"))
        elif len(tip_text) > MAX_TIP_LENGTH:
            errors.append(ValidationError("Tips", row_num, "tip",
                f"Too long ({len(tip_text)} chars). Max {MAX_TIP_LENGTH} chars"))

    # ==========================================================================
    # VALIDATE ARABIC PHRASES SHEET
    # ==========================================================================
    print("   Validating ArabicPhrases...")
    for idx, phrase in enumerate(phrases):
        row_num = idx + 2

        # Validate foreign key to Sites
        site_id = phrase.get("siteId", "").strip()
        if not site_id:
            errors.append(ValidationError("ArabicPhrases", row_num, "siteId", "Missing required field"))
        elif site_id not in site_ids:
            errors.append(ValidationError("ArabicPhrases", row_num, "siteId",
                f"References non-existent site: '{site_id}'"))

        if not phrase.get("english", "").strip():
            errors.append(ValidationError("ArabicPhrases", row_num, "english", "Missing required field"))

        arabic_text = phrase.get("arabic", "").strip()
        if not arabic_text:
            errors.append(ValidationError("ArabicPhrases", row_num, "arabic", "Missing required field"))
        elif not contains_arabic(arabic_text):
            errors.append(ValidationError("ArabicPhrases", row_num, "arabic",
                f"Should contain Arabic characters: '{arabic_text}'"))

        if not phrase.get("pronunciation", "").strip():
            errors.append(ValidationError("ArabicPhrases", row_num, "pronunciation", "Missing required field"))

    # ==========================================================================
    # CROSS-SHEET VALIDATION (Orphan checks)
    # ==========================================================================
    print("   Checking for orphaned records...")

    # Check for sites with no sublocations
    sites_with_sublocations = set(s.get("siteId", "").strip() for s in sublocations)
    for site_id in site_ids:
        if site_id not in sites_with_sublocations:
            # This is a warning, not an error - some sites might intentionally have no sublocations
            pass  # Uncomment below to make it an error:
            # errors.append(ValidationError("Sites", "N/A", "subLocations",
            #     f"Site '{site_id}' has no sublocations"))

    # Check for sublocations with no cards
    sublocs_with_cards = set(c.get("subLocationId", "").strip() for c in cards)
    for idx, subloc in enumerate(sublocations):
        subloc_id = subloc.get("id", "").strip()
        if subloc_id and subloc_id not in sublocs_with_cards:
            errors.append(ValidationError("SubLocations", idx + 2, "storyCards",
                f"Sublocation '{subloc_id}' has no story cards - users won't be able to earn Knowledge Key"))

    # ==========================================================================
    # URL EXISTENCE VALIDATION (only if no other errors - URLs can be slow)
    # ==========================================================================
    if not errors:
        print("   Validating URLs (this may take a moment)...")
        urls_to_check = []

        # Collect all URLs from cards
        for idx, card in enumerate(cards):
            image_url = card.get("imageUrl", "").strip()
            if image_url and image_url.startswith(('http://', 'https://')):
                urls_to_check.append(("Cards", idx + 2, "imageUrl", image_url))

        # Check URLs (with progress indicator)
        if urls_to_check:
            checked = 0
            for sheet, row, field, url in urls_to_check:
                checked += 1
                exists, error_msg = check_url_exists(url)
                if not exists:
                    errors.append(ValidationError(sheet, row, field,
                        f"URL not accessible ({error_msg}): {url[:60]}..."))
                # Show progress every 5 URLs
                if checked % 5 == 0:
                    print(f"      Checked {checked}/{len(urls_to_check)} URLs...")

            if urls_to_check:
                print(f"      Checked {len(urls_to_check)} URLs")
        else:
            print("      No external URLs to check")

    # ==========================================================================
    # CONTENT QUALITY CHECKS
    # ==========================================================================
    print("   Checking content quality...")

    # Check for very short descriptions (might be placeholder text)
    for idx, site in enumerate(sites):
        desc = site.get("shortDescription", "").strip()
        if desc and len(desc) < MIN_DESCRIPTION_LENGTH:
            errors.append(ValidationError("Sites", idx + 2, "shortDescription",
                f"Very short ({len(desc)} chars). Minimum {MIN_DESCRIPTION_LENGTH} recommended"))

    # Check for very short card content
    for idx, card in enumerate(cards):
        content = card.get("content", "").strip()
        fun_fact = card.get("funFact", "").strip()
        card_type = card.get("type", "").strip().lower()

        if card_type == "story" and content and len(content) < MIN_CONTENT_LENGTH:
            errors.append(ValidationError("Cards", idx + 2, "content",
                f"Very short ({len(content)} chars). Minimum {MIN_CONTENT_LENGTH} recommended"))

        if card_type == "fact" and fun_fact and len(fun_fact) < MIN_CONTENT_LENGTH:
            errors.append(ValidationError("Cards", idx + 2, "funFact",
                f"Very short ({len(fun_fact)} chars). Minimum {MIN_CONTENT_LENGTH} recommended"))

    # Check for duplicate content (copy/paste errors)
    seen_content = {}
    for idx, card in enumerate(cards):
        content = card.get("content", "").strip()
        if content and len(content) > 50:  # Only check substantial content
            content_key = content[:100].lower()  # Use first 100 chars as key
            if content_key in seen_content:
                prev_row = seen_content[content_key]
                errors.append(ValidationError("Cards", idx + 2, "content",
                    f"Duplicate content (same as row {prev_row})"))
            else:
                seen_content[content_key] = idx + 2

    # Check quiz answer points to non-empty option
    for idx, card in enumerate(cards):
        quiz_question = card.get("quizQuestion", "").strip()
        if quiz_question:
            correct_str = card.get("quizCorrectAnswer", "").strip()
            if correct_str:
                try:
                    correct = int(correct_str)
                    if 1 <= correct <= 4:
                        option_field = f"quizOption{correct}"
                        option_value = card.get(option_field, "").strip()
                        if not option_value:
                            errors.append(ValidationError("Cards", idx + 2, "quizCorrectAnswer",
                                f"Points to empty option {correct}"))
                except ValueError:
                    pass  # Already caught by earlier validation

    return errors


def print_validation_report(errors: List[ValidationError]) -> bool:
    """
    Print a formatted validation report.
    Returns True if validation passed (no errors), False otherwise.
    """
    if not errors:
        print("\n" + "=" * 60)
        print("✓ VALIDATION PASSED - No issues found!")
        print("=" * 60)
        return True

    # Group errors by sheet
    errors_by_sheet = {}
    for error in errors:
        if error.sheet not in errors_by_sheet:
            errors_by_sheet[error.sheet] = []
        errors_by_sheet[error.sheet].append(error)

    print("\n" + "=" * 60)
    print(f"✗ VALIDATION FAILED - {len(errors)} issue(s) found!")
    print("=" * 60)

    for sheet_name in ["Sites", "SubLocations", "Cards", "Tips", "ArabicPhrases"]:
        if sheet_name in errors_by_sheet:
            sheet_errors = errors_by_sheet[sheet_name]
            print(f"\n[{sheet_name}] - {len(sheet_errors)} issue(s):")
            print("-" * 50)
            for error in sheet_errors:
                print(f"  Row {error.row:3d} | {error.field:20s} | {error.message}")

    print("\n" + "=" * 60)
    print("Please fix the issues in Google Sheets and try again.")
    print("=" * 60 + "\n")

    return False

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
    print("=" * 60)
    print("       Unlock Egypt Content Sync")
    print("=" * 60)

    # Fetch from local CSV files (or Google Sheets when configured)
    print("\n1. Reading content from data files...")
    sheets_data = fetch_all_sheets_manually()

    print(f"   - Sites: {len(sheets_data.get('Sites', []))} records")
    print(f"   - SubLocations: {len(sheets_data.get('SubLocations', []))} records")
    print(f"   - Cards: {len(sheets_data.get('Cards', []))} records")
    print(f"   - Tips: {len(sheets_data.get('Tips', []))} records")
    print(f"   - ArabicPhrases: {len(sheets_data.get('ArabicPhrases', []))} records")

    # Check if any sheets are empty
    if not sheets_data.get('Sites'):
        print("\n✗ ERROR: Sites sheet is empty or missing!")
        print("  Make sure the CSV files exist in ContentManagement/data/")
        sys.exit(1)

    # ==========================================================================
    # VALIDATION STEP
    # ==========================================================================
    print("\n2. Validating data integrity...")
    validation_errors = validate_all_sheets(sheets_data)

    if not print_validation_report(validation_errors):
        # Validation failed - exit without generating JSON
        sys.exit(1)

    # ==========================================================================
    # CONVERSION STEP
    # ==========================================================================
    print("\n3. Converting to app JSON format...")
    app_json = convert_to_app_json(sheets_data)

    # Ensure output directories exist
    project_dir = os.path.dirname(os.path.dirname(__file__))
    content_dir = os.path.join(project_dir, 'content')
    resources_dir = os.path.join(project_dir, 'Resources')
    os.makedirs(content_dir, exist_ok=True)

    json_filename = 'unlock_egypt_content.json'
    content_path = os.path.join(content_dir, json_filename)
    resources_path = os.path.join(resources_dir, json_filename)

    print(f"\n4. Saving JSON files...")

    # Save to content folder (for GitHub)
    with open(content_path, 'w', encoding='utf-8') as f:
        json.dump(app_json, f, indent=2, ensure_ascii=False)
    print(f"   ✓ {content_path}")

    # Also copy to Resources folder (bundled with app)
    with open(resources_path, 'w', encoding='utf-8') as f:
        json.dump(app_json, f, indent=2, ensure_ascii=False)
    print(f"   ✓ {resources_path}")

    print(f"\n" + "=" * 60)
    print(f"✓ SUCCESS! Generated JSON with {len(app_json['sites'])} sites.")
    print("=" * 60)

    return app_json

if __name__ == "__main__":
    main()
