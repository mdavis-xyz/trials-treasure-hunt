import yaml
from jinja2 import Environment, FileSystemLoader
import html5lib

with open('tasks.yaml', 'r') as f:
    all_tasks = yaml.safe_load(f)

env = Environment(loader=FileSystemLoader('.'))
template = env.get_template('template.html.jinja')

rendered = template.render(all_tasks=all_tasks)

output_path = 'index.html'

with open(output_path, 'w') as f:
    f.write(rendered)


parser = html5lib.HTMLParser(strict=True)
with open(output_path, 'rb') as f:
    document = parser.parse(f)