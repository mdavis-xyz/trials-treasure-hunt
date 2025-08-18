import yaml
from jinja2 import Environment, FileSystemLoader
import html5lib
import os
import shutil
from pathlib import Path

target_dir = Path('docs')

lang = "fr"

with open('tasks.yaml', 'r') as f:
    all_tasks = yaml.safe_load(f)

def capitalise(s): 
    return s[0].upper() + s[1:]


all_tasks = [c for c in all_tasks if not c.get('example')]

for category in all_tasks:
    category['id'] = category['name'][lang].replace(' ', '-').lower()
    for task in category['tasks']:
        try:
            task['id'] = task['name'][lang].replace(' ', '-').lower()
        except KeyError:
            print(f"Bad task: {task} within category {category['name'][lang]}")
            raise
        assert 'points' in task, f"Task {task['id']} has no points specified"

        # capitalise
        assert lang in task['name'], f"Task {task['name']} has no entry for {lang}"
        task['name'][lang] = capitalise(task['name'][lang])

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('template.html.jinja')

rendered = template.render(all_tasks=all_tasks, lang=lang)

# empty the build dir
if target_dir.exists():
    shutil.rmtree(target_dir)
target_dir.mkdir()

output_path = target_dir / 'index.html'

with open(output_path, 'w') as f:
    f.write(rendered)


parser = html5lib.HTMLParser(strict=True)
with open(output_path, 'rb') as f:
    document = parser.parse(f)

# copy across only the (small) media we need
# not the full raw data
for category in all_tasks:
    for task in category['tasks']:
        for media_type in ['photos', 'video', 'iframes']:
            for media in task.get("details", {}).get(media_type, []):
                src_path = Path(media['path'])
                dest_path = target_dir / src_path.relative_to('.')
                
                print(f"Copying {src_path} to {dest_path}")
                dest_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src_path, dest_path)

for src_path in ["script.js", "styles.css"]:
    dest_path = target_dir / src_path
    print(f"Copying {src_path} to {dest_path}")
    shutil.copy2(src_path, dest_path)