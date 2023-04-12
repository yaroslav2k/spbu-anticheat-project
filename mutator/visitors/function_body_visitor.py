import libcst as cst
from typing import Optional


class FunctionBodyCollector(cst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data = {}

        def add(self, class_name: str, function_name: str, body: str):
            self.data[(class_name, function_name)] = body

    class ResultPrinter:
        def __init__(self, result) -> None:
            self.result = result

        def call(self):
            for (class_name, function_name), value in self.result.data.items():
                print(class_name, function_name)
                print(value)

    def __init__(self) -> None:
        self.stack = []
        self.result = self.Result()
        self.module = cst.parse_module("")

    def visit_ClassDef(self, node: cst.ClassDef) -> Optional[bool]:
        self.stack.append(node.name.value)

    def leave_ClassDef(self, node: cst.ClassDef) -> None:
        self.stack.pop()

    def visit_FunctionDef(self, node: cst.FunctionDef) -> Optional[bool]:
        code = self._get_code_no_empty_leading_lines(node)
        if len(self.stack) > 0:
            self.result.add(self.stack[-1], node.name.value, code)
        else:
            self.result.add("", node.name.value, code)

    def leave_FunctionDef(self, node: cst.FunctionDef) -> None:
        pass

    def _get_code_no_empty_leading_lines(self, node: cst.FunctionDef) -> str:
        code = self.module.code_for_node(node)
        empty_lines = 0
        for line in node.leading_lines:
            if line.comment is None:
                empty_lines += 1
            else:
                break

        return code[empty_lines:]
