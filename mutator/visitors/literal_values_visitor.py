from typing import Literal

import libcst

from type_definitions.function_path import FunctionPath
from visitors.abstract_visitor import AbstractVisitor


class LiteralValuesCollector(AbstractVisitor):
    class Result(AbstractVisitor.Result):
        def __init__(self) -> None:
            self.data: dict[str, list[libcst.BaseNumber | libcst.SimpleString]] = {}
            self.changes: dict = {}

        def add(
            self,
            function_path: FunctionPath,
            node: libcst.BaseNumber | libcst.SimpleString,
        ) -> None:
            current_function_path_serialized = ".".join(function_path)

            if current_function_path_serialized not in self.data.keys():
                self.data[current_function_path_serialized] = []

            self.data[current_function_path_serialized].append(node)

    def __init__(self, target_types: list[type]) -> None:
        self.result = self.Result()
        self.target_types = target_types

        self.current_function_path: FunctionPath = []

        self.current_function_path: list[str]

    def visit_ClassDef(self, node: libcst.ClassDef) -> Literal[True]:
        self.current_function_path.append(node.name.value)

        return True

    def leave_ClassDef(self, node: libcst.ClassDef) -> None:
        self.current_function_path.pop()

    def visit_FunctionDef(self, node: libcst.FunctionDef) -> Literal[True]:
        self.current_function_path.append(node.name.value)

        return True

    def leave_FunctionDef(self, node: libcst.FunctionDef) -> None:
        self.current_function_path.pop()

    # NOTE: for some reason `visit_BaseNumber` does not work,
    # see https://libcst.readthedocs.io/en/latest/nodes.html#libcst.BaseNumber for details.
    def visit_Integer(self, node: libcst.Integer):
        self.__try_collect_node(node)

    def visit_Float(self, node: libcst.Float):
        self.__try_collect_node(node)

    def visit_Imaginary(self, node: libcst.Imaginary):
        self.__try_collect_node(node)

    def visit_SimpleString(self, node: libcst.SimpleString):
        self.__try_collect_node(node)

    def __try_collect_node(self, node):
        if not self.__ensure_type_is_processable(node):
            return None

        self.result.add(self.current_function_path, node)

    def __ensure_type_is_processable(self, node):
        return type(node) in self.target_types
