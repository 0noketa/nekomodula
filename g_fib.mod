MODULE Global

(* public procedure *)
PROCEDURE fib(n)
(* expressions are inline Neko *)
VAR a = { i => 1, j => 0 }
    (* unlike Modula, local procedures cant rewrite to outer vars (just vars) *)
    PROCEDURE f()
    VAR i = a.i
    BEGIN
        a.i := a.i + a.j
        a.j := i
    END f
BEGIN
    WHILE n > 0 DO
        f()

        n := n - 1
    END

    RETURN a.i
END fib

(* minus-suffix means private procedure *)
PROCEDURE main-
VAR i
BEGIN
    FOR i := 0 TO 20 DO
        $print(fib(i) + "\n")
    END
END main

(* every initial routine never runs twice *)
BEGIN
    main()
END Global.
