import libcst as cst
from libcst._removal_sentinel import RemoveFromParent


class SingleStatementLineRemover(cst.CSTTransformer):
    def __init__(self, result):
        self.result = result

    def leave_SimpleStatementLine(
        self,
        original_node: cst.SimpleStatementLine,
        updated_node: cst.SimpleStatementLine,
    ) -> cst.CSTNode:
        if hash(original_node) in self.result:
            return RemoveFromParent()

        return updated_node
