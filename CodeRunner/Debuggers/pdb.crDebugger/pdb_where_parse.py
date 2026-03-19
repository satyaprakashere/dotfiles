import re
import json
from sys import stdin
locations = []
for line in stdin:
	match = re.search(r"^(>)?\s+((?:<string>)|(?:(?:/.*)))\((\d+)\)(.*?)(->.*)?$", line.strip("\r\n"))
	if match:
		current = match.group(1) != None
		file = match.group(2)
		line = match.group(3)
		name = match.group(4)
		if name == "<module>()":
			name = None
		d = {
			"file": file,
			"line": line,
			"current": current
		}
		if name:
			d["name"] = name
		locations.append(d)
locations.reverse()
print(json.dumps(locations))
