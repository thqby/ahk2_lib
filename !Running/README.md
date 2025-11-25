# AutoHotkey v2 Training Database

A comprehensive, categorized collection of AutoHotkey v2 scripts organized for progressive learning from beginner to advanced levels.

## 🎯 Overview

This training database automatically extracts, analyzes, categorizes, and documents AutoHotkey v2 scripts into a structured learning environment. Scripts are organized by:

- **Category**: GUI Applications, Data Structures, Utility Libraries
- **Difficulty Tier**: Beginner (Tier 1), Intermediate (Tier 2), Advanced (Tier 3)
- **Concepts**: Specific AHK v2 features and patterns demonstrated

## 📁 Directory Structure

```
Training/
├── GUI_Applications/           # GUI design patterns and window management
│   ├── Tier1_Beginner/        # Basic GUI controls and events
│   ├── Tier2_Intermediate/    # Complex UI components
│   └── Tier3_Advanced/        # Multi-window apps and dashboards
│
├── Data_Structures/           # Collection manipulation and data patterns
│   ├── Tier1_Beginner/        # Basic Array/Map operations
│   ├── Tier2_Intermediate/    # Advanced data transformations
│   └── Tier3_Advanced/        # Complex data structures
│
├── Utility_Libraries/         # Practical tools and design patterns
│   ├── Tier1_Beginner/        # File I/O, basic hotkeys
│   ├── Tier2_Intermediate/    # OOP patterns, event handling
│   └── Tier3_Advanced/        # COM/WinRT, design patterns
│
├── ahk_scraper.py             # Script analyzer and organizer
├── pattern_documenter.py      # Documentation generator
├── pattern_config.json        # Categorization configuration
├── quick_start.sh             # Automated setup script
│
├── README.md                  # This file
├── LEARNING_PATH.md           # Recommended learning progression
├── CONCEPTS.md                # Scripts organized by concept
├── STATISTICS.md              # Database statistics
├── INDEX.md                   # Complete script index
└── cross_references.json      # Related pattern mappings
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

```bash
cd Training
chmod +x quick_start.sh
./quick_start.sh /path/to/ahk/scripts
```

This will:
1. Create the directory structure
2. Analyze and categorize all AHK scripts
3. Generate comprehensive documentation
4. Create learning paths and concept guides

### Option 2: Manual Setup

```bash
# 1. Create directory structure
mkdir -p Training/{GUI_Applications,Data_Structures,Utility_Libraries}/{Tier1_Beginner,Tier2_Intermediate,Tier3_Advanced}

# 2. Run the scraper
python3 Training/ahk_scraper.py /path/to/scripts \
    --training-dir ./Training \
    --pattern "*.ahk" \
    --recursive \
    --copy \
    --generate-docs \
    --generate-index

# 3. Generate documentation
python3 Training/pattern_documenter.py \
    --training-dir ./Training \
    --config ./Training/pattern_config.json
