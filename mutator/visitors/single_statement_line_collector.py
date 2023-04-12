import libcst as cst
from typing import Optional


class SingleStatementLineCollector(cst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data = {}

        def add(self, node: cst.Call):
            self.data[hash(node)] = node

    def __init__(self) -> None:
        self.result = self.Result()

    def visit_SimpleStatementLine(
        self, node: cst.SimpleStatementLine
    ) -> Optional[bool]:
        self.result.add(node)
