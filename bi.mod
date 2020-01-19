MODULE bi

CONST idiv10- = BINDR(IDIV, 10)
CONST mod10- = BINDR(MOD, 10)
CONST eq0- = BIND(EQ, 0)
CONST neq0- = BIND(NEQ, 0)
CONST eq48- = BIND(EQ, 48)
CONST neq48- = BIND(NEQ, 48)

PROCEDURE fromInt(z, n)
VAR r: ARRAY[z]
VAR i
BEGIN
    FOR i := 0 TO z DO
        IF n > 0 THEN
            r[i] := MOD(n, 10)
            n := IDIV(n, 10)
        ELSE
            r[i] := 0
        END
    END

    RETURN r
END fromInt

PROCEDURE fromStr(z, s)
VAR cs = WRAP(s)
VAR r: ARRAY[z]
VAR i
BEGIN
    FOR i := 0 TO z DO
        IF i < cs.len THEN
            r[i] := MOD(ABS(cs[cs.len - i - 1] - 48), 10)
        ELSE
            r[i] := 0
        END
    END

    RETURN r
END fromStr

PROCEDURE bi(z, n)
BEGIN
    IF $typeof(n) == $tstring THEN
        RETURN fromStr(z, n)
    ELSIF $typeof(n) == $tint THEN
        RETURN fromInt(z, n)
    ELSE
        RETURN fromInt(z, 0)
    END
END bi

PROCEDURE shl(a)
VAR i
VAR z = LENGTH(a)
VAR r: ARRAY[z]
BEGIN
    FOR i := 0 TO z - 1 DO
        r[z - i - 1] := a[z - i - 2]
    END

    IF z > 0 THEN
        r[0] := 0
    END

    RETURN r
END shl

PROCEDURE shr(a)
VAR i
VAR z = LENGTH(a)
VAR r: ARRAY[z]
BEGIN
    FOR i := 0 TO z - 1 DO
        r[i] := a[i + 1]
    END

    IF z > 0 THEN
        r[z - 1] := 0
    END

    RETURN r
END shr

PROCEDURE iszero(a)
BEGIN
    RETURN COUNT(neq0, a) == 0
END iszero


PROCEDURE print(a)
VAR i
BEGIN
    FOR i := 0 TO LENGTH(a) DO
        $print(a[LENGTH(a) - i - 1])
    END
END print

PROCEDURE println(a)
BEGIN
    print(a)
    $print("\n")
END println

PROCEDURE add(x, y)
VAR tmp = ZIP(ADD, x, y)
VAR c = MAP(idiv10, tmp)
VAR z = MAP(mod10, tmp)
BEGIN
    WHILE NOT(iszero(c)) DO
        tmp := ZIP(ADD, z, shl(c))
        c := MAP(idiv10, tmp)
        z := MAP(mod10, tmp)
    END

    RETURN z
END add

VAR c
VAR a, b, o
VAR i

BEGIN
    c := 8
    IF LENGTH(ARGS) > 0 THEN
        c := INT(ARGS[0])
    END

    a := 0
    IF LENGTH(ARGS) > 1 THEN
        a := ARGS[1]

        $print(INDICES(eq48, a) + "\n")
    END

    a := bi(c, a)

    println(a)

    i := 2
    WHILE i + 1 < LENGTH(ARGS) DO
        o := ARGS[i]
        b := bi(c, ARGS[i + 1])

        IF o == "+" THEN
            a := add(a, b)
        ELSE
            $print("unknown operator " + ARGS[i] + "\n")
            EXIT WHILE
        END

        println(a)

        i := i + 2
    END

END bi.
