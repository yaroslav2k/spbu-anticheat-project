import libcst

from visitors.abstract_visitor import AbstractVisitor


class FunctionInvocationCollector(AbstractVisitor):
    class Result(AbstractVisitor.Result):
        def __init__(self) -> None:
            self.data: dict = {}

        def add(self, node: libcst.Call):
            self.data[hash(node)] = node

    def __init__(self) -> None:
        self.result = self.Result()

    def visit_Call(self, node: libcst.Call) -> bool:
        self.result.add(node)

        return False
