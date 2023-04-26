import split_module
import tokenizer
import argparse

from pathlib import Path

def call_splitter(dir: str, output: str):
  result = []
  files = list(Path(dir).rglob("*.py"))

  for file in files:
    result = result + split_module.split(file)

  return result

def call_tokenizer(data, output):
  return tokenizer.tokenize_data(data, output)

def main():
  parser = argparse.ArgumentParser(
    prog="tt.py", description="bad naming"
  )
  parser.add_argument("dir")
  parser.add_argument("--output")
  args = parser.parse_args()

  if args.output is None or len(args.output) == 0:
    args.output = args.dir + "/result.json"

  result = call_splitter(args.dir, None)
  call_tokenizer(result, args.output)


if __name__ == "__main__":
    main()