#!/usr/bin/env python3

from __future__ import print_function
import json
import sys
data = sys.stdin.read()
t = None
i = -1
for obj in json.JSONDecoder().decode(data):
	i += 1
	if t == "dict":
		if obj["name"].isdigit():
			print("["+obj["name"]+"]", end="")
		else:
			print("['"+obj["name"]+"']", end="")
	elif t == "list":
		print("["+obj["name"]+"]", end="")
	elif i > 0:
		print("."+obj["name"], end="")
	else:
		print(obj["name"], end="")
	t = obj["type"]
