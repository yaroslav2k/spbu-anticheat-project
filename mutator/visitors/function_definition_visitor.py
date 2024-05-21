from typing import Literal

import libcst


from type_definitions.function_path import FunctionPath
from visitors.abstract_visitor import AbstractVisitor


class FunctionDefinitionCollector(AbstractVisitor):
    class Result(AbstractVisitor.Result):
        def __init__(self) -> None:
            self.data: dict[str, libcst.Parameters] = {}

        def add(
            self,
            function_path: FunctionPath,
            parameters: libcst.Parameters,
        ):
            self.data[".".join(function_path)] = parameters

    class ResultPrinter:
        def __init__(self, result) -> None:
            self.result = result

        def call(self):
            for (class_name, function_name), value in self.result.data.items():
                print(class_name, function_name, value)

    def __init__(self) -> None:
        self.current_function_path: FunctionPath = []
        self.result: FunctionDefinitionCollector.Result = self.Result()

    def visit_ClassDef(self, node: libcst.ClassDef) -> Literal[True]:
        self.current_function_path.append(node.name.value)

        return True

    def leave_ClassDef(self, node: libcst.ClassDef) -> None:
        self.current_function_path.pop()

    def visit_FunctionDef(self, node: libcst.FunctionDef) -> Literal[False]:
        self.current_function_path.append(node.name.value)

        self.result.add(
            function_path=self.current_function_path, parameters=node.params.params
        )

        return False

    def leave_FunctionDef(self, node: libcst.FunctionDef) -> None:
        self.current_function_path.pop()
