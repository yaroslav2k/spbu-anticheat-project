from typing import Optional, List

import libcst as cst


class FunctionDefinitionTransformer(cst.CSTTransformer):
    def __init__(self, result):
        self.stack: List[str] = []
        self.result = result

    def visit_ClassDef(self, node: cst.ClassDef) -> Optional[bool]:
        self.stack.append(node.name.value)

    def leave_ClassDef(
        self, original_node: cst.ClassDef, updated_node: cst.ClassDef
    ) -> cst.CSTNode:
        self.stack.pop()
        return updated_node

    def visit_FunctionDef(self, node: cst.FunctionDef) -> Optional[bool]:
        self.stack.append(node.name.value)
        return False  # pyi files don't support inner functions, return False to stop the traversal.

    def leave_FunctionDef(
        self, original_node: cst.FunctionDef, updated_node: cst.FunctionDef
    ) -> cst.CSTNode:
        key = self.stack[-1]
        self.stack.pop()
        class_name = self.stack[-1] if len(self.stack) > 0 else ""
        if (class_name, key) in self.result.data:
            return updated_node.with_changes(params=self.result.data[(class_name, key)])
        return updated_node