```

## 📚 Usage Guide

### For Learners

1. **Start with the Learning Path**
   ```bash
   cat Training/LEARNING_PATH.md
   ```
   Follow the structured progression from Tier 1 to Tier 3.

2. **Explore by Concept**
   ```bash
   cat Training/CONCEPTS.md
   ```
   Find scripts that demonstrate specific features (e.g., GUI Creation, OOP, COM).

3. **Browse by Category**
   - GUI Applications: For learning UI design
   - Data Structures: For data manipulation patterns
   - Utility Libraries: For practical tools and patterns

4. **Check Script Metadata**
   Each script has a corresponding `.json` file with:
   - Complexity score
   - Demonstrated concepts
   - Dependencies
   - Key functions and classes

### For Contributors

1. **Add New Scripts**
   ```bash
   # Place your .ahk file in the source directory
   cp my_script.ahk /path/to/scripts/

   # Re-run the scraper
   python3 Training/ahk_scraper.py /path/to/scripts --copy
   ```

2. **Customize Categorization**
   Edit `Training/pattern_config.json` to modify:
   - Category definitions
   - Tier thresholds
   - Concept mappings
   - Quality criteria

3. **Regenerate Documentation**
   ```bash
   python3 Training/pattern_documenter.py
   ```

## 🎓 Learning Tiers

### Tier 1: Beginner (Complexity 0-30)
**Topics:**
- Hello World GUI
- Button clicks and events
- Basic array operations
- File reading/writing
- Single hotkey binding
- String concatenation and math

**Example Scripts:**
- `GUI_01*` - Basic GUI controls
- `Data_001-010` - Array/Map basics
- `Util_001-025` - File I/O
- `Util_110-130` - Basic hotkeys

### Tier 2: Intermediate (Complexity 31-60)
**Topics:**
- Multi-pane GUIs with tabs
- Event-driven architecture
- Higher-order functions
- Hotkey context sensitivity
- Class inheritance
- Property getters/setters

**Example Scripts:**
- `GUI_028-040` - Complex UI components
- `Data_020-040` - Advanced data operations
- `Util_030-080` - Design patterns
- `Util_306-365` - OOP patterns

### Tier 3: Advanced (Complexity 61-100)
**Topics:**
- Multi-window applications
- .NET/COM interop
- Concurrency and async
- Design pattern implementations
- Full MVC applications
- Buffer manipulation and DllCall

**Example Scripts:**
- `GUI_13X-167` - Complex dashboards
- `Util_200-250` - COM/CLR/WinRT
- `Util_315-350` - Full systems
- `Util_372-395` - GoF patterns

## 🔍 Script Categories

### 1. GUI Applications (167+ patterns)
GUI design patterns, window management, and interactive controls.

**Subcategories:**
- Basic controls (buttons, text, edit)
- Complex components (ListView, TreeView, Tab)
- Dark mode and theming
- Multi-monitor support
- Window management systems

**Key Concepts:**
- GUI creation and options
- Control event binding
- Layout management
- State management
- Custom drawing

### 2. Data Structures (112+ patterns)
Collection manipulation, data transformation, and storage patterns.

**Subcategories:**
- Array operations (map, filter, reduce, sort)
- Map utilities
- Stack and Queue implementations
- Tree and Graph structures
- Set operations

**Key Concepts:**
- Functional programming patterns
- Immutable operations
- Data transformation pipelines
- Object nesting and deep operations

### 3. Utility Libraries (533+ patterns)
Practical tools, design patterns, and advanced techniques.

**Subcategories:**
- File & I/O Operations
- Design Patterns (Factory, Singleton, Observer, etc.)
- Input Handling (Hotkeys, Hotstrings)
- Advanced Language Features (COM, .NET, WinRT)
- OOP & Architecture
- Concurrency & Events
- Built-in Functions Reference

**Key Concepts:**
- Object-oriented design
- Gang of Four patterns
- COM automation
- Buffer manipulation
- Event-driven programming
- Async operations

## 🛠️ Tools

### ahk_scraper.py
Analyzes and categorizes AHK scripts.

```bash
python3 ahk_scraper.py SOURCE_DIR [options]

Options:
  --training-dir PATH    Training directory (default: ./Training)
  --pattern PATTERN      File pattern (default: *.ahk)
  --recursive            Search recursively (default: True)
  --copy                 Copy files instead of moving (default: True)
  --generate-docs        Generate per-script documentation
  --generate-index       Generate master index
```

**Features:**
- Detects AHK v2 syntax and patterns
- Calculates complexity scores
- Identifies concepts (GUI, OOP, COM, etc.)
- Extracts classes, functions, dependencies
- Auto-categorizes by content analysis
- Generates metadata JSON files

### pattern_documenter.py
Generates comprehensive documentation.

```bash
python3 pattern_documenter.py [options]

Options:
  --training-dir PATH    Training directory (default: ./Training)
  --config PATH          Config file (default: pattern_config.json)
  --output-dir PATH      Output directory (default: ./Training)
