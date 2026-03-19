def main():
	import os
	if "CR_SANDBOXED" in os.environ:
		def input_func(prompt = ""):
			prompt = str(prompt)
			import sys
			if prompt:
				sys.stdout.write(prompt)
				sys.stdout.flush()
			line = sys.stdin.readline()
			if not len(line):
				raise EOFError
			else:
				line = line.rstrip('\r\n')
			return line
		try:
			import __builtin__ as b
		except ImportError:
			import builtins as b
		if hasattr(b, 'raw_input'):
			def input(prompt = ""):
				return eval(raw_input(prompt))
			b.raw_input = input_func
			b.input = input
		else:
			b.input = input_func

	import remote_pdb
	import sys
	import pdb
	filename = os.environ.get("CR_FILENAME")
	path = os.environ.get("PWD") + "/" + filename
	sys.argv[0] = filename
	sys.path.insert(0, os.environ.get("PWD"))
	port = int(os.environ.get("CR_RUNID"))
	p = remote_pdb.RemotePdb("127.0.0.1", port)
	p.mainpyfile = path
	try:
		if hasattr(p, "_run"):
			p._run(pdb._ScriptTarget(p.mainpyfile))
		elif hasattr(p, "_runscript"):
			p._runscript(p.mainpyfile)
	except SystemExit:
		status = int(str(sys.exc_info()[1]))
		exit(status)
	except:
		status = sys.exc_info()[1]
		import traceback
		traceback.print_exc()
		t = sys.exc_info()[2]
		p.interaction(None, t)
		exit(status)

if __name__ == '__main__':
	main()
