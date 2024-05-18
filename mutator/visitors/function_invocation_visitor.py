from typing import Optional

import libcst as cst

from visitors.abstract_visitor import AbstractVisitor


class FunctionInvocationCollector(AbstractVisitor):
    class Result(AbstractVisitor.Result):
        def __init__(self) -> None:
            self.data = {}

        def add(self, node: cst.Call):
            self.data[hash(node)] = node

    def __init__(self) -> None:
        self.result = self.Result()

    def visit_Call(self, node: cst.Call) -> Optional[bool]:
        self.result.add(node)
