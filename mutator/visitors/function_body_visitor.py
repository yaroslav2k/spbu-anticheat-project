from dataclasses import dataclass
import libcst as cst
from typing import Optional, Tuple


class FunctionBodyCollector(cst.CSTVisitor):
    METADATA_DEPENDENCIES = (cst.metadata.PositionProvider,)

    class Result:
        @dataclass
        class FunctionInfo:
            body: str
            start: int
            end: int

        def __init__(self) -> None:
            self.data: dict[Tuple[str, str], 'FunctionBodyCollector.Result.FunctionInfo'] = {}

        def add(self, class_name: str, function_name: str, body: str, start: int, end: int):
            self.data[(class_name, function_name)] = FunctionBodyCollector.Result.FunctionInfo(body, start, end)

    class ResultPrinter:
        def __init__(self, result: 'FunctionBodyCollector.Result') -> None:
            self.result = result

        def call(self):
            for (class_name, function_name), value in self.result.data.items():
                print("---")
                if class_name and len(class_name) > 0:
                    print(class_name + "#" + function_name)
                else:
                    print(function_name)
                print(value.body)

    def __init__(self) -> None:
        self.stack = []
        self.result = self.Result()
        self.module = cst.parse_module("")

    def visit_ClassDef(self, node: cst.ClassDef) -> Optional[bool]:
        self.stack.append(node.name.value)

    def leave_ClassDef(self, node: cst.ClassDef) -> None:
        self.stack.pop()

    def visit_FunctionDef(self, node: cst.FunctionDef) -> Optional[bool]:
        start_pos = self.get_metadata(cst.metadata.PositionProvider, node).start
        end_pos = self.get_metadata(cst.metadata.PositionProvider, node).end
        code = self._get_code_no_empty_leading_lines(node)

        class_name = ""
        if len(self.stack) > 0:
            class_name = self.stack[-1]

        self.result.add(class_name, node.name.value, code, start_pos.line, end_pos.line)

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
