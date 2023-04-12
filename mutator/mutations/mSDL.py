import random

import visitors.function_definition_visitor as fdv
import transformers.function_definition_transformer as fdt


class mSDL:
    def __init__(self, source_tree):
        self.source_tree = source_tree

    def call(self):
        visitor = fdv.FunctionDefinitionCollector()
        self.source_tree.visit(visitor)

        result = visitor.result
        self.__apply_transformation(result)

        transformer = fdt.FunctionDefinitionTransformer(result)
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree

    def __apply_transformation(self, result) -> None:
        function_spec, arguments = random.choice(list(result.data.items()))
        params = list(arguments.params)
        params.pop(random.randrange(len(params)))
        if len(params) > 0:
            params[-1] = params[-1].with_changes(comma=None)
        result.data[function_spec] = arguments.with_changes(params=tuple(params))
