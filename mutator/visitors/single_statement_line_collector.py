from typing import Optional

import libcst


class SingleStatementLineCollector(libcst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data: dict = {}

        def add(self, node: libcst.SimpleStatementLine):
            self.data[hash(node)] = node

    def __init__(self) -> None:
        self.result = self.Result()

    def visit_SimpleStatementLine(
        self, node: libcst.SimpleStatementLine
    ) -> Optional[bool]:
        self.result.add(node)

        return False
