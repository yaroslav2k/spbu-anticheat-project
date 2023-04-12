import libcst as cst
from typing import Optional


class FunctionInvocationCollector(cst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data = {}

        def add(self, node: cst.Call):
            self.data[hash(node)] = node

    def visit_Call(self, node: cst.Call) -> Optional[bool]:
        self.result.add(node)

    def __init__(self) -> None:
        self.result = self.Result()
