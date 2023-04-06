def fun_1(a, b=3):
    a, b = a * b, a + b * a
    return a + b


def fun_2(a: int, b: int):
    return fun_1(a, b)


def fun_3(a, b, c):
    print(fun_2(a, fun_1(b, c)))
