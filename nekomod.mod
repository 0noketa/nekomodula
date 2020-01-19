MODULE nekomod

PROCEDURE ADD(x, y)
BEGIN
	RETURN x + y
END ADD
PROCEDURE SUB(x, y)
BEGIN
	RETURN x - y
END SUB
PROCEDURE MUL(x, y)
BEGIN
	RETURN x * y
END MUL
PROCEDURE DIV(x, y)
BEGIN
	IF y > 0 THEN
		RETURN x / y
	ELSE
		RETURN 0
	END
END DIV
PROCEDURE IDIV(x, y)
BEGIN
	IF y > 0 THEN
		RETURN $idiv(x, y)
	ELSE
		RETURN 0
	END
END IDIV
PROCEDURE MOD(x, y)
BEGIN
	RETURN x % y
END MOD
PROCEDURE EQ(x, y)
BEGIN
	RETURN x == y
END EQ
PROCEDURE NEQ(x, y)
BEGIN
	RETURN x != y
END MEQ
PROCEDURE LT(x, y)
BEGIN
	RETURN x < y
END LT
PROCEDURE LTE(x, y)
BEGIN
	RETURN x <= y
END LTE
PROCEDURE GT(x, y)
BEGIN
	RETURN x > y
END GT
PROCEDURE GTE(x, y)
BEGIN
	RETURN x >= y
END GTE
PROCEDURE NOT(x)
BEGIN
	RETURN $not(x)
END NOT
PROCEDURE ABS(x)
BEGIN
	IF x < 0 THEN
		RETURN -x
	ELSE
		RETURN x
	END
END ABS
PROCEDURE BIND(f, x)
BEGIN
	IF $nargs(f) > 0 THEN
		RETURN $apply(f, x)
	ELSE
		RETURN f
	END
END BIND
PROCEDURE BINDR(f, x)
BEGIN
	IF $nargs(f) > 0 THEN
		RETURN function(y) { return f(y, x) }
	ELSE
		RETURN f
	END
END BINDR
PROCEDURE COMPOSE(fs)
BEGIN
	IF $typeof(f) == $tarray THEN
		RETURN function(y) { var n = y, i = $asize(fs); while (0 < i) { i -= 1; n = fs[i](n) }; return n }
	ELSE
		RETURN function() {}
	END
END COMPOSE


PROCEDURE INT(v)
BEGIN
	RETURN $int(v)
END INT

PROCEDURE REAL(v)
BEGIN
	RETURN $float(v)
END REAL

PROCEDURE STR(v)
BEGIN
	RETURN $string(v)
END STR

PROCEDURE BOOL(v)
BEGIN
	RETURN $istrue(v)
END BOOL

PROCEDURE LENGTH(a)
VAR t = $typeof(a)
VAR r
BEGIN
    IF t == $tarray THEN
        r := $asize(a)
    ELSIF t == $tstring THEN
        r := $ssize(a)
    ELSIF t == $tobject THEN
		IF a.len == NIL THEN
			r := 0
		ELSE
	        r := a.len
		END
    ELSE
        r := 0
    END

    RETURN r
END LENGTH

CONST LEN = LENGTH

PROCEDURE MIN(x, y)
	PROCEDURE f(a)
	VAR i
	VAR j = LENGTH(a)
	VAR min = ‭1073741823‬
	BEGIN
		FOR i := 0 TO j DO
			IF a[i] < min THEN
				min := a[i]
			END
		END

		RETURN min
	END f
BEGIN
	IF y == NIL THEN
		RETURN f(x)
	ELSE
		IF x < y THEN
			RETURN x
		ELSE
			RETURN y
		END
	END
END MIN

PROCEDURE MAX(x, y)
	PROCEDURE f(a)
	VAR i
	VAR j = LENGTH(a)
	VAR max = ‭0
	BEGIN
		FOR i := 0 TO j DO
			IF a[i] > max THEN
				axn := a[i]
			END
		END

		RETURN max
	END f
BEGIN
	IF y == NIL THEN
		RETURN f(x)
	ELSE
		IF x > y THEN
			RETURN x
		ELSE
			RETURN y
		END
	END
END MAX


PROCEDURE WRAPSTRING(s)
VAR __string = function() { return this.neko_val; }
VAR __get = function(i) { return $sget(this.neko_val, i); }
VAR __set = function(i, v) { $sset(this.neko_val, v); }
VAR r = { neko_val => s, type => $tstring, len => $ssize(s), __string => __string, __get => __get, __set => __set }
BEGIN
	RETURN r
