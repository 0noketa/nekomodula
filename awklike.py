
# AWK-like text processing

# from: \/(.*)\/ \{
# to: @awklike.add("""$1""")\ndef f(args):\n

import re


class Awklike:
	def __init__(self):
		self.ptns = []

	def add(self, regex):
		def deco(f):
			self.ptns += [(regex, f)]

			return f

		return deco

	def run(self, strm):
		def ipt():
			try:
				self.line = strm.readline().strip()

				return True
			except:
				self.line = ""

				return False

		while ipt():
			for k, f in self.ptns:
				m = re.match(k, self.line)

				if m:
					args = [self.line, *m.groups()]
					#print(args)
					f(args)

					break


default_awl = Awklike()

def add(regex):
	return default_awl.add(regex)

def run(strm):
	return default_awl.run(strm)