```

**Generates:**
- Category-specific READMEs
- Concept guide
- Learning path
- Statistics report
- Cross-reference map

### pattern_config.json
Configuration file for categorization.

**Customize:**
- Category definitions and keywords
- Tier complexity ranges
- Concept-to-pattern mappings
- Quality criteria

## 📊 Quality Criteria

Scripts are evaluated on:

✅ **Syntax Correctness** - Valid AHK v2 syntax
✅ **V2 Compliance** - Modern v2 features (not v1 compatibility)
✅ **Pattern Clarity** - Clear, focused purpose
✅ **OOP Best Practices** - Proper class structure when applicable
✅ **Documentation** - Comments explaining key concepts
✅ **Reusability** - Patterns applicable to other projects
✅ **Error Handling** - Edge cases and validation

## 🔗 Cross-References

The system automatically generates cross-references between related scripts based on:
- Shared concepts
- Similar complexity levels
- Related patterns
- Common dependencies

Access via `cross_references.json` or script-specific READMEs.

## 📈 Statistics

View comprehensive statistics:

```bash
cat Training/STATISTICS.md
```

Includes:
- Script counts by category and tier
- Concept coverage
- Complexity distribution
- Feature usage breakdown
- Top patterns and concepts

## 🎯 Example Workflow

### Learning AHK v2 GUI Programming

1. **Start with Tier 1 GUI scripts**
   ```bash
   cd Training/GUI_Applications/Tier1_Beginner
   ls *.ahk
   ```

2. **Read a script's documentation**
   ```bash
   cat GUI_001_SimpleButton_README.md
   ```

3. **Check the metadata**
   ```bash
   cat GUI_001_SimpleButton.json
   ```

4. **Find related patterns**
   ```bash
   grep "GUI_001_SimpleButton" ../cross_references.json
   ```

5. **Progress to Tier 2**
   ```bash
   cd ../Tier2_Intermediate
   ```

## 🤝 Contributing

To add scripts to the training database:

1. Place AHK v2 scripts in a source directory
2. Run the scraper on that directory
3. Review the auto-generated categorization
4. Adjust `pattern_config.json` if needed
5. Regenerate documentation

## 📝 Script Metadata Format

Each script has metadata stored in JSON:

```json
{
  "filename": "Example.ahk",
  "category": "GUI_Applications",
  "tier": "Tier2_Intermediate",
  "concepts": ["GUI Creation", "Event Handling", "OOP"],
  "dependencies": ["MyLib.ahk"],
  "key_functions": ["MyFunction", "Initialize"],
  "classes": ["MyClass"],
  "has_gui": true,
  "has_oop": true,
  "has_com": false,
  "has_hotkeys": false,
  "line_count": 150,
  "complexity_score": 45
}
```

## 🎓 Learning Resources

After working through the training scripts:

1. **Practice Projects** - Build real applications
2. **Contribute** - Add your own examples
3. **Explore** - Dive into advanced patterns
4. **Share** - Help others learn AHK v2

## 📜 License

Scripts are subject to their original licenses. The training infrastructure (scraper, documenter, configs) is provided as-is for educational purposes.

## 🆘 Troubleshooting

### "No scripts found"
- Check the source directory path
- Verify `--pattern` matches your files
- Ensure `--recursive` is set if scripts are in subdirectories

### "Error analyzing script"
- Check script encoding (should be UTF-8)
- Verify AHK v2 syntax (not v1)
- Review error message for specific issues

### "Incorrect categorization"
- Adjust `pattern_config.json`
- Add category-specific keywords
- Modify tier complexity ranges
- Regenerate with new config

## 📚 Additional Documentation

- **LEARNING_PATH.md** - Structured learning progression
- **CONCEPTS.md** - Scripts organized by concept
- **STATISTICS.md** - Database statistics and metrics
- **INDEX.md** - Complete alphabetical script listing
- **Category READMEs** - In each category directory

---

**Happy Learning!** 🚀

For questions, issues, or contributions, refer to the main repository documentation.
