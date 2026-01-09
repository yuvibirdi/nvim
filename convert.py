#!/usr/bin/env python3
"""
Convert C++ competitive programming templates to LuaSnip snippets.
Optimized for ncduy0303/Competitive-Programming repository structure.

Usage: python3 cpp_to_luasnip_v2.py <cpp_directory> <output_file> [--short-triggers]
"""

import os
import re
import sys
from pathlib import Path


# Custom trigger mappings for common patterns
TRIGGER_MAPPINGS = {
    'disjoint set union': 'dsu',
    'segment tree': 'segtree',
    'fenwick tree': 'fenwick',
    'sparse table': 'sparse',
    'binary lifting': 'binlift',
    'lowest common ancestor': 'lca',
    'strongly connected components': 'scc',
    'topological sort': 'toposort',
    'dijkstra': 'dijkstra',
    'bellman': 'bellman',
    'floyd warshall': 'floyd',
    'knapsack': 'knapsack',
    'longest increasing subsequence': 'lis',
    'longest common subsequence': 'lcs',
    'kruskal': 'kruskal',
    'prim': 'prim',
    'suffix array': 'suffix',
    'kmp': 'kmp',
    'z-algo': 'zalgo',
    'rabin-karp': 'rabinkarp',
    'sieve': 'sieve',
    'convex hull': 'convexhull',
    'max flow': 'maxflow',
    'dinic': 'dinic',
    'edmonds': 'edmonds',
    'bipartite': 'bipartite',
    'traveling salesman': 'tsp',
    'heavy light decomposition': 'hld',
    'treap': 'treap',
    'trie': 'trie',
    'tarjan': 'tarjan',
    'kosaraju': 'kosaraju',
    'articulation': 'articulation',
    'bridges': 'bridges',
}


def sanitize_trigger(filepath, base_dir, use_short=True):
    """Convert filepath to a meaningful snippet trigger."""
    # Get relative path from base directory
    rel_path = Path(filepath).relative_to(base_dir)
    
    # Get category (parent directory)
    category = rel_path.parent.name if rel_path.parent != Path('.') else ''
    
    # Get filename without extension
    name = rel_path.stem
    
    # Create full name for matching
    full_name = f"{category} {name}".lower()
    
    # Check for custom mappings first
    for pattern, trigger in TRIGGER_MAPPINGS.items():
        if pattern in full_name:
            # If there are variations (like DFS/BFS), append suffix
            if '(' in name and ')' in name:
                suffix = re.search(r'\(([^)]+)\)', name)
                if suffix:
                    variant = suffix.group(1).lower().replace(' ', '_')[:4]
                    return f"{trigger}_{variant}"
            return trigger
    
    # Otherwise, sanitize the filename
    name_lower = name.lower()
    
    # Remove common parentheticals but extract them for suffix if needed
    variant = ''
    paren_match = re.search(r'\(([^)]+)\)', name_lower)
    if paren_match:
        variant = paren_match.group(1).lower().replace(' ', '_')[:6]
        name_lower = re.sub(r'\([^)]*\)', '', name_lower)
    
    # Replace special characters with underscores
    name_clean = re.sub(r'[^a-z0-9_]', '_', name_lower)
    
    # Remove consecutive underscores
    name_clean = re.sub(r'_+', '_', name_clean)
    
    # Remove leading/trailing underscores
    name_clean = name_clean.strip('_')
    
    # If we want short triggers and name is long, abbreviate
    if use_short and len(name_clean) > 15:
        # Try to create abbreviation from words
        words = name_clean.split('_')
        if len(words) > 1:
            abbrev = ''.join(w[0] for w in words if w)
            if len(abbrev) >= 3:
                if variant:
                    return f"{abbrev}_{variant}"
                return abbrev
    
    # Add variant if we have one
    if variant and len(name_clean) > 8:
        name_clean = f"{name_clean[:10]}_{variant}"
    
    return name_clean if name_clean else 'snippet'


