import libcst
from libcst._removal_sentinel import RemoveFromParent

from transformers.abstract_transformer import AbstractTransformer


class SingleStatementLineRemover(AbstractTransformer):
    def __init__(self, result):
        self.result = result

    def leave_SimpleStatementLine(
        self,
        original_node: libcst.SimpleStatementLine,
        updated_node: libcst.SimpleStatementLine,
    ) -> libcst.CSTNode:
        if hash(original_node) in self.result:
            return RemoveFromParent()

        return updated_node
