# Python CST-based mutation framework

## Usage

Run `python mutator.py` to see the help banner:

```
usage: mutator.py [-h] [-o OUTPUT] -m MUTATIONS [-s SEED] [-d {uniform}] input

Python CST-based code mutation framework

positional arguments:
  input

options:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
  -m MUTATIONS, --mutations MUTATIONS
  -s SEED, --seed SEED
  -d {uniform}, --distribution {uniform}
```

## Mutations suite specification

When invoking `mutator`, you should provide a non-empty string as a mutation suite specification.

The mutation suite specification consists of (1 or more) parts divided by `;` symbol. Each part consists of these parts

- (required) mutation operator name, e.g. `mSDL`;
- (optional) count of times to apply particular mutation, e.g `1` or `1-3`.

If the second part contains the `-` symbol the LHS is interpreted as a minimal count of times to apply and
the RHS as maximum count to apply. Exact count is chosen randomly.

Alternatively, you can use a single integer to specify exact applications count explicitly.

Examples:

1. Apply `mSDL` 2 times and then apply `mSIL` at least 3 and at max 5 times: `mSDL:2;mSIL:3-5`;
2. Apply `mSIL` exactly 4 times: `mSIL:4`.

You can also use `any` as the mutation name to select it randomly.

## Deterministic running

In order to be able to reproduce the results, you might want to specify `-s`/`-seed` option. It consumes an integer
which is passed to a `random.Random` instance which is used to perform any pseudorandom-related operations.

It's guaranteed that evaluation the same mutation specification on the same code (within specific CPython interpreter) will generate
consistent result.

## Example

The following was run against the following source file:

```python
#!/usr/bin/env python

class Calc:
  def __init__(self, name: str) -> None:
    self.name = name

  def sum(self, a, b): return a + b

  def div(self, a, b):
    if b == 0:
      print(f"{self.name}: can't divide by zero in context of rings")

      return float('nan')
    else:
      return a / b
```

python mutator.py -m mSIL:4,mSDL:2,mDL:2 --seed 1337 test.py

```python
# test file

class Calc:
  def __init__(self, smith: Tuple[str]) -> None:
    pass

  def sum(self, a, b): return a + b

  def div(self, package, release, a, b):
    if b == 0:

      return float('nan')
    else:
      return a / b
```

## Running tests

Simply run `python -m unittest`.

## References

The mutation operations taxonomy was heavely inspired by

```
Svajlenko, J. (2021). The Mutation and Injection Framework: Evaluating Clone Detection Tools with Mutation Analysis. In: C. Roy, ed., IEEE TRANSACTIONS ON SOFTWARE ENGINEERING. pp.1060–1087.

‌
```
