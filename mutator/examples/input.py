def fun_1(a: Tuple[str, int] = ("asda", 11), b=3):
    a, b = a * b, a + b * a
    return a + b


def fun_2(a: int, b: int):
    return fun_1(a, b)


def fun_3(a, b, c):
    print(fun_2(a, fun_1(b, c)))


class A:
    # foo bar
    def a_fn1(self):
        pass


class B:
    def b_fn1(self, a: int = 1):
        print(a)
