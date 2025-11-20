#!/usr/bin/env python3
"""
AutoHotkey v2 Script Scraper and Organizer
Analyzes, categorizes, and documents AHK v2 scripts for training purposes.
"""

import os
import re
import json
import shutil
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, asdict
from enum import Enum


class ScriptCategory(Enum):
    """Script category classification"""
    GUI = "GUI_Applications"
    DATA = "Data_Structures"
    UTILITY = "Utility_Libraries"
    UNKNOWN = "Unknown"


class DifficultyTier(Enum):
    """Difficulty tier classification"""
    TIER1 = "Tier1_Beginner"
    TIER2 = "Tier2_Intermediate"
    TIER3 = "Tier3_Advanced"
    UNKNOWN = "Unknown"


@dataclass
class ScriptMetadata:
    """Metadata for an AHK script"""
    filename: str
    category: str
    tier: str
    concepts: List[str]
    dependencies: List[str]
    key_functions: List[str]
    classes: List[str]
    has_gui: bool
    has_oop: bool
    has_com: bool
    has_hotkeys: bool
    line_count: int
    complexity_score: int


class AHKScriptAnalyzer:
    """Analyzes AutoHotkey v2 scripts to extract patterns and metadata"""

    # Pattern definitions for AHK v2 syntax
    PATTERNS = {
        'class_def': re.compile(r'^\s*class\s+(\w+)', re.MULTILINE),
        'function_def': re.compile(r'^\s*(\w+)\s*\([^)]*\)\s*{', re.MULTILINE),
        'method_def': re.compile(r'^\s*(\w+)\s*\([^)]*\)\s*{', re.MULTILINE),
        'gui_create': re.compile(r'Gui\s*\(', re.IGNORECASE),
        'gui_add': re.compile(r'\.Add(Button|Edit|Text|ListView|TreeView|Tab|Picture|CheckBox|Radio|DropDownList|ComboBox|ListBox|GroupBox|Progress|Slider|DateTime|MonthCal|Hotkey|UpDown|StatusBar|Link)', re.IGNORECASE),
        'hotkey': re.compile(r'^(?:\s*|\s*#HotIf\s+.*\n\s*)([~*!^+#<>$]*(?:[a-zA-Z0-9]|F\d+|Space|Enter|Tab|Esc|Backspace|Delete|Insert|Home|End|PgUp|PgDn|Up|Down|Left|Right|NumpadEnter|LButton|RButton|MButton|WheelUp|WheelDown))::', re.MULTILINE),
        'hotstring': re.compile(r'^(?:\s*|\s*#HotIf\s+.*\n\s*):(?:[*?BCKOR0-9]*):([^:]+)::', re.MULTILINE),
        'com_create': re.compile(r'ComObject\s*\(|ComObjActive\s*\(|ComObjGet\s*\(', re.IGNORECASE),
        'clr_usage': re.compile(r'CLR_\w+|\.NET|System\.', re.IGNORECASE),
        'winrt_usage': re.compile(r'WinRT|Windows\.Runtime|Windows\.Foundation', re.IGNORECASE),
        'map_usage': re.compile(r'Map\s*\(', re.IGNORECASE),
        'array_usage': re.compile(r'Array\s*\(|\[.*\]', re.IGNORECASE),
        'prop_get': re.compile(r'^\s*(\w+)\s*\[\s*\]\s*{', re.MULTILINE),
        'prop_set': re.compile(r'^\s*(\w+)\s*\[\s*\]\s*{', re.MULTILINE),
        'static_method': re.compile(r'^\s*static\s+(\w+)\s*\(', re.MULTILINE),
        'callback': re.compile(r'ObjBindMethod\s*\(|CallbackCreate\s*\(|Func\s*\(', re.IGNORECASE),
        'event_handler': re.compile(r'\.OnEvent\s*\(|OnMessage\s*\(|OnExit\s*\(', re.IGNORECASE),
        'buffer_usage': re.compile(r'Buffer\s*\(|NumPut\s*\(|NumGet\s*\(|StrPut\s*\(|StrGet\s*\(', re.IGNORECASE),
        'dllcall': re.compile(r'DllCall\s*\(', re.IGNORECASE),
        'regex_usage': re.compile(r'RegEx(?:Match|Replace)\s*\(', re.IGNORECASE),
    }

    # Keyword patterns for categorization
    GUI_KEYWORDS = ['gui', 'window', 'button', 'control', 'listview', 'treeview', 'tab', 'menu', 'dialog', 'form']
    DATA_KEYWORDS = ['array', 'map', 'object', 'collection', 'list', 'queue', 'stack', 'tree', 'graph', 'hash']
    OOP_KEYWORDS = ['class', 'inheritance', 'polymorphism', 'encapsulation', 'abstract', 'interface', 'factory', 'singleton', 'observer', 'pattern']
    ADVANCED_KEYWORDS = ['com', 'clr', 'winrt', 'buffer', 'dllcall', 'callback', 'async', 'thread', 'mutex', 'semaphore']

    def __init__(self):
        self.metadata_cache = {}

    def analyze_script(self, filepath: Path) -> ScriptMetadata:
        """Analyze a single AHK script and extract metadata"""

        if not filepath.exists():
            raise FileNotFoundError(f"Script not found: {filepath}")

        # Read script content
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            # Try with different encoding
            with open(filepath, 'r', encoding='latin-1') as f:
                content = f.read()

        # Extract basic metrics
        lines = content.split('\n')
        line_count = len([l for l in lines if l.strip() and not l.strip().startswith(';')])

        # Extract classes
        classes = self.PATTERNS['class_def'].findall(content)

        # Extract functions
        functions = self.PATTERNS['function_def'].findall(content)

        # Detect features
        has_gui = bool(self.PATTERNS['gui_create'].search(content) or self.PATTERNS['gui_add'].search(content))
        has_oop = len(classes) > 0
        has_com = bool(self.PATTERNS['com_create'].search(content) or
                      self.PATTERNS['clr_usage'].search(content) or
                      self.PATTERNS['winrt_usage'].search(content))
        has_hotkeys = bool(self.PATTERNS['hotkey'].search(content) or self.PATTERNS['hotstring'].search(content))

        # Extract dependencies (simple include detection)
        dependencies = re.findall(r'#Include\s+([^\r\n]+)', content, re.IGNORECASE)

        # Identify concepts
        concepts = self._identify_concepts(content, filepath.name)

        # Calculate complexity score
        complexity_score = self._calculate_complexity(content, classes, functions)

        # Determine category and tier
        category = self._categorize_script(filepath.name, content, concepts)
        tier = self._determine_tier(complexity_score, concepts, has_gui, has_oop, has_com)

        return ScriptMetadata(
            filename=filepath.name,
            category=category.value,
            tier=tier.value,
            concepts=concepts,
            dependencies=dependencies,
            key_functions=functions[:10],  # Top 10 functions
            classes=classes,
            has_gui=has_gui,
            has_oop=has_oop,
            has_com=has_com,
            has_hotkeys=has_hotkeys,
            line_count=line_count,
            complexity_score=complexity_score
        )

    def _identify_concepts(self, content: str, filename: str) -> List[str]:
        """Identify AHK concepts demonstrated in the script"""
        concepts = []

        # Check for various AHK v2 features
        if self.PATTERNS['gui_create'].search(content):
            concepts.append('GUI Creation')
        if self.PATTERNS['gui_add'].search(content):
            concepts.append('GUI Controls')
        if self.PATTERNS['class_def'].search(content):
            concepts.append('Object-Oriented Programming')
        if self.PATTERNS['hotkey'].search(content):
            concepts.append('Hotkeys')
        if self.PATTERNS['hotstring'].search(content):
            concepts.append('Hotstrings')
        if self.PATTERNS['com_create'].search(content):
            concepts.append('COM Automation')
        if self.PATTERNS['clr_usage'].search(content):
            concepts.append('.NET Interop')
        if self.PATTERNS['winrt_usage'].search(content):
            concepts.append('WinRT/Modern Windows')
        if self.PATTERNS['map_usage'].search(content):
            concepts.append('Map Data Structure')
        if self.PATTERNS['array_usage'].search(content):
            concepts.append('Array Operations')
        if self.PATTERNS['prop_get'].search(content):
            concepts.append('Properties')
        if self.PATTERNS['static_method'].search(content):
            concepts.append('Static Methods')
        if self.PATTERNS['callback'].search(content):
            concepts.append('Callbacks')
        if self.PATTERNS['event_handler'].search(content):
            concepts.append('Event Handling')
        if self.PATTERNS['buffer_usage'].search(content):
            concepts.append('Buffer Manipulation')
        if self.PATTERNS['dllcall'].search(content):
            concepts.append('DllCall/WinAPI')
        if self.PATTERNS['regex_usage'].search(content):
            concepts.append('Regular Expressions')

        # Pattern-based concepts from filename
        if 'factory' in filename.lower():
            concepts.append('Factory Pattern')
        if 'singleton' in filename.lower():
            concepts.append('Singleton Pattern')
        if 'observer' in filename.lower():
            concepts.append('Observer Pattern')
        if 'adapter' in filename.lower():
            concepts.append('Adapter Pattern')
        if 'decorator' in filename.lower():
            concepts.append('Decorator Pattern')
        if 'mvc' in filename.lower():
            concepts.append('MVC Pattern')
        if 'inheritance' in filename.lower():
            concepts.append('Inheritance')

        return list(set(concepts))  # Remove duplicates

    def _calculate_complexity(self, content: str, classes: List[str], functions: List[str]) -> int:
        """Calculate complexity score (0-100)"""
        score = 0

        # Base score from code size
        line_count = len([l for l in content.split('\n') if l.strip()])
        score += min(line_count // 10, 20)  # Max 20 points

        # Class complexity
        score += len(classes) * 5  # 5 points per class

        # Function complexity
        score += len(functions) * 2  # 2 points per function

        # Feature complexity
        if self.PATTERNS['com_create'].search(content):
            score += 15
        if self.PATTERNS['clr_usage'].search(content):
            score += 15
        if self.PATTERNS['buffer_usage'].search(content):
            score += 10
        if self.PATTERNS['dllcall'].search(content):
            score += 10
        if self.PATTERNS['gui_create'].search(content):
            score += 5
        if self.PATTERNS['callback'].search(content):
            score += 8

        return min(score, 100)  # Cap at 100

    def _categorize_script(self, filename: str, content: str, concepts: List[str]) -> ScriptCategory:
        """Determine script category based on content analysis"""
        filename_lower = filename.lower()
        content_lower = content.lower()

        # Check filename prefix first
        if filename.startswith('GUI_'):
            return ScriptCategory.GUI
        if filename.startswith('Data_'):
            return ScriptCategory.DATA
        if filename.startswith('Util_'):
            return ScriptCategory.UTILITY

        # Analyze content
        gui_score = sum(1 for kw in self.GUI_KEYWORDS if kw in filename_lower or kw in content_lower)
        data_score = sum(1 for kw in self.DATA_KEYWORDS if kw in filename_lower or kw in content_lower)

        # Check for GUI indicators
        if self.PATTERNS['gui_create'].search(content) or gui_score > 2:
            return ScriptCategory.GUI

        # Check for data structure indicators
        if data_score > gui_score and (
            self.PATTERNS['map_usage'].search(content) or
            self.PATTERNS['array_usage'].search(content) or
            any(kw in filename_lower for kw in ['array', 'map', 'stack', 'queue', 'tree', 'graph'])
        ):
            return ScriptCategory.DATA

        # Default to utility
        return ScriptCategory.UTILITY

    def _determine_tier(self, complexity: int, concepts: List[str], has_gui: bool, has_oop: bool, has_com: bool) -> DifficultyTier:
        """Determine difficulty tier based on complexity and features"""

        # Tier 3: Advanced (complexity > 60 or has advanced features)
        if complexity > 60 or has_com:
            return DifficultyTier.TIER3

        # Check for advanced concepts
        advanced_concepts = ['COM Automation', '.NET Interop', 'WinRT/Modern Windows',
                            'Buffer Manipulation', 'Callbacks', 'Factory Pattern',
                            'Observer Pattern', 'MVC Pattern']

        if any(c in concepts for c in advanced_concepts):
            return DifficultyTier.TIER3

        # Tier 2: Intermediate (complexity 30-60 or has OOP/complex GUI)
        if complexity > 30 or (has_oop and has_gui):
            return DifficultyTier.TIER2

        intermediate_concepts = ['Object-Oriented Programming', 'Properties',
                                'Static Methods', 'Event Handling', 'Regular Expressions']

        if any(c in concepts for c in intermediate_concepts):
            return DifficultyTier.TIER2

        # Tier 1: Beginner (everything else)
        return DifficultyTier.TIER1


class ScriptScraper:
    """Scrapes and organizes AHK scripts into training structure"""

    def __init__(self, source_dir: Path, training_dir: Path):
        self.source_dir = source_dir
        self.training_dir = training_dir
        self.analyzer = AHKScriptAnalyzer()
        self.processed_scripts = []

    def scrape_directory(self, pattern: str = "*.ahk", recursive: bool = True) -> List[ScriptMetadata]:
        """Scrape all AHK scripts from source directory"""

        if recursive:
            scripts = list(self.source_dir.rglob(pattern))
        else:
            scripts = list(self.source_dir.glob(pattern))

        print(f"Found {len(scripts)} scripts to analyze...")

        metadata_list = []
        for script_path in scripts:
            try:
                print(f"Analyzing: {script_path.name}")
                metadata = self.analyzer.analyze_script(script_path)
                metadata_list.append(metadata)
                self.processed_scripts.append((script_path, metadata))
            except Exception as e:
                print(f"Error analyzing {script_path}: {e}")

        return metadata_list

    def organize_scripts(self, copy_mode: bool = True):
        """Organize scripts into training directory structure"""

        for script_path, metadata in self.processed_scripts:
            # Determine target directory
            target_dir = self.training_dir / metadata.category / metadata.tier
            target_dir.mkdir(parents=True, exist_ok=True)

            # Copy or move script
            target_path = target_dir / metadata.filename

            if copy_mode:
                shutil.copy2(script_path, target_path)
            else:
                shutil.move(str(script_path), str(target_path))

            # Create metadata JSON
            metadata_path = target_path.with_suffix('.json')
            with open(metadata_path, 'w', encoding='utf-8') as f:
                json.dump(asdict(metadata), f, indent=2)

            print(f"Organized: {metadata.filename} -> {metadata.category}/{metadata.tier}")

    def generate_documentation(self, script_path: Path, metadata: ScriptMetadata) -> str:
        """Generate markdown documentation for a script"""

        # Read script content
        with open(script_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extract comments at the top as description
        description_lines = []
        for line in content.split('\n'):
            if line.strip().startswith(';'):
                description_lines.append(line.strip()[1:].strip())
            elif line.strip():
                break

        description = '\n'.join(description_lines) if description_lines else "No description available."

        # Generate markdown
        doc = f"""# {metadata.filename}

## Metadata
- **Category:** {metadata.category}
- **Difficulty:** {metadata.tier}
- **Complexity Score:** {metadata.complexity_score}/100
- **Line Count:** {metadata.line_count}

## Concepts Demonstrated
{chr(10).join(f'- {concept}' for concept in metadata.concepts)}

## Features
- GUI: {'✓' if metadata.has_gui else '✗'}
- OOP: {'✓' if metadata.has_oop else '✗'}
- COM/Interop: {'✓' if metadata.has_com else '✗'}
- Hotkeys: {'✓' if metadata.has_hotkeys else '✗'}

## Classes
{chr(10).join(f'- `{cls}`' for cls in metadata.classes) if metadata.classes else '- None'}

## Key Functions
{chr(10).join(f'- `{func}()`' for func in metadata.key_functions[:5]) if metadata.key_functions else '- None'}

## Dependencies
{chr(10).join(f'- `{dep}`' for dep in metadata.dependencies) if metadata.dependencies else '- None'}

## Description
{description}

## Code
```ahk
{content}
```

## Usage Examples
<!-- TODO: Add usage examples -->

## Related Patterns
<!-- TODO: Add cross-references to related scripts -->

---
*Generated by AHK Script Scraper*
"""
        return doc

    def generate_index(self) -> str:
        """Generate index of all processed scripts"""

        # Group by category and tier
        by_category = {}
        for _, metadata in self.processed_scripts:
            if metadata.category not in by_category:
                by_category[metadata.category] = {}
            if metadata.tier not in by_category[metadata.category]:
                by_category[metadata.category][metadata.tier] = []
            by_category[metadata.category][metadata.tier].append(metadata)

        # Generate index markdown
        index = "# AutoHotkey v2 Training Database Index\n\n"
        index += f"**Total Scripts:** {len(self.processed_scripts)}\n\n"

        for category in sorted(by_category.keys()):
            index += f"## {category}\n\n"

            for tier in sorted(by_category[category].keys()):
                scripts = by_category[category][tier]
                index += f"### {tier} ({len(scripts)} scripts)\n\n"

                for metadata in sorted(scripts, key=lambda m: m.filename):
                    concepts_str = ', '.join(metadata.concepts[:3])
                    if len(metadata.concepts) > 3:
                        concepts_str += f", +{len(metadata.concepts) - 3} more"

                    index += f"- **{metadata.filename}** - {concepts_str}\n"

                index += "\n"

        return index


def main():
    """Main entry point for the scraper"""
    import argparse

    parser = argparse.ArgumentParser(description='AutoHotkey v2 Script Scraper')
    parser.add_argument('source', type=str, help='Source directory containing AHK scripts')
    parser.add_argument('--training-dir', type=str, default='./Training', help='Training directory path')
    parser.add_argument('--pattern', type=str, default='*.ahk', help='File pattern to match')
    parser.add_argument('--recursive', action='store_true', default=True, help='Search recursively')
    parser.add_argument('--copy', action='store_true', default=True, help='Copy files (vs move)')
    parser.add_argument('--generate-docs', action='store_true', help='Generate documentation for each script')
    parser.add_argument('--generate-index', action='store_true', help='Generate index file')

    args = parser.parse_args()

    source_dir = Path(args.source)
    training_dir = Path(args.training_dir)

    if not source_dir.exists():
        print(f"Error: Source directory not found: {source_dir}")
        return

    # Create scraper
    scraper = ScriptScraper(source_dir, training_dir)

    # Scrape scripts
    metadata_list = scraper.scrape_directory(args.pattern, args.recursive)

    print(f"\nProcessed {len(metadata_list)} scripts")

    # Organize scripts
    scraper.organize_scripts(copy_mode=args.copy)

    # Generate documentation
    if args.generate_docs:
        print("\nGenerating documentation...")
        for script_path, metadata in scraper.processed_scripts:
            doc = scraper.generate_documentation(script_path, metadata)
            doc_path = training_dir / metadata.category / metadata.tier / f"{Path(metadata.filename).stem}_README.md"
            with open(doc_path, 'w', encoding='utf-8') as f:
                f.write(doc)

    # Generate index
    if args.generate_index:
        print("\nGenerating index...")
        index = scraper.generate_index()
        index_path = training_dir / "INDEX.md"
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(index)
        print(f"Index written to: {index_path}")


if __name__ == '__main__':
    main()
