import os
import re

fixed_count = 0

for root, dirs, files in os.walk('.'):
    if '.git' in root:
        continue
    for f in files:
        if not f.endswith('.md'):
            continue
        filepath = os.path.join(root, f)
        try:
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()

            def fix_tags(match):
                tags_str = match.group(1)
                tags = [t.strip() for t in tags_str.split(',')]
                quoted = ', '.join(['"' + t + '"' for t in tags])
                return 'tags: [' + quoted + ']'

            new_content = re.sub(
                r'^tags:\s*\[([^\]]+)\]',
                fix_tags,
                content,
                flags=re.MULTILINE
            )

            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(new_content)
                fixed_count += 1
                print(f"Fixed: {filepath}")
        except Exception as e:
            print(f"Error: {filepath}: {e}")

print(f"\nTotal fixed: {fixed_count} files")
