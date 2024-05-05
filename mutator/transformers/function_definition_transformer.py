from typing import List, Union, Literal, no_type_check

import libcst as cst

from visitors.abstract_visitor import AbstractVisitor


class FunctionDefinitionTransformer(cst.CSTTransformer):
    def __init__(
        self,
        result: AbstractVisitor.Result,
        mode: Union[Literal["insert"], Literal["remove"]] = "remove",
    ) -> None:
        self.result = result
        self.mode = mode

        self.visited_classes_stack: List[str] = []
        self.visited_functions_stack: List[str] = []

    def visit_ClassDef(self, node: cst.ClassDef) -> Literal[True]:
        self.visited_classes_stack.append(node.name.value)

        return True

    @no_type_check
    def leave_ClassDef(
        self, original_node: cst.ClassDef, updated_node: cst.ClassDef
    ) -> cst.CSTNode:
        self.visited_classes_stack.pop()

        return updated_node

    @no_type_check
    def visit_FunctionDef(self, node: cst.FunctionDef) -> Literal[True]:
        self.visited_functions_stack.append(node.name.value)

        return True

    @no_type_check
    def leave_FunctionDef(
        self, original_node: cst.FunctionDef, updated_node: cst.FunctionDef
    ) -> cst.CSTNode:
        self.visited_functions_stack.pop()

        return updated_node

    @no_type_check
    def leave_Param(
        self,
        original_node: cst.Param,
        updated_node: cst.Param,
    ) -> Union[cst.Param, cst.RemovalSentinel]:
        path = self.__current_path()

        if path in self.result.data and original_node not in self.result.data[path]:
            return cst.RemovalSentinel.REMOVE
        else:
            return updated_node

    def leave_Parameters(
        self,
        original_node: cst.Parameters,
        updated_node: cst.Parameters,
    ) -> cst.Parameters:
        if self.mode == "remove" and (not original_node.deep_equals(updated_node)):
            if len(updated_node.params) == 1:
                return updated_node.with_deep_changes(
                    updated_node.params[0], comma=cst.MaybeSentinel.DEFAULT
                )
        elif self.mode == "insert" and updated_node.params != (
            self.result.data[self.__current_path()]
        ):
            return updated_node.with_changes(
                params=self.result.data[self.__current_path()]
            )

        return updated_node

    def __current_path(self) -> tuple[str, str]:
        return (
            ".".join(self.visited_classes_stack),
            ".".join(self.visited_functions_stack),
        )
