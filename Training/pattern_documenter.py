#!/usr/bin/env python3
"""
Pattern Documentation Generator
Generates comprehensive documentation for AHK training patterns
"""

import json
from pathlib import Path
from typing import List, Dict, Set
from collections import defaultdict


class PatternDocumenter:
    """Generates comprehensive documentation for training patterns"""

    def __init__(self, training_dir: Path, config_path: Path):
        self.training_dir = training_dir
        self.config = self._load_config(config_path)
        self.pattern_index = defaultdict(list)
        self.concept_index = defaultdict(list)

    def _load_config(self, config_path: Path) -> dict:
        """Load pattern configuration"""
        with open(config_path, 'r', encoding='utf-8') as f:
            return json.load(f)

    def scan_training_directory(self):
        """Scan training directory and build indexes"""
        print("Scanning training directory...")

        for json_file in self.training_dir.rglob('*.json'):
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)

                # Index by category and tier
                key = f"{metadata['category']}/{metadata['tier']}"
                self.pattern_index[key].append(metadata)

                # Index by concepts
                for concept in metadata.get('concepts', []):
                    self.concept_index[concept].append(metadata)

            except Exception as e:
                print(f"Error reading {json_file}: {e}")

    def generate_category_readme(self, category: str) -> str:
        """Generate README for a specific category"""

        cat_config = self.config['categories'].get(category, {})
        desc = cat_config.get('description', 'No description')

        readme = f"# {category}\n\n"
        readme += f"**Description:** {desc}\n\n"

        # Statistics
        total_scripts = sum(len(v) for k, v in self.pattern_index.items() if k.startswith(category))
        readme += f"**Total Scripts:** {total_scripts}\n\n"

        # By tier
        readme += "## Scripts by Difficulty\n\n"

        for tier in ['Tier1_Beginner', 'Tier2_Intermediate', 'Tier3_Advanced']:
            key = f"{category}/{tier}"
            scripts = self.pattern_index.get(key, [])

            if scripts:
                tier_config = self.config['tier_definitions'].get(tier, {})
                tier_desc = f"Complexity {tier_config.get('complexity_range', [0, 100])[0]}-{tier_config.get('complexity_range', [0, 100])[1]}"

                readme += f"### {tier} ({len(scripts)} scripts)\n"
                readme += f"*{tier_desc}*\n\n"

                # Sort by filename
                for script in sorted(scripts, key=lambda s: s['filename']):
                    concepts = ', '.join(script['concepts'][:3])
                    if len(script['concepts']) > 3:
                        concepts += f" +{len(script['concepts']) - 3} more"

                    readme += f"- **[{script['filename']}]({tier}/{script['filename']})** "
                    readme += f"(Complexity: {script['complexity_score']}) - {concepts}\n"

                readme += "\n"

        # Patterns section
        if 'patterns' in cat_config:
            readme += "## Pattern Categories\n\n"
            for pattern_name, pattern_desc in cat_config['patterns'].items():
                readme += f"### {pattern_name}\n{pattern_desc}\n\n"

        return readme

    def generate_concept_guide(self) -> str:
        """Generate a guide organized by concepts"""

        guide = "# AutoHotkey v2 Concepts Guide\n\n"
        guide += "Scripts organized by the concepts they demonstrate.\n\n"

        # Sort concepts by tier (beginner first)
        concept_tier_map = {}
        for concept, config in self.config.get('concept_mappings', {}).items():
            concept_tier_map[concept] = config.get('tier', 2)

        sorted_concepts = sorted(self.concept_index.keys(),
                                key=lambda c: (concept_tier_map.get(c, 2), c))

        for concept in sorted_concepts:
            scripts = self.concept_index[concept]
            tier = concept_tier_map.get(concept, 2)
            tier_name = ['', 'Beginner', 'Intermediate', 'Advanced'][tier]

            guide += f"## {concept}\n"
            guide += f"**Level:** {tier_name}\n\n"

            # Add pattern examples if available
            concept_config = self.config.get('concept_mappings', {}).get(concept, {})
            if 'patterns' in concept_config:
                guide += f"**Patterns:** `{'`, `'.join(concept_config['patterns'])}`\n\n"

            guide += f"**Scripts ({len(scripts)}):**\n"

            for script in sorted(scripts, key=lambda s: (s['complexity_score'], s['filename']))[:10]:
                guide += f"- [{script['filename']}]({script['category']}/{script['tier']}/{script['filename']}) "
                guide += f"({script['category']}, Complexity: {script['complexity_score']})\n"

            if len(scripts) > 10:
                guide += f"- *...and {len(scripts) - 10} more*\n"

            guide += "\n"

        return guide

    def generate_learning_path(self) -> str:
        """Generate a recommended learning path"""

        path = "# AutoHotkey v2 Learning Path\n\n"
        path += "A structured approach to learning AutoHotkey v2 from beginner to advanced.\n\n"

        # Tier 1: Beginner
        tier_config = self.config['tier_definitions']['Tier1_Beginner']
        path += "## Stage 1: Beginner\n\n"
        path += "**Topics to Learn:**\n"
        for topic in tier_config['topics']:
            path += f"- {topic}\n"
        path += "\n"

        path += "**Recommended Scripts:**\n"
        tier1_scripts = []
        for key, scripts in self.pattern_index.items():
            if 'Tier1_Beginner' in key:
                tier1_scripts.extend(scripts)

        # Get 10 best starter scripts
        starter_scripts = sorted(tier1_scripts, key=lambda s: s['complexity_score'])[:10]
        for i, script in enumerate(starter_scripts, 1):
            path += f"{i}. **{script['filename']}** - {', '.join(script['concepts'][:2])}\n"
        path += "\n"

        # Tier 2: Intermediate
        tier_config = self.config['tier_definitions']['Tier2_Intermediate']
        path += "## Stage 2: Intermediate\n\n"
        path += "**Topics to Learn:**\n"
        for topic in tier_config['topics']:
            path += f"- {topic}\n"
        path += "\n"

        path += "**Recommended Scripts:**\n"
        tier2_scripts = []
        for key, scripts in self.pattern_index.items():
            if 'Tier2_Intermediate' in key:
                tier2_scripts.extend(scripts)

        intermediate_scripts = sorted(tier2_scripts, key=lambda s: s['complexity_score'])[:10]
        for i, script in enumerate(intermediate_scripts, 1):
            path += f"{i}. **{script['filename']}** - {', '.join(script['concepts'][:2])}\n"
        path += "\n"

        # Tier 3: Advanced
        tier_config = self.config['tier_definitions']['Tier3_Advanced']
        path += "## Stage 3: Advanced\n\n"
        path += "**Topics to Learn:**\n"
        for topic in tier_config['topics']:
            path += f"- {topic}\n"
        path += "\n"

        path += "**Recommended Scripts:**\n"
        tier3_scripts = []
        for key, scripts in self.pattern_index.items():
            if 'Tier3_Advanced' in key:
                tier3_scripts.extend(scripts)

        advanced_scripts = sorted(tier3_scripts, key=lambda s: s['complexity_score'])[:10]
        for i, script in enumerate(advanced_scripts, 1):
            path += f"{i}. **{script['filename']}** - {', '.join(script['concepts'][:2])}\n"
        path += "\n"

        # Projects section
        path += "## Capstone Projects\n\n"
        path += "After completing the learning path, try building these projects:\n\n"
        path += "1. **Simple GUI Application** - Text editor with file operations\n"
        path += "2. **Data Management Tool** - CSV/JSON processor with GUI\n"
        path += "3. **Automation Suite** - Hotkey-based workflow automation\n"
        path += "4. **System Utility** - Window manager or clipboard enhancer\n"
        path += "5. **Advanced Integration** - COM/WinRT application with modern UI\n\n"

        return path

    def generate_cross_reference_map(self) -> Dict[str, List[str]]:
        """Generate cross-reference map between related scripts"""

        cross_ref = defaultdict(list)

        # Cross-reference by shared concepts
        for script_key, scripts in self.pattern_index.items():
            for script in scripts:
                filename = script['filename']
                concepts = set(script['concepts'])

                # Find related scripts (scripts sharing concepts)
                for other_key, other_scripts in self.pattern_index.items():
                    for other_script in other_scripts:
                        if other_script['filename'] == filename:
                            continue

                        other_concepts = set(other_script['concepts'])
                        shared_concepts = concepts & other_concepts

                        # If they share 2+ concepts, consider them related
                        if len(shared_concepts) >= 2:
                            cross_ref[filename].append({
                                'filename': other_script['filename'],
                                'category': other_script['category'],
                                'tier': other_script['tier'],
                                'shared_concepts': list(shared_concepts)
                            })

        return dict(cross_ref)

    def generate_statistics_report(self) -> str:
        """Generate statistics report"""

        report = "# AutoHotkey v2 Training Database Statistics\n\n"

        # Total counts
        total_scripts = sum(len(v) for v in self.pattern_index.values())
        report += f"**Total Scripts:** {total_scripts}\n\n"

        # By category
        report += "## Scripts by Category\n\n"
        category_counts = defaultdict(int)
        for key, scripts in self.pattern_index.items():
            category = key.split('/')[0]
            category_counts[category] += len(scripts)

        for category, count in sorted(category_counts.items()):
            percentage = (count / total_scripts * 100) if total_scripts > 0 else 0
            report += f"- **{category}:** {count} scripts ({percentage:.1f}%)\n"

        report += "\n"

        # By tier
        report += "## Scripts by Difficulty Tier\n\n"
        tier_counts = defaultdict(int)
        for key, scripts in self.pattern_index.items():
            tier = key.split('/')[1]
            tier_counts[tier] += len(scripts)

        for tier in ['Tier1_Beginner', 'Tier2_Intermediate', 'Tier3_Advanced']:
            count = tier_counts.get(tier, 0)
            percentage = (count / total_scripts * 100) if total_scripts > 0 else 0
            report += f"- **{tier}:** {count} scripts ({percentage:.1f}%)\n"

        report += "\n"

        # Concept coverage
        report += "## Concept Coverage\n\n"
        report += f"**Total Unique Concepts:** {len(self.concept_index)}\n\n"

        # Top concepts
        top_concepts = sorted(self.concept_index.items(),
                            key=lambda x: len(x[1]), reverse=True)[:15]

        report += "### Most Common Concepts\n\n"
        for concept, scripts in top_concepts:
            report += f"- **{concept}:** {len(scripts)} scripts\n"

        report += "\n"

        # Complexity distribution
        report += "## Complexity Distribution\n\n"

        all_scripts = []
        for scripts in self.pattern_index.values():
            all_scripts.extend(scripts)

        if all_scripts:
            complexities = [s['complexity_score'] for s in all_scripts]
            avg_complexity = sum(complexities) / len(complexities)
            min_complexity = min(complexities)
            max_complexity = max(complexities)

            report += f"- **Average Complexity:** {avg_complexity:.1f}\n"
            report += f"- **Min Complexity:** {min_complexity}\n"
            report += f"- **Max Complexity:** {max_complexity}\n\n"

            # Distribution ranges
            ranges = {
                '0-20': 0,
                '21-40': 0,
                '41-60': 0,
                '61-80': 0,
                '81-100': 0
            }

            for complexity in complexities:
                if complexity <= 20:
                    ranges['0-20'] += 1
                elif complexity <= 40:
                    ranges['21-40'] += 1
                elif complexity <= 60:
                    ranges['41-60'] += 1
                elif complexity <= 80:
                    ranges['61-80'] += 1
                else:
                    ranges['81-100'] += 1

            report += "### Complexity Ranges\n\n"
            for range_name, count in ranges.items():
                percentage = (count / len(all_scripts) * 100)
                bar = '█' * int(percentage / 2)
                report += f"- **{range_name}:** {count:3d} scripts {bar} {percentage:.1f}%\n"

        report += "\n"

        # Feature usage
        report += "## Feature Usage\n\n"

        feature_counts = {
            'GUI': sum(1 for scripts in self.pattern_index.values() for s in scripts if s.get('has_gui')),
            'OOP': sum(1 for scripts in self.pattern_index.values() for s in scripts if s.get('has_oop')),
            'COM/Interop': sum(1 for scripts in self.pattern_index.values() for s in scripts if s.get('has_com')),
            'Hotkeys': sum(1 for scripts in self.pattern_index.values() for s in scripts if s.get('has_hotkeys'))
        }

        for feature, count in feature_counts.items():
            percentage = (count / total_scripts * 100) if total_scripts > 0 else 0
            report += f"- **{feature}:** {count} scripts ({percentage:.1f}%)\n"

        report += "\n"

        return report


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(description='Pattern Documentation Generator')
    parser.add_argument('--training-dir', type=str, default='./Training',
                       help='Training directory path')
    parser.add_argument('--config', type=str, default='./Training/pattern_config.json',
                       help='Pattern configuration file')
    parser.add_argument('--output-dir', type=str, default='./Training',
                       help='Output directory for generated docs')

    args = parser.parse_args()

    training_dir = Path(args.training_dir)
    config_path = Path(args.config)
    output_dir = Path(args.output_dir)

    if not training_dir.exists():
        print(f"Error: Training directory not found: {training_dir}")
        return

    if not config_path.exists():
        print(f"Error: Config file not found: {config_path}")
        return

    # Create documenter
    documenter = PatternDocumenter(training_dir, config_path)

    # Scan directory
    documenter.scan_training_directory()

    # Generate documentation
    print("Generating category READMEs...")
    for category in ['GUI_Applications', 'Data_Structures', 'Utility_Libraries']:
        readme = documenter.generate_category_readme(category)
        readme_path = training_dir / category / 'README.md'
        readme_path.parent.mkdir(parents=True, exist_ok=True)
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme)
        print(f"  Generated: {readme_path}")

    # Generate concept guide
    print("Generating concept guide...")
    concept_guide = documenter.generate_concept_guide()
    concept_path = output_dir / 'CONCEPTS.md'
    with open(concept_path, 'w', encoding='utf-8') as f:
        f.write(concept_guide)
    print(f"  Generated: {concept_path}")

    # Generate learning path
    print("Generating learning path...")
    learning_path = documenter.generate_learning_path()
    path_file = output_dir / 'LEARNING_PATH.md'
    with open(path_file, 'w', encoding='utf-8') as f:
        f.write(learning_path)
    print(f"  Generated: {path_file}")

    # Generate statistics
    print("Generating statistics report...")
    stats = documenter.generate_statistics_report()
    stats_path = output_dir / 'STATISTICS.md'
    with open(stats_path, 'w', encoding='utf-8') as f:
        f.write(stats)
    print(f"  Generated: {stats_path}")

    # Generate cross-reference map
    print("Generating cross-reference map...")
    cross_ref = documenter.generate_cross_reference_map()
    cross_ref_path = output_dir / 'cross_references.json'
    with open(cross_ref_path, 'w', encoding='utf-8') as f:
        json.dump(cross_ref, f, indent=2)
    print(f"  Generated: {cross_ref_path}")

    print("\nDocumentation generation complete!")


if __name__ == '__main__':
    main()
