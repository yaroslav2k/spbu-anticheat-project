import math

def func_a(a: int, b: int):
    c = b - (a % 2)
    stat = "foobar"

    if c > 2:
        c -= 1
        stat = "foo" + str(c)

    while a < 100:
        a = math.pow(a, 2)

    return (c + a, stat)

def func_b(a, b):
    c = -1 * (a % 2) + b
    stat = "foo"

    if c > 2:
        c -= 1
        stat = "foo" + str(c)
    else:
        stat += "bar"

    while a > 100:
        a = math.pow(2)

    result = (c + a, stat)

    return result