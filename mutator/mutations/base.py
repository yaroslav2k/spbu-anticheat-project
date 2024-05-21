import random

import libcst

from mutations.injection_trace import InjectionTrace


class Base:
    def __init__(
        self,
        source_tree: libcst.Module,
        randomizer: random.Random,
        injection_trace: InjectionTrace,
    ):
        self.source_tree: libcst.Module = source_tree
        self.randomizer: random.Random = randomizer
        self.injection_trace: InjectionTrace = injection_trace

    def call(self):
        raise NotImplementedError

    def _visit(self, visitor: libcst.CSTVisitor):
        self.source_tree.visit(visitor)
