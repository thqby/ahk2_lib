# AutoHotkey v2 Training Database - Usage Examples

Practical examples of how to use the training database tools.

## Table of Contents

1. [Basic Scraping](#basic-scraping)
2. [Advanced Scraping](#advanced-scraping)
3. [Documentation Generation](#documentation-generation)
4. [Custom Categorization](#custom-categorization)
5. [Filtering and Searching](#filtering-and-searching)
6. [Integration Workflows](#integration-workflows)

---

## Basic Scraping

### Example 1: Scrape Current Directory

```bash
# Scrape all .ahk files in current directory and subdirectories
python3 Training/ahk_scraper.py . \
    --training-dir ./Training \
    --recursive \
    --copy
```

### Example 2: Scrape Specific Directory

```bash
# Scrape a specific source directory
python3 Training/ahk_scraper.py /path/to/my/ahk/scripts \
    --training-dir ./Training \
    --recursive \
    --copy
```

### Example 3: Move Instead of Copy

```bash
# Move files instead of copying (use with caution!)
python3 Training/ahk_scraper.py /path/to/source \
    --training-dir ./Training \
    --recursive
```

### Example 4: Non-Recursive Scraping

```bash
# Only scrape the top-level directory
python3 Training/ahk_scraper.py /path/to/source \
    --training-dir ./Training \
    --recursive=false \
    --copy
```

---

## Advanced Scraping

### Example 5: Generate Full Documentation

```bash
# Scrape with documentation and index generation
python3 Training/ahk_scraper.py /path/to/source \
    --training-dir ./Training \
    --recursive \
    --copy \
    --generate-docs \
    --generate-index
```

### Example 6: Custom File Pattern

```bash
# Scrape only files matching a specific pattern
python3 Training/ahk_scraper.py /path/to/source \
    --training-dir ./Training \
    --pattern "GUI_*.ahk" \
    --recursive \
    --copy
```

### Example 7: Scrape Multiple Patterns

```bash
# Scrape GUI scripts
python3 Training/ahk_scraper.py /path/to/source \
    --pattern "GUI_*.ahk" \
    --copy

# Scrape Data scripts
python3 Training/ahk_scraper.py /path/to/source \
    --pattern "Data_*.ahk" \
    --copy

# Scrape Utility scripts
python3 Training/ahk_scraper.py /path/to/source \
    --pattern "Util_*.ahk" \
    --copy
```

---

## Documentation Generation

### Example 8: Generate All Documentation

```bash
# Generate comprehensive documentation
python3 Training/pattern_documenter.py \
    --training-dir ./Training \
    --config ./Training/pattern_config.json \
    --output-dir ./Training
```

### Example 9: Custom Output Directory

```bash
# Generate docs to a different directory
python3 Training/pattern_documenter.py \
    --training-dir ./Training \
    --output-dir ./docs
```

### Example 10: Regenerate After Adding Scripts

```bash
# 1. Add new scripts
python3 Training/ahk_scraper.py /path/to/new/scripts --copy

# 2. Regenerate documentation
python3 Training/pattern_documenter.py
```

---

## Custom Categorization

### Example 11: Modify Tier Thresholds

Edit `Training/pattern_config.json`:

```json
{
  "tier_definitions": {
    "Tier1_Beginner": {
      "complexity_range": [0, 25]  // Changed from [0, 30]
    },
    "Tier2_Intermediate": {
      "complexity_range": [26, 65]  // Changed from [31, 60]
    },
    "Tier3_Advanced": {
      "complexity_range": [66, 100]  // Changed from [61, 100]
    }
  }
}
```

Then re-run:
```bash
python3 Training/ahk_scraper.py /path/to/source --copy
```

### Example 12: Add Custom Keywords

Edit `Training/pattern_config.json`:

```json
{
  "categories": {
    "GUI_Applications": {
      "keywords": [
        "gui", "window", "button",
        "mycustomgui", "myapp"  // Add your keywords
      ]
    }
  }
}
```

### Example 13: Add Custom Concept

Edit `Training/pattern_config.json`:

```json
{
  "concept_mappings": {
    "My Custom Pattern": {
      "patterns": ["MyPattern()", "CustomFunc()"],
      "tier": 2,
      "category": "Utility_Libraries"
    }
  }
}
```

---

## Filtering and Searching

### Example 14: Find All GUI Scripts

```bash
# Find all GUI scripts across all tiers
find Training/GUI_Applications -name "*.ahk"
```

### Example 15: Find Beginner Scripts Only

```bash
# Find all Tier 1 scripts
find Training -path "*/Tier1_Beginner/*.ahk"
```

### Example 16: Find Scripts by Concept

```bash
# Search metadata for specific concept
grep -r "Object-Oriented Programming" Training --include="*.json"
```

### Example 17: Find High Complexity Scripts

```bash
# Find scripts with complexity > 70
find Training -name "*.json" -exec sh -c '
  if [ $(jq ".complexity_score" "$1") -gt 70 ]; then
    echo "$1: $(jq ".complexity_score" "$1")"
  fi
' _ {} \;
```

### Example 18: Find Scripts with COM

```bash
# Find all scripts using COM
find Training -name "*.json" -exec sh -c '
  if [ $(jq ".has_com" "$1") = "true" ]; then
    echo "$1"
  fi
' _ {} \;
```

### Example 19: List All Concepts Used

```bash
# Extract all unique concepts
find Training -name "*.json" -exec jq -r '.concepts[]' {} \; | sort -u
```

---

## Integration Workflows

### Example 20: Complete Setup Workflow

```bash
#!/bin/bash
# Complete setup from scratch

# 1. Create structure
mkdir -p Training/{GUI_Applications,Data_Structures,Utility_Libraries}/{Tier1_Beginner,Tier2_Intermediate,Tier3_Advanced}

# 2. Scrape existing scripts
python3 Training/ahk_scraper.py . \
    --training-dir ./Training \
    --recursive \
    --copy \
    --generate-docs \
    --generate-index

# 3. Generate comprehensive docs
python3 Training/pattern_documenter.py

# 4. Display summary
echo "Setup complete!"
cat Training/STATISTICS.md
```

### Example 21: Update Workflow

```bash
#!/bin/bash
# Update training database with new scripts

# 1. Scrape new scripts
python3 Training/ahk_scraper.py /path/to/new/scripts \
    --training-dir ./Training \
    --copy

# 2. Regenerate docs
python3 Training/pattern_documenter.py

# 3. Commit changes (if using git)
git add Training/
git commit -m "Update training database with new scripts"
```

### Example 22: Export Workflow

```bash
#!/bin/bash
# Export training database for distribution

# 1. Create export directory
mkdir -p ahk_training_export

# 2. Copy organized scripts
cp -r Training/* ahk_training_export/

# 3. Create archive
tar -czf ahk_training_database.tar.gz ahk_training_export/

# 4. Cleanup
rm -rf ahk_training_export/

echo "Export created: ahk_training_database.tar.gz"
```

### Example 23: Quality Check Workflow

```bash
#!/bin/bash
# Check quality of categorized scripts

echo "Checking script quality..."

# Count scripts by tier
echo -e "\nScripts by Tier:"
echo "Tier 1: $(find Training -path "*/Tier1_Beginner/*.ahk" | wc -l)"
echo "Tier 2: $(find Training -path "*/Tier2_Intermediate/*.ahk" | wc -l)"
echo "Tier 3: $(find Training -path "*/Tier3_Advanced/*.ahk" | wc -l)"

# Find scripts without documentation
echo -e "\nScripts without README:"
find Training -name "*.ahk" | while read script; do
    readme="${script%.ahk}_README.md"
    if [ ! -f "$readme" ]; then
        echo "Missing: $readme"
    fi
done

# Find scripts with low complexity in advanced tier
echo -e "\nPotentially miscategorized (Advanced tier, low complexity):"
find Training -path "*/Tier3_Advanced/*.json" -exec sh -c '
  if [ $(jq ".complexity_score" "$1") -lt 50 ]; then
    echo "$1: Complexity $(jq ".complexity_score" "$1")"
  fi
' _ {} \;
```

### Example 24: Learning Progress Tracker

```bash
#!/bin/bash
# Track learning progress

# Create progress directory
mkdir -p ~/.ahk_training_progress

# Mark script as completed
mark_complete() {
    echo "$(date): $1" >> ~/.ahk_training_progress/completed.log
}

# Usage
mark_complete "GUI_001_SimpleButton.ahk"

# View progress
echo "Scripts completed: $(wc -l < ~/.ahk_training_progress/completed.log)"
```

### Example 25: Generate Custom Learning Path

```python
#!/usr/bin/env python3
# custom_learning_path.py
import json
from pathlib import Path

def generate_custom_path(focus_concept):
    """Generate learning path for specific concept"""
    scripts = []

    # Find all scripts with the concept
    for json_file in Path('Training').rglob('*.json'):
        with open(json_file) as f:
            metadata = json.load(f)
            if focus_concept in metadata.get('concepts', []):
                scripts.append(metadata)

    # Sort by complexity
    scripts.sort(key=lambda s: s['complexity_score'])

    print(f"Learning Path for: {focus_concept}\n")
    for i, script in enumerate(scripts, 1):
        print(f"{i}. {script['filename']} (Complexity: {script['complexity_score']})")
        print(f"   Category: {script['category']} / {script['tier']}\n")

# Usage
if __name__ == '__main__':
    import sys
    concept = sys.argv[1] if len(sys.argv) > 1 else "GUI Creation"
    generate_custom_path(concept)
```

Usage:
```bash
python3 custom_learning_path.py "Object-Oriented Programming"
```

---

## Python API Usage

### Example 26: Programmatic Access

```python
from pathlib import Path
import sys
sys.path.append('Training')

from ahk_scraper import AHKScriptAnalyzer, ScriptScraper

# Analyze a single script
analyzer = AHKScriptAnalyzer()
metadata = analyzer.analyze_script(Path('my_script.ahk'))

print(f"Category: {metadata.category}")
print(f"Tier: {metadata.tier}")
print(f"Complexity: {metadata.complexity_score}")
print(f"Concepts: {', '.join(metadata.concepts)}")
```

### Example 27: Batch Analysis

```python
from pathlib import Path
from ahk_scraper import AHKScriptAnalyzer

analyzer = AHKScriptAnalyzer()

# Analyze multiple scripts
scripts = Path('.').glob('*.ahk')
for script in scripts:
    try:
        metadata = analyzer.analyze_script(script)
        print(f"{script.name}: Tier {metadata.tier}, Complexity {metadata.complexity_score}")
    except Exception as e:
        print(f"Error analyzing {script.name}: {e}")
```

---

## Tips and Tricks

### Tip 1: Preview Before Organizing

Run the scraper with `--copy` first to preview categorization before committing to moving files.

### Tip 2: Backup Before Scraping

```bash
# Create backup
tar -czf backup_$(date +%Y%m%d).tar.gz Training/

# Scrape
python3 Training/ahk_scraper.py /path/to/source
```

### Tip 3: Incremental Updates

Only scrape new directories to avoid re-processing:

```bash
python3 Training/ahk_scraper.py /path/to/new/scripts/only \
    --copy \
    --generate-docs
```

### Tip 4: Version Control

```bash
# Track changes with git
git add Training/
git commit -m "Added $(find Training -name "*.ahk" -mtime -1 | wc -l) new scripts"
```

### Tip 5: Search Optimization

Create index for faster searching:

```bash
# Create searchable index
find Training -name "*.ahk" > training_index.txt
find Training -name "*.json" -exec jq -r '.concepts[]' {} \; | sort -u > concepts_index.txt
```

---

## Troubleshooting Examples

### Issue: Scripts Not Found

```bash
# Debug: Show what would be found
python3 -c "
from pathlib import Path
scripts = list(Path('/path/to/source').rglob('*.ahk'))
print(f'Found {len(scripts)} scripts')
for s in scripts[:10]:
    print(f'  {s}')
"
```

### Issue: Wrong Categorization

```bash
# Check specific script metadata
python3 -c "
from pathlib import Path
import json

script = 'Training/GUI_Applications/Tier1_Beginner/MyScript.json'
with open(script) as f:
    meta = json.load(f)
    print(json.dumps(meta, indent=2))
"
```

### Issue: Missing Dependencies

```bash
# Check Python dependencies
python3 -c "import json, pathlib, re, shutil; print('All dependencies OK')"
```

---

For more examples and use cases, see the main [README.md](README.md) and [LEARNING_PATH.md](LEARNING_PATH.md).
