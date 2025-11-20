#!/bin/bash
#
# AutoHotkey v2 Training Database - Quick Start Script
# Automates the setup and scraping process
#

set -e

echo "======================================"
echo "AHK v2 Training Database - Quick Start"
echo "======================================"
echo ""

# Configuration
TRAINING_DIR="./Training"
SOURCE_DIR="${1:-.}"
PATTERN="*.ahk"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not found."
    exit 1
fi

echo "Source directory: $SOURCE_DIR"
echo "Training directory: $TRAINING_DIR"
echo ""

# Create directory structure
echo "[1/6] Creating directory structure..."
mkdir -p "$TRAINING_DIR"/{GUI_Applications,Data_Structures,Utility_Libraries}/{Tier1_Beginner,Tier2_Intermediate,Tier3_Advanced}
echo "  ✓ Directory structure created"

# Make Python scripts executable
echo "[2/6] Setting up Python scripts..."
chmod +x "$TRAINING_DIR"/ahk_scraper.py
chmod +x "$TRAINING_DIR"/pattern_documenter.py
echo "  ✓ Scripts configured"

# Run the scraper
echo "[3/6] Scraping and analyzing AHK scripts..."
python3 "$TRAINING_DIR/ahk_scraper.py" "$SOURCE_DIR" \
    --training-dir "$TRAINING_DIR" \
    --pattern "$PATTERN" \
    --recursive \
    --copy \
    --generate-docs \
    --generate-index

echo "  ✓ Scripts analyzed and organized"

# Generate documentation
echo "[4/6] Generating comprehensive documentation..."
python3 "$TRAINING_DIR/pattern_documenter.py" \
    --training-dir "$TRAINING_DIR" \
    --config "$TRAINING_DIR/pattern_config.json" \
    --output-dir "$TRAINING_DIR"

echo "  ✓ Documentation generated"

# Count results
echo "[5/6] Counting results..."
TOTAL_SCRIPTS=$(find "$TRAINING_DIR" -name "*.ahk" -type f | wc -l)
TOTAL_JSON=$(find "$TRAINING_DIR" -name "*.json" -type f | wc -l)
TOTAL_DOCS=$(find "$TRAINING_DIR" -name "*README.md" -type f | wc -l)

echo "  ✓ Total scripts organized: $TOTAL_SCRIPTS"
echo "  ✓ Total metadata files: $TOTAL_JSON"
echo "  ✓ Total documentation files: $TOTAL_DOCS"

# Generate summary
echo "[6/6] Generating summary..."
cat > "$TRAINING_DIR/QUICKSTART_SUMMARY.md" << EOF
# Quick Start Summary

**Date:** $(date)
**Source Directory:** $SOURCE_DIR
**Training Directory:** $TRAINING_DIR

## Results

- **Scripts Organized:** $TOTAL_SCRIPTS
- **Metadata Files:** $TOTAL_JSON
- **Documentation Files:** $TOTAL_DOCS

## Next Steps

1. Browse the organized scripts in \`$TRAINING_DIR\`
2. Read the learning path: \`$TRAINING_DIR/LEARNING_PATH.md\`
3. Explore concepts: \`$TRAINING_DIR/CONCEPTS.md\`
4. Check statistics: \`$TRAINING_DIR/STATISTICS.md\`
5. Review category-specific READMEs in each subdirectory

## Directory Structure

\`\`\`
$TRAINING_DIR/
├── GUI_Applications/
│   ├── Tier1_Beginner/
│   ├── Tier2_Intermediate/
│   └── Tier3_Advanced/
├── Data_Structures/
│   ├── Tier1_Beginner/
│   ├── Tier2_Intermediate/
│   └── Tier3_Advanced/
├── Utility_Libraries/
│   ├── Tier1_Beginner/
│   ├── Tier2_Intermediate/
│   └── Tier3_Advanced/
├── LEARNING_PATH.md
├── CONCEPTS.md
├── STATISTICS.md
├── INDEX.md
└── cross_references.json
\`\`\`

## Tools Available

- **ahk_scraper.py** - Script analyzer and organizer
- **pattern_documenter.py** - Documentation generator
- **pattern_config.json** - Configuration for categorization
- **quick_start.sh** - This automated setup script

EOF

echo "  ✓ Summary written to $TRAINING_DIR/QUICKSTART_SUMMARY.md"

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "📊 Scripts organized: $TOTAL_SCRIPTS"
echo "📁 Training directory: $TRAINING_DIR"
echo "📖 Read the learning path: $TRAINING_DIR/LEARNING_PATH.md"
echo ""
echo "Happy learning!"
