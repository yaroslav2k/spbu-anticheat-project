from typing import Tuple, List, Literal

import libcst as cst


class FunctionDefinitionCollector(cst.CSTVisitor):
    class Result:
        def __init__(self) -> None:
            self.data: dict[Tuple[str, str], cst.Parameters] = {}

        def add(
            self,
            class_path: List[str],
            function_path: List[str],
            parameters: cst.Parameters,
        ):
            self.data[(".".join(class_path), ".".join(function_path))] = parameters

    class ResultPrinter:
        def __init__(self, result) -> None:
            self.result = result

        def call(self):
            for (class_name, function_name), value in self.result.data.items():
                print(class_name, function_name, value)

    def __init__(self) -> None:
        self.visited_classes_stack: List[str] = []
        self.visited_functions_stack: List[str] = []

        self.result: FunctionDefinitionCollector.Result = self.Result()

    def visit_ClassDef(self, node: cst.ClassDef) -> Literal[True]:
        self.visited_classes_stack.append(node.name.value)

        return True

    def leave_ClassDef(self, node: cst.ClassDef) -> None:
        self.visited_classes_stack.pop()

    def visit_FunctionDef(self, node: cst.FunctionDef) -> Literal[False]:
        self.visited_functions_stack.append(node.name.value)

        self.result.add(
            class_path=self.visited_classes_stack,
            function_path=self.visited_functions_stack,
            parameters=node.params.params,
        )

        return False

    def leave_FunctionDef(self, node: cst.FunctionDef) -> None:
        self.visited_functions_stack.pop()
