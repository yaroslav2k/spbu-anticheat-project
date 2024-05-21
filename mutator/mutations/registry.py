from enum import Enum


class CloneType(Enum):
    TYPE_1 = 1
    TYPE_2 = 2
    TYPE_3 = 3
    TYPE_4 = 4


class Registry(Enum):  # NOTE: syntax sugar for `aenum`
    def __new__(cls, *args, **kwargs):
        value = len(cls.__members__) + 1
        obj = object.__new__(cls)
        obj._value_ = value

        return obj

    def __init__(self, slug: str, clone_type: CloneType) -> None:
        self.slug = slug
        self.clone_type = clone_type

    @property
    def value(self) -> str:
        return self.slug

    M_SIL = "mSIL", CloneType.TYPE_3
    M_SDL = "mSDL", CloneType.TYPE_3
    M_DL = "mDL", CloneType.TYPE_3
    M_IL = "mIL", CloneType.TYPE_3
    M_RLN = "mRLN", CloneType.TYPE_2
    M_RLS = "mRLS", CloneType.TYPE_2
