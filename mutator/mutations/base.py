import libcst
import random


class Base:
    def __init__(self, source_tree: libcst.Module, randomizer: random.Random):
        self.source_tree: libcst.Module = source_tree
        self.randomizer: random.Random = randomizer

    def call(self):
        raise NotImplementedError

    def _visit(self, visitor: libcst.CSTVisitor):
        self.source_tree.visit(visitor)
