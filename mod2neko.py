
# Modula-like language for Neko
import sys
import re
import awklike as awkl


localVars=[set()]
loopTypes=[]
forCounters=[]
procDpt=0; procName=""
globalMod=False
exportsRef="$exports"

print("""
var NIL = null, TRUE = true, FALSE = false;
""")

if len(sys.argv) < 2 or sys.argv[1] != "-nostdlib":
	print("""
var ARGS = $loader.args;
var nekomod = $loader.loadmodule("nekomod", $loader);
""")

	for i in [
			"ADD", "SUB", "MUL", "DIV", "IDIV", "MOD", "ABS",
			"EQ", "NEQ", "LT", "LTE", "GT", "GTE", "NOT",
			"MIN", "MAX", "LEN", "LENGTH",
			"BIND", "BINDR", "COMPOSE",
			"INT", "REAL", "STR", "BOOL",
			"WRAP", "UNWRAP",
			"MAKEARRAY", "MAKEWRAP",
			"MAP", "ZIP", "COUNT", "FILTER", "INDEX", "INDICES"]:
		print("var " + i + " = nekomod." + i)

def loopTypeIs(n):
	r = False
	loopTypes.reverse()

	for i in loopTypes:
		if i not in ["WHILE", "FOR", "IIF"]:
			continue

		if i == n:
			r = True
		break

	loopTypes.reverse()

	return r

ttable = {
	"INTEGER": "INT",
	"INT": "INT",
	"STRING": "STR",
	"STR": "STR",
	"REAL": "REAL",
	"FLOAT": "REAL",
	"BOOLEAN": "BOOL",
	"BOOL": "BOOL"
}

def IsTypeName(t):
	return t in ttable.keys()

def converterForType(t):
	if IsTypeName(t):
		return ttable[t]
	else:
		return "error type " + t

def putVarInit(name, sgn, val):
	global procDpt
	if procDpt == 0 and sgn != "-":
		print("var " + name + " = " + exportsRef + "." + name + " = " + val)
	else:
		print("var " + name + " = " + val)


@awkl.add("""NEKO\s+(.+)\s+END""")
def f(args):
	print(args[1] + ";")
@awkl.add("""(\(\*\s*.*\s*\*\))""")
def f(args):
	print("//" + args[1])
@awkl.add("""MODULE\s+([a-zA-Z][a-zA-Z0-9_]*)""")
def f(args):
	global exportsRef
	print("/*module " + args[1] + " */")
	if args[1] == "Global":
		print("/* global */")
		print("var Global = $loader.loadmodule(\"Global\", $loader);")
		globalMod = True
		exportsRef = "Global"
@awkl.add("""IMPORT\s+([a-zA-Z][a-zA-Z0-9_]*)\s+AS\s+([a-zA-Z][a-zA-Z0-9_]*)""")
def f(args):
	print("var " + args[2] + " = $loader.loadmodule(\"" + args[1] + "\", $loader);")
@awkl.add("""IMPORT\s+([a-zA-Z][a-zA-Z0-9_]*)""")
def f(args):
	print("var " + args[1] + " = $loader.loadmodule(\"" + args[1] + "\", $loader);")
@awkl.add("""FROM\s+([a-zA-Z][a-zA-Z0-9_]*)\s+IMPORT\s+([a-zA-Z][a-zA-Z0-9_]*(?:\s*,\s*[a-zA-Z][a-zA-Z0-9_]*)*)""")
def f(args):
	for elm in args[2].split(","):
		elm = elm.strip()
		print("var " + elm + " = " + args[1] + "." + elm + ";")
@awkl.add("""(PROCEDURE)\s+([a-zA-Z][a-zA-Z0-9_]*)(|\-)\s*\((\s*[a-zA-Z][a-zA-Z0-9_]*(?:\s*,\s*[a-zA-Z][a-zA-Z0-9_]*)*\s*)\)""")
def f(args):
	global procDpt, procName

	putVarInit(args[2], args[3], " function(" + args[4] + ") {")
	procDpt += 1; procName=args[2]

@awkl.add("""(PROCEDURE)\s+([a-zA-Z][a-zA-Z0-9_]*)(|\-)""")
def f(args):
	global procDpt, procName

	putVarInit(args[2], args[3], " function() {")
	procDpt += 1; procName=args[2]

@awkl.add("""CONST\s+([a-zA-Z][a-zA-Z0-9_]*)(|\-)\s*\=\s*(.*)""")
def f(args):
	putVarInit(args[1], args[2], args[3] + ";")
@awkl.add("""VAR\s+([a-zA-Z][a-zA-Z0-9_]*)(|\-)\s*\:\s*ARRAY\s*\[(.*)\]""")
def f(args):
	putVarInit(args[1], args[2], "$amake(" + args[3] + ");")
@awkl.add("""VAR\s+([a-zA-Z][a-zA-Z0-9_]*)\s*\:\s*ARRAY\s*\[(.*)\]\s*OF\s+CHAR""")
def f(args):
	putVarInit(args[1], args[2], "$smake(" + args[3] + ");")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*(\:)\s*ARRAY\s+OF\s+(INT(?:|EGER)|REAL|FLOAT|STR(?:|ING)|BOOL(?:|EAN))\s*(\=)\s*(.*)""")
def f(args):
	print("var " + args[2] + "=MAP(" + converterForType(args[4]) + ", " + args[6] + ");")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*(\:)\s*KEYS\s+OF\s+(.*)""")
