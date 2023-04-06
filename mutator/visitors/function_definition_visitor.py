import libcst as cst
from typing import Dict, List, Optional, Tuple


class FunctionDefinitionCollector(cst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data = {}

        def add(self, class_name: str, function_name: str, parameters: any):
            self.data[(class_name, function_name)] = parameters

    class ResultPrinter:
        def __init__(self, result) -> None:
            self.result = result

        def call(self):
            for (class_name, function_name), value in self.result.data.items():
                print(class_name, function_name, value)

    def visit_ClassDef(self, node: cst.ClassDef) -> Optional[bool]:
        self.stack.append(node.name.value)

    def leave_ClassDef(self, node: cst.ClassDef) -> None:
        self.stack.pop()

    def __init__(self) -> None:
        self.stack = []
        self.result = self.Result()

    def visit_FunctionDef(self, node: cst.FunctionDef) -> Optional[bool]:
        if len(self.stack) > 0:
            self.result.add(self.stack[-1], node.name.value, node.params)
        else:
            self.result.add("", node.name.value, node.params)

    def leave_FunctionDef(self, node: cst.FunctionDef) -> None:
        pass
