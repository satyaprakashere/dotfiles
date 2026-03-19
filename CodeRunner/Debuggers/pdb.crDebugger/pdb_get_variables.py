def __cr_debugger_encode(d, seen, this_function, recurse_time=None, depth_limit=3, this_depth=0):
	try:
		import __builtin__ as b
	except ImportError:
		import builtins as b
	import time
	no_recurse = False
	if recurse_time == None:
		recurse_time = time.time()
	elif time.time()-recurse_time > 5.0:
		no_recurse = True
	import types
	l = []
	if this_depth > depth_limit:
		l.append({"name":"..."})
		return l
	i = -1
	for obj in d:
		try:
			i += 1
			key = i
			description = None
			if b.isinstance(d, b.type({})):
				key = obj
				obj = d[key]
			if __cr_debugger_variables_show_all == False and (b.hasattr(obj, '__call__') or b.isinstance(obj, (b.type, types.ModuleType)) or (b.hasattr(types, 'ClassType') and b.isinstance(obj, types.ClassType))):
				continue
			typename = b.type(obj).__name__
			if this_depth == depth_limit:
				count = -1
				if b.hasattr(obj, '__dict__'): count = b.len(obj.__dict__)
				elif b.hasattr(obj, '__slots__'): count = b.len(obj.__slots__)
				elif b.isinstance(obj, (b.type([]), b.type({}))): description = count = b.len(obj)
				if count != -1:
					description = str(count) + " item"
					if count != 1: description = description + "s"
			if not no_recurse:
				if b.hasattr(obj, '__dict__') and b.len(obj.__dict__):
					description = b.repr(obj)
					obj = obj.__dict__
				elif b.hasattr(obj, '__slots__') and b.len(obj.__slots__):
					description = b.repr(obj)
					obj = obj.__slots__
			if not no_recurse and b.isinstance(obj, (b.type([]), b.type({}))):
				found = False
				for item in seen:
					if item is obj:
						found = True
						break
				if found:
					obj = b.repr(obj)
				else:
					seen.append(obj)
					obj = this_function(obj, seen, this_function, recurse_time, depth_limit, this_depth+1)
					seen.pop()
			else:
				obj = b.repr(obj)
				if len(obj) > 1500:
					obj = obj[0:1500]+" [...]"
			result = {"name":b.str(key), "value":obj}
			if description != None:
				result["description"] = description
			result["type"] = typename
			l.append(result)
		except:
			continue
	return l

__cr_debugger_variables = locals().items()
if __cr_debugger_variables_show_all:
	__cr_debugger_variables = list(__cr_debugger_variables)
	__cr_debugger_variables.extend(globals().items())
__cr_debugger_variables = __cr_debugger_encode({k:v for (k,v) in __cr_debugger_variables if (__cr_debugger_variables_show_all == False and k[0:2] != '__') or (__cr_debugger_variables_show_all == True and k[0:5] != '__cr_')}, [], __cr_debugger_encode, None, __cr_debugger_variables_depth, 0)
from operator import itemgetter as __cr_debugger_itemgetter
__cr_debugger_variables.sort(key=__cr_debugger_itemgetter('name'))
from json import dumps as __cr_debugger_dumps
print(__cr_debugger_dumps(__cr_debugger_variables))
del __cr_debugger_variables
del __cr_debugger_encode
del __cr_debugger_dumps
del __cr_debugger_itemgetter
del __cr_debugger_variables_show_all
del __cr_debugger_variables_depth