def f(args):
	print("var " + args[2] + "=$fields(" + args[4] + ");")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*(\:)\s*(INT(?:|EGER)|REAL|FLOAT|STR(?:|ING)|BOOL(?:|EAN))\s*(\=)\s*(.*)""")
def f(args):
	print("var " + args[2] + "=" + converterForType(args[4]) + "(" + args[5] + ");")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*(\=)\s*\[(.*)\]""")
def f(args):
	print("var " + args[2] + "=$array(" + args[4] + ");")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*(\=)\s*(.*)""")
def f(args):
	print("var " + args[2] + "=" + args[4] + ";")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*(\:)\s*(.*)""")
def f(args):
	print("var " + args[2] + "=" + args[4] + ";")
@awkl.add("""(VAR)\s+([a-zA-Z][a-zA-Z0-9_]*(?:\s*,\s*[a-zA-Z][a-zA-Z0-9_]*)*)""")
def f(args):
	print("var " + args[2] + ";")
@awkl.add("""(BEGIN)""")
def f(args):
	global procDpt
	if not procDpt:
		print("/* BEGIN */")
@awkl.add("""(FOR)\s+([a-zA-Z][a-zA-Z0-9_]*(?:\.[a-zA-Z][a-zA-Z0-9_]*)*(?:|\[.+\]))\s*(\:\=)\s*([a-zA-Z0-9\+\-\*\/\<\>\=\!\#\&\|\(\)\[\]\$\"\.\, ]+)\s+(TO)\s+([a-zA-Z0-9\+\-\*\/\<\>\=\!\#\&\|\(\)\[\]\$\"\.\, ]+)\s+(DO)""")
def f(args):
	global loopTypes, forCounters
	print(args[2] + "=" + args[4] + "; while (" + args[2] + " < " + args[6] + ") {")
	loopTypes += ["FOR"]
	forCounters += [args[2]]
@awkl.add("""(ELSIF)\s+([a-zA-Z0-9\+\-\*\/\<\>\=\!\#\&\|\(\)\[\]\$\"\.\, ]+)\s+(THEN)""")
def f(args):
	print("} else if (" + args[2] + ") {")
@awkl.add("""(IF)\s+([a-zA-Z0-9\+\-\*\/\<\>\=\!\#\&\|\(\)\[\]\$\"\.\, ]+)\s+(THEN)""")
def f(args):
	global loopTypes
	print("if (" + args[2] + ") {")
	loopTypes += ["IF"]
@awkl.add("""([a-zA-Z][a-zA-Z0-9_]*(?:\.[a-zA-Z][a-zA-Z0-9_]*)*(?:|\[.+\]))\s*(\:\=)\s*(IF)\s+([a-zA-Z0-9\+\-\*\/\<\>\=\!\#\&\|\(\)\[\]\$\"\.\, ]+)\s+(THEN)""")
def f(args):
	global loopTypes
	print(args[1] + " = if (" + args[4] + ") {")
	loopTypes += ["IIF"]
@awkl.add("""(WHILE)\s+([a-zA-Z0-9\+\-\*\/\<\>\=\!\#\&\|\(\)\[\]\$\"\.\, ]+)\s+(DO)""")
def f(args):
	global loopTypes
	print("while (" + args[2] + ") {")
	loopTypes += ["WHILE"]
@awkl.add("""ELSE""")
def f(args):
	print("} else {")
@awkl.add("""EXIT\s+(FOR|WHILE)""")
def f(args):
	global loopTypes
	if len(loopTypes) and loopTypeIs(args[1]):
		print("break;")
	else:
		print("error EXIT " + args[1])
@awkl.add("""(RETURN)\s+(.*)""")
def f(args):
	print("return " + args[2] + ";")
@awkl.add("""(END)\s+([a-zA-Z][a-zA-Z0-9_]*)\s*\.""")
def f(args):
	exit()
@awkl.add("""(END)\s+([a-zA-Z][a-zA-Z0-9_]*)""")
def f(args):
	global procDpt
	procDpt-=1; print("}")
@awkl.add("""(END)""")
def f(args):
	global forCounters
	if len(loopTypes):
		t = loopTypes.pop()

		if t == "FOR":
			i = forCounters.pop()
			print(i + " += 1")

		print("} // end " + t)
	else:
		print("}")
@awkl.add("""([a-zA-Z][a-zA-Z0-9_]*(?:\.[a-zA-Z][a-zA-Z0-9_]*)*(?:|\[.+\]))\s*(\:\=)\s*\[(.*)\]""")
def f(args):
	print(args[1] + "=$array(" + args[2] + ");")
@awkl.add("""([a-zA-Z][a-zA-Z0-9_]*(?:\.[a-zA-Z][a-zA-Z0-9_]*)*(?:|\[.+\]))\s*(\:\=)\s*(.*)""")
def f(args):
	print(args[1] + " = " + args[3] + ";")
@awkl.add("""(.+)""")
def f(args):
	print(args[1] + ";")


awkl.run(sys.stdin)
