import yaml
from jinja2 import Environment, FileSystemLoader
import html5lib

with open('tasks.yaml', 'r') as f:
    all_tasks = yaml.safe_load(f)

for category in all_tasks:
    category['id'] = category['name'].replace(' ', '-').lower()
    for task in category['tasks']:
        try:
            task['id'] = task['name'].replace(' ', '-').lower()
        except KeyError:
            print(f"Bad task: {task} within category {category['name']}")
            raise
        assert 'points' in task, f"Task {task['id']} has no points specified"

        # capitalise
        task['name'] = task['name'][0].upper() + task['name'][1:]

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('template.html.jinja')

rendered = template.render(all_tasks=all_tasks)

output_path = 'index.html'

with open(output_path, 'w') as f:
    f.write(rendered)


parser = html5lib.HTMLParser(strict=True)
with open(output_path, 'rb') as f:
    document = parser.parse(f)