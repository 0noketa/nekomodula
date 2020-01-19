(* C-like mergable module *)
MODULE Global

IMPORT g_hello
IMPORT g_fib
FROM Global IMPORT fib, hello

BEGIN
    $print("* main *\n")
    hello()
    $print("fib(7): " + fib(7) + "\n")
END Global.
