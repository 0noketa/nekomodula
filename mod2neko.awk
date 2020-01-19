/* dirty! */
BEGIN { procDpt=0; procName=""; entry=0
	print "var argv=$loader.args, argc=$asize($loader.args)"
	print "LEN=function(a){var t=$typeof(a);return if(t==$tarray)$asize(a) else if(t==$tstring)$ssize(a)else 0;};"
}
function m(){ return ++matched == 1 }
{ matched=0 }

/\(\*[ ]+.*[ ]+\*\)/ { m() }
/MODULE[ ]+[a-zA-Z]/ { if (m()) print "/*module " $2 " */" }
/IMPORT[ ]+[a-zA-Z]/ { if (m()) print "var " $2 " = $loader.loadmodule(\"" $2 "\", $loader);" $2 ".init()" }
/PROCEDURE[ ]+([a-zA-Z]+)[ ]*\(+[a-zA-Z]+(\,[a-zA-Z]+)*\)/ { if (m()) {
	++procDpt; procName=$2
	if (procDpt == 1)
		print "var " $2 " = $exports." $2 " = function" $3 "{"
	else
		print "var " $2 " = function" $3 "{"
} }
/PROCEDURE[ ]+[a-zA-Z]/ { if (m()) {
	++procDpt; procName=$2
	if (procDpt == 1)
		print "var " $2 " = $exports." $2 " = function(){"
	else
		print "var " $2 " = function(){"
} }
/VAR[ ]+[a-zA-Z]+[ ]*\:[ ]*.*/ { if (m()) print "var " $2 "=" $4 ";" }
/VAR[ ]+[a-zA-Z]+(\,[a-zA-Z]+)*/ { if (m()) print "var " $2 ";" }
/BEGIN/ { if(m() && !procDpt) { print "/* entry */"; print "$exports.init = function() {"; entry=1 } }
/FOR[ ]+[a-zA-Z]+[ ]+\:\=[ ]+[a-zA-Z0-9]+[ ]+TO[ ]+[a-zA-Z0-9]+[ ]+DO/ { if (m()) {
	print "for " $2 "=" $4 " to " $6 " {" }}
/ELSIF[ ]+[a-zA-Z0-9\+\-\*\/\<\>\=\#\&\|]+[ ]+THEN/ {
	if (m()) print "} else if (" $2 ") {"
}
/IF[ ]+[a-zA-Z0-9\+\-\*\/\<\>\=\#\&\|]+[ ]+THEN/ {
	if (m()) print "if (" $2 ") {"
}
/WHILE[ ]+[a-zA-Z0-9\+\-\*\/\<\>\=\#\&\|]+[ ]+DO/ {
	if (m()) print "while (" $2 ") {"
}
/ELSE/ {
	if (m()) print "} else {"
}
/RETURN[ ]+[a-zA-Z0-9]*/ { if (m()) {
	print "return " $2 ";"
} }
/END[ ]+[a-zA-Z]+[ ]+\./ { if (m()) { print "$exports.init=function(){};"; if (entry) print "}"; print "$exports.init();"; exit } }
/END[ ]+[a-zA-Z]/ { if (m()) { --procDpt; print "}" } }
/END/ { if (m()) print "}" }
/[a-zA-Z][a-zA-Z0-9]*[ ]+\:\=[ ]+[a-zA-Z0-9]*/ { if (m()) print $1 " = " $2 ";" }
/[a-zA-Z][a-zA-Z0-9\+\-\*\/\<\>\=\#\(\)]*[\+\-\*\/\<\>\=\#\(\)]+[a-zA-Z0-9\+\-\*\/\<\>\=\#\(\)]*/ { if (m()) {
	print $1 ";" } }
/[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)*/ { if (m()) print $1 "();" }
/[a-zA-Z0-9]+/ { if (m()) print $1 ";" }

