import string
import random
import pathlib

from typing import Tuple, List, Optional
from mutations.base import Base

import visitors.function_definition_visitor as fdv
import transformers.function_definition_transformer as fdt
import libcst


# FIXME: naming should be aligned with python's recommendations
class mSIL(Base):
    def call(self):
        visitor = fdv.FunctionDefinitionCollector()
        self.source_tree.visit(visitor)

        result = visitor.result
        self._add_parameter(result)

        transformer = fdt.FunctionDefinitionTransformer(result, mode="insert")
        modified_tree = self.source_tree.visit(transformer)

        return modified_tree

    def _add_parameter(
        self,
        result: fdv.FunctionDefinitionCollector.Result,
        typehint_prob: float = 0.5,
        value_prob: float = 0.3,
    ) -> None:
        path, parameters_tuple = self.randomizer.choice(list(result.data.items()))
        parameters: List = list(parameters_tuple or tuple())

        name = ParameterNameGenerator.generate_parameter_name(self.randomizer)
        new_param = libcst.Param(libcst.Name(name))
        new_position = self.randomizer.randint(0, len(parameters))

        typehint, default_value = TypehintGenerator.generate_typehint_and_default_value(
            self.randomizer
        )

        if new_position > 0 and parameters[new_position - 1].default is not None:
            new_param = new_param.with_changes(default=default_value)
        elif (
            new_position < len(parameters) and parameters[new_position].default is None
        ):
            new_param = new_param.with_changes(default=None)
        elif self.randomizer.random() < value_prob:
            new_param = new_param.with_changes(default=default_value)

        if self.randomizer.random() < typehint_prob:
            new_param = new_param.with_changes(annotation=typehint)

        parameters.insert(new_position, new_param)
        result.data[path] = tuple(parameters)


class TypehintGenerator:
    _basic_types = ["int", "float", "str"]
    _compound_types = ["List", "Tuple"]  # TODO: add "Dict" and "Set"

    @classmethod
    def generate_typehint_and_default_value(
        cls, randomizer
    ) -> Tuple[libcst.Annotation, libcst.CSTNode]:
        typehint = randomizer.choice(cls._basic_types + cls._compound_types)
        if typehint in cls._basic_types:
            return cls._generate_basic_typehint_and_value(typehint, randomizer)
        return cls._generate_compound_typehint_and_value(typehint, randomizer)

    @classmethod
    def _generate_basic_typehint_and_value(
        cls, basic_type: str, randomizer
    ) -> Tuple[libcst.Annotation, libcst.CSTNode]:
        typehint = libcst.Annotation(libcst.Name(basic_type))
        match basic_type:
            case "int":
                value = str(randomizer.randint(0, 1000000))
                return typehint, libcst.Integer(value)
            case "str":
                allowed_symbols = (
                    string.ascii_letters
                    + string.digits
                    + "#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
                )
                length = randomizer.randint(0, 20)
                value = (
                    '"'
                    + "".join(randomizer.choice(allowed_symbols) for i in range(length))
                    + '"'
                )
                return typehint, libcst.SimpleString(value)
            case "float":
                value = str(randomizer.random() * randomizer.randint(0, 1000))
                return typehint, libcst.Float(value)
            case _:
                raise ValueError(basic_type)

    @classmethod
    def _generate_compound_typehint_and_value(
        cls, compound_type: str, randomizer
    ) -> Tuple[libcst.Annotation, libcst.CSTNode]:
        elements = []
        match compound_type:
            case "List":
                basic_type = randomizer.choice(cls._basic_types)
                length = randomizer.randint(0, 6)
                for _ in range(length):
                    _, value = cls._generate_basic_typehint_and_value(
                        basic_type, randomizer
                    )
                    elements.append(libcst.Element(value))
                typehint = libcst.Annotation(
                    libcst.Subscript(
                        libcst.Name("List"),
                        [
                            libcst.SubscriptElement(
                                libcst.Index(libcst.Name(basic_type))
                            )
                        ],
                    )
                )
                return typehint, libcst.List(elements)
            case "Tuple":
                tuple_slice = []
                length = randomizer.randint(1, 3)
                for _ in range(length):
                    basic_type = randomizer.choice(cls._basic_types)
                    _, value = cls._generate_basic_typehint_and_value(
                        basic_type, randomizer
                    )
                    elements.append(libcst.Element(value))
                    tuple_slice.append(
                        libcst.SubscriptElement(libcst.Index(libcst.Name(basic_type)))
                    )

                return libcst.Annotation(
                    libcst.Subscript(libcst.Name("Tuple"), tuple_slice)
                ), libcst.Tuple(elements)
            case _:
                raise ValueError(compound_type)


class ParameterNameGenerator:
    __parameter_names: Optional[List[str]] = None

    @classmethod
    def generate_parameter_name(cls, randomizer: random.Random) -> str:
        if cls.__parameter_names is None:
            with open(
                pathlib.Path(__file__).parent / "data" / "parameter-names-registry.txt"
            ) as f:
                cls.__parameter_names = list(filter(len, f.read().split("\n")))

        return randomizer.choice(cls.__parameter_names)