def extract_description(content, filepath):
    """Extract description from C++ comments at the top of file."""
    lines = content.strip().split('\n')
    description_parts = []
    
    # Also use category from path as fallback
    category = Path(filepath).parent.name if Path(filepath).parent != Path('.') else ''
    
    for line in lines[:15]:  # Check first 15 lines
        line = line.strip()
        
        # Single line comment
        if line.startswith('//'):
            desc = line[2:].strip()
            # Skip common headers and empty lines
            if desc and not desc.startswith('===') and not desc.startswith('---'):
                if not any(skip in desc.lower() for skip in ['author:', 'date:', 'license:', 'copyright', 'problem:']):
                    description_parts.append(desc)
        
        # Multi-line comment
        elif line.startswith('/*') or (line.startswith('*') and not line.startswith('**/')):
            desc = re.sub(r'^/?\*+\s*', '', line).strip()
            desc = desc.replace('*/', '').strip()
            if desc and not desc.startswith('='):
                description_parts.append(desc)
        
        # Stop at first actual code (not preprocessor)
        elif line and not line.startswith('#') and not line.startswith('//') and not line.startswith('/*'):
            break
    
    if description_parts:
        # Take first meaningful line, limit length
        return description_parts[0][:100]
    
    # Fallback to category + filename
    if category and category != 'Contest Template':
        filename = Path(filepath).stem
        return f"{category}: {filename}"[:100]
    
    return Path(filepath).stem[:100]


def clean_code(content):
    """Clean up the C++ code for snippet use."""
    lines = content.split('\n')
    cleaned_lines = []
    in_comment_block = False
    
    for line in lines:
        stripped = line.strip()
        
        # Skip initial comment blocks
        if stripped.startswith('/*'):
            in_comment_block = True
        if in_comment_block:
            if '*/' in stripped:
                in_comment_block = False
            continue
        
        # Skip single-line comments at the start
        if not cleaned_lines and stripped.startswith('//'):
            continue
        
        # Skip empty lines at start
        if not cleaned_lines and not stripped:
            continue
        
        cleaned_lines.append(line)
    
    return '\n'.join(cleaned_lines).strip()


def cpp_to_lua_snippet(cpp_content, trigger, description):
    """Convert C++ code to Lua snippet format."""
    # Clean the code
    code = clean_code(cpp_content)
    
    # Escape special characters for Lua strings
    code = code.replace('\\', '\\\\')
    code = code.replace('"', '\\"')
    
    # Split into lines
    lines = code.split('\n')
    
    # Build the Lua snippet
    lua_lines = [
        f'  s("{trigger}", {{',
        f'    t({{',
    ]
    
    # Add each line as a text node
    for i, line in enumerate(lines):
        if i < len(lines) - 1:
            lua_lines.append(f'      "{line}",')
        else:
            lua_lines.append(f'      "{line}"')
    
    lua_lines.extend([
        '    }),',
        '    i(0),  -- Final cursor position',
        '  }),',
        ''
    ])
    
    return '\n'.join(lua_lines), description


