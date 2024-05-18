#!/usr/bin/env python


class Calc:
    def __init__(self, name: str) -> None:
        self.name = name

    def sum(self, a, b):
        return a + b

    def div(self, a, b):
        if b == 0:
            print(f"{self.name}: can't divide by zero in context of rings")

            return float("nan")
        else:
            return a / b
