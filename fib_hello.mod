MODULE fib_hello

IMPORT hello AS h
IMPORT fib
FROM h IMPORT hello

BEGIN
    $print("* main *\n")
    hello()
    $print("fib(7): " + fib.fib(7) + "\n")
END fib_hello.