def process_directory(cpp_dir, output_file, use_short_triggers=True):
    """Process all C++ files in directory and create LuaSnip file."""
    cpp_dir = Path(cpp_dir)
    
    if not cpp_dir.exists():
        print(f"Error: Directory {cpp_dir} does not exist")
        return False
    
    # Find all .cpp files recursively
    cpp_files = list(cpp_dir.rglob('*.cpp'))
    
    if not cpp_files:
        print(f"No .cpp files found in {cpp_dir}")
        return False
    
    print(f"Found {len(cpp_files)} C++ files")
    
    # Start building the Lua file
    lua_content = [
        '-- Auto-generated LuaSnip snippets from C++ competitive programming templates',
        '-- Source: ncduy0303/Competitive-Programming',
        '-- Generated using cpp_to_luasnip_v2.py',
        '',
        'local ls = require("luasnip")',
        'local s = ls.snippet',
        'local t = ls.text_node',
        'local i = ls.insert_node',
        '',
        'return {',
        ''
    ]
    
    snippets_info = []
    categories = {}
    trigger_counts = {}
    
    # Process each file
    for cpp_file in sorted(cpp_files):
        # Skip template/example files that aren't actual algorithms  
        # But keep Contest Template
        if 'test' in cpp_file.name.lower() or 'example' in cpp_file.name.lower():
            continue
            
        print(f"Processing: {cpp_file.relative_to(cpp_dir)}")
        
        try:
            with open(cpp_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Skip empty files or very small files
            if not content.strip() or len(content.strip()) < 50:
                continue
            
            trigger = sanitize_trigger(cpp_file, cpp_dir, use_short_triggers)
            description = extract_description(content, cpp_file)
            category = cpp_file.parent.name if cpp_file.parent != cpp_dir else 'General'
            
            # Handle duplicates
            if trigger in trigger_counts:
                trigger_counts[trigger] += 1
                # Append category abbreviation to make unique
                cat_abbrev = ''.join(w[0] for w in category.lower().split()[:2])
                trigger = f"{trigger}_{cat_abbrev}{trigger_counts[trigger]}"
                print(f"  Duplicate → using '{trigger}'")
            else:
                trigger_counts[trigger] = 0
            
            # Add snippet
            snippet_lua, desc = cpp_to_lua_snippet(content, trigger, description)
            lua_content.append(f'  -- [{category}] {cpp_file.name}: {desc}')
            lua_content.append(snippet_lua)
            
            snippets_info.append((trigger, category, cpp_file.name, desc))
            
            # Track by category
            if category not in categories:
                categories[category] = []
            categories[category].append((trigger, cpp_file.name, desc))
            
        except Exception as e:
            print(f"  Error processing {cpp_file.name}: {e}")
            continue
    
    # Close the Lua table
    lua_content.append('}')
    
    # Write output file
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lua_content))
    
    print(f"\n✓ Created {output_file}")
    print(f"✓ Generated {len(snippets_info)} snippets")
    
    # Create a categorized README
    readme_path = output_path.parent / 'SNIPPETS.md'
    with open(readme_path, 'w') as f:
        f.write('# Competitive Programming Snippets for Neovim\n\n')
        f.write(f'**Total: {len(snippets_info)} snippets**\n\n')
        f.write('Source: [ncduy0303/Competitive-Programming](https://github.com/ncduy0303/Competitive-Programming)\n\n')
        
        # By category
        for category in sorted(categories.keys()):
            f.write(f'\n## {category}\n\n')
            f.write('| Trigger | Description |\n')
            f.write('|---------|-------------|\n')
            for trigger, filename, desc in sorted(categories[category]):
                f.write(f'| `{trigger}` | {desc} |\n')
        
        # Quick reference table
        f.write('\n## Quick Reference (Alphabetical)\n\n')
        f.write('| Trigger | Category | Description |\n')
        f.write('|---------|----------|-------------|\n')
        for trigger, cat, filename, desc in sorted(snippets_info):
            f.write(f'| `{trigger}` | {cat} | {desc} |\n')
    
    print(f"✓ Created {readme_path} with categorized snippet reference")
    print(f"\n📝 Categories found: {', '.join(sorted(categories.keys()))}")
    
    return True


def main():
    use_short = '--short-triggers' not in sys.argv
    
    if len(sys.argv) < 3:
        print("Usage: python3 cpp_to_luasnip_v2.py <cpp_directory> <output_file> [--short-triggers]")
        print("\nExample:")
        print("  git clone https://github.com/ncduy0303/Competitive-Programming.git")
        print("  python3 cpp_to_luasnip_v2.py ./Competitive-Programming ~/.config/nvim/snippets/cpp.lua")
        print("\nOptions:")
        print("  --short-triggers  Use short abbreviated triggers (enabled by default)")
        return
    
    cpp_directory = sys.argv[1]
    output_file = sys.argv[2]
    
    success = process_directory(cpp_directory, output_file, use_short)
    
    if success:
        print("\n" + "="*70)
        print("✨ SUCCESS! To use these snippets in Neovim:")
        print("="*70)
        print("\n1. Add to your Neovim config:")
        print('   require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})')
        print("\n2. Restart Neovim")
        print("\n3. In a .cpp file, type a trigger + Tab:")
        print("   - dsu → Disjoint Set Union")
        print("   - segtree → Segment Tree")
        print("   - dijkstra → Dijkstra's Algorithm")
        print("   - etc.")
        print("\n4. Check SNIPPETS.md for the full list!")
        print("="*70)


if __name__ == '__main__':
    main()