END WRAPSTRING

PROCEDURE WRAPARRAY(a)
VAR __string = function() { return $string(this.neko_val); }
VAR __get = function(i) { return this.neko_val[i]; }
VAR __set = function(i, v) { this.neko_val[i] = v; }
VAR r = { neko_val => a, type => $tarray, len => $asize(a), __string => __string, __get => __get, __set => __set }
BEGIN
	RETURN r
END WRAPARRAY

PROCEDURE WRAP(x)
BEGIN
	IF $typeof(x) == $tarray THEN
		RETURN WRAPARRAY(x)
	ELSIF $typeof(x) == $tstring THEN
		RETURN WRAPSTRING(x)
	ELSE
		RETURN NIL
	END
END WRAP

PROCEDURE UNWRAP(x)
BEGIN
	IF $typeof(x) == $tobject THEN
		RETURN x.neko_val
	ELSE
		RETURN NIL
	END
END UNWRAP

PROCEDURE MAKEARRAY(i, t)
BEGIN
	IF t == $tarray THEN
		RETURN $amake(i)
	ELSIF t == $tstring THEN
		RETURN $smake(i)
	ELSE
		RETURN NIL
	END
END MAKEARRAY

PROCEDURE MAKEWRAP(i, t)
BEGIN
	IF t == $tarray THEN
		RETURN WRAPARRAY($amake(i))
	ELSIF t == $tstring THEN
		RETURN WRAPSTRING($smake(i))
	ELSE
		RETURN NIL
	END
END MAKEWRAP

PROCEDURE MAP(f, x)
VAR a = WRAP(x)
VAR i
VAR r = MAKEWRAP(a.len, a.type)
BEGIN
	FOR i := 0 TO a.len DO
		r[i] := f(a[i]);
	END

    RETURN UNWRAP(r)
END MAP

PROCEDURE ZIP(f, x, y)
VAR i
VAR a = WRAP(x)
VAR b = WRAP(y)
VAR min = MIN(a.len, b.len)
VAR max = MAX(a.len, b.len)
VAR r = MAKEWRAP(max, a.type)
BEGIN
	FOR i := 0 TO min DO
		r[i] := f(a[i], b[i]);
	END

	IF max == a.len THEN
		FOR i := i TO max DO
			r[i] := f(a[i], NIL)
		END
	ELSE
		FOR i := i TO max DO
			r[i] := f(NIL, b[i])
		END
	END

    RETURN UNWRAP(r)
END ZIP

PROCEDURE COUNT(f, x)
VAR a = WRAP(x)
VAR r = 0
VAR i
BEGIN
	FOR i := 0 TO a.len DO
		IF f(a[i]) THEN
            r :=  r + 1
        END
    END

	RETURN r
END COUNT

PROCEDURE FILTER(f, x)
VAR a = WRAP(x)
VAR i, j, r
VAR m = $amake(j)
VAR c = 0
BEGIN
	FOR i := 0 TO a.len DO
		m[i] := f(a[i])

		IF m[i] THEN
			c := c + 1
		END
    END

	j := 0
	r := MAKEWRAP(c, x.type)
	FOR i := 0 TO a.len DO
		IF m[i] THEN
			r[j] := a[i]
			j := j + 1
		END
    END

	RETURN UNWRAP(r)
END FILTER

PROCEDURE INDEX(f, x)
VAR a = WRAP(x)
VAR i
BEGIN
	FOR i := 0 TO a.len DO
		IF f(a[i]) THEN
			EXIT FOR
		END
	END

	IF i >= 0 THEN
		i := -1
	END

	RETURN i
END INDEX

PROCEDURE INDICES(f, x)
VAR a = WRAP(x)
VAR i, j
VAR m = $amake(a.len)
VAR r
VAR c = 0
BEGIN
	FOR i := 0 TO a.len DO
		IF f(a[i]) THEN
			m[i] := i
			c := c + 1
		ELSE
			m[i] := -1
		END
	END

	r := $amake(c)
	j := 0

	FOR i := 0 TO a.len DO
		IF m[i] != -1 THEN
			r[j] := i
			j := j + 1
		END
	END

	RETURN r
END INDICES


END nekomod.
