#!/usr/bin/env python3
# code/tangle.sphweb:18 <tangle.py>
# code/parser.sphweb:7 <Parsing>
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
# code/parser.sphweb:29 <Chunk definition>
from collections import defaultdict
from dataclasses import dataclass

CHUNK_STORAGE = {}
FILE_STORAGE = {}

def get_comment_sym_for_lang(lang):
    return '#'

class Chunk:
    storage = None

    def __init__(self, name: str, filename: str, line_number: int, code: str = '', language: str = ''):
        self.name = name
        self.filename = filename
        self.language = language
        self.parents = []
        self.children = []
        self.code = [
            Code(
                line=line_number,
                code=code,
                source=filename,
            )
        ]

    def __add__(self, other):
        if not isinstance(other, Chunk):
            raise TypeError(
                f"{other} must be ``Chunk`` type, {type(other)} was given")
        if self.name != other.name:
            raise ValueError("Can't add chunk with different name!")
        self.code.append(other.code[0])
        return self

    @property
    def line_number(self):
        return self.code.line

    def apply(self):
        first_appear = self.storage[self.name]
        return first_appear + self

    def register(self):
        assert self.storage is not None, "Chunk type unknown, storage undefined"
        assert self.storage.get(self.name, None) is None, f"Chunk {self} already defined"
        self.storage[self.name] = self

    def add_code_line(self, line):
        self.code[-1].code += line


@dataclass
class Code:
    source: str                 # Filename, where code difined
    line: int                 # Line number where code defined
    code: str                 # source code itself

    def get_anchor(self, language, shift=0):
        comment_sym = get_comment_sym_for_lang(language)
        anchor = f"{comment_sym} {self.source}:{self.line + shift}"
        return anchor


class CodeChunk(Chunk):
    storage = CHUNK_STORAGE

class FileChunk(Chunk):
    storage = FILE_STORAGE
    shebang = ''

# code/parser.sphweb:100 End of <Chunk definition>
# code/parser.sphweb:11 Continues <Parsing>
# code/parser.sphweb:137 <Chunk regexps>
import re
from types import SimpleNamespace

PATTERNS = {
    'CHUNK_NAME': r"^\s*@<(?P<chunk>[^>]+)@>",
    'FILE_NAME': r"@\((?P<chunk>[^)]+)@\)",
    'OP': r"\s*(?P<op>=\+?)\s*",
    'LANGUAGE': r"(?P<lang>[\S]+)\s*$",
    'END_OF_CHUNK': r"^\s*@\s*$",
    'SHEBANG': r"^\s*@shebang\s*(?P<shebang>.*$)",
}

PATTERNS['CHUNK_DEF'] =  PATTERNS['CHUNK_NAME'] + PATTERNS['OP'] + PATTERNS['LANGUAGE']
PATTERNS['FILE_DEF'] = '^\s*' + PATTERNS['FILE_NAME'] + PATTERNS['OP'] + PATTERNS['LANGUAGE']

RERE = SimpleNamespace()                       # Compiled regexps

for name, pattern in PATTERNS.items():
    setattr(RERE, name, re.compile(pattern))

# code/parser.sphweb:157 End of <Chunk regexps>
# code/parser.sphweb:12 Continues <Parsing>
# code/parser.sphweb:267 <Children parsing>
def read_code(chunk):
    for code in chunk.code:
        for line in code.code.split('\n'):
            yield line

def bound_chunks(parent, child):
    child.parents.apply(parent)
    chunk.children.apply(child)

def get_chunk(chunk_name):
    chunk = CHUNK_STORAGE.get(chunk_name, None) or FILE_STORAGE.get(chunk_name, None)
    if not chunk:
        raise ValueError(f"{chunk_name} chunk UNDEFINED")
        return 
    return chunk

def find_children(chunk):
    for line in read_code(chunk):
        if child_name := re.match(RERE.CHUNK_NAME, line):
            child = get_chunk(child_name)
            bound_chunks(parent=chunk,
                         child=child)
            return chunk.children
    return []

def build_tree(chunk):
    for child in find_children(chunk):
        build_tree(child)


# code/parser.sphweb:297 End of <Children parsing>
# code/parser.sphweb:13 Continues <Parsing>
# code/parser.sphweb:118 <File operations>
import pathlib

def find_files(directory_name):
    dir_ = pathlib.Path(directory_name)
    return dir_.glob("**/*.sphweb")

def contain_chunks(files):
    for path in files:
        with open(path, 'r') as f:
            parse_text(f.readlines(), f.name)

# code/parser.sphweb:129 End of <File operations>
# code/parser.sphweb:14 Continues <Parsing>
# code/parser.sphweb:215 <Parse code>
# Parsing modes
TEXT = 0
CHUNK = 1

def parse_text(text, filename):
    PARSE_MODE = TEXT           # Parsing starts always in text mode 
    current_chunk = None
    lino = 0                  
    op = ''
    for line in text:
        lino += 1
        if PARSE_MODE == TEXT:
            if chunk_head := re.match(RERE.CHUNK_DEF, line):
                PARSE_MODE = CHUNK
                op = chunk_head.group('op')
                current_chunk = CodeChunk(
                    name=chunk_head.group('chunk'), 
                    line_number=lino,
                    filename=filename,
                    language=chunk_head.group('lang')
                ) 
            if chunk_head := re.match(RERE.FILE_DEF, line):
                PARSE_MODE = CHUNK
                op = chunk_head.group('op')
                current_chunk = FileChunk(
                    name=chunk_head.group('chunk'), 
                    line_number=lino,
                    filename=filename,
                    language=chunk_head.group('lang')
                ) 
            continue
        if PARSE_MODE == CHUNK:
            assert current_chunk is not None
            if re.match(RERE.END_OF_CHUNK, line): # End of chunk?
                if op == '=':
                    current_chunk.register()
                elif op == '=+':
                    current_chunk.apply()
                else:
                    ParserError("Undefined chunk")
                PARSE_MODE = TEXT
                current_chunk = None
                op = ''
            elif shebang := re.match(RERE.SHEBANG, line):
                assert isinstance(current_chunk, FileChunk), "``@shebang`` macro can be used only in file chunks"
                current_chunk.shebang = shebang.group('shebang')
            else:
                logger.info(current_chunk.name)
                current_chunk.add_code_line(line) # Save code line to the chunk object

# code/parser.sphweb:265 End of <Parse code>
# code/parser.sphweb:15 Continues <Parsing>

# code/parser.sphweb:17 End of <Parsing>
# code/tangle.sphweb:18 Continues <tangle.py>

# code/config.sphweb:12 <Command line arguments>
import argparse


def cli_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--in', dest='_in')
    parser.add_argument('--out', dest='output_dir')
    return parser.parse_args()

# code/config.sphweb:21 End of <Command line arguments>
# code/tangle.sphweb:20 Continues <tangle.py>


def expand_code(chunk):
    code = ''
    # code/tangle.sphweb:25 Continues <tangle.py>
    for code_obj in chunk.code:
        shift = 0
        code += f"{code_obj.get_anchor(chunk.language)} <{chunk.name}>\n"
        for line in code_obj.code.split('\n'):
            if child := re.match(RERE.CHUNK_NAME, line):
                try:
                    child_code = expand_code(
                            get_chunk(child.group('chunk'))
                    )
                except ValueError as e:
                    logger.error(e)
                    child_code = ''
                context = line[:line.index('@<')] # Indentation
                posttext = line.split('@>')[1] # Tail of symbols after chunk
                # Push every line to context
                child_code = child_code.replace('\n', '\n'+context)
                # Add posttext
                child_code += posttext
                code += child_code
                code += context + code_obj.get_anchor(chunk.language, shift) + f" Continues <{chunk.name}>\n" # Shift commentary ancor by indentation
            else:
                code += line + '\n'
            shift += 1
        code += code_obj.get_anchor(chunk.language, shift) + f" End of <{chunk.name}>\n" # Shift commentary ancor by indentation
    return code
    
def tangle(output_dir):
    for root in FILE_STORAGE.values():
        with open(pathlib.PurePath(output_dir, root.name), "w") as tangled:
            if root.shebang: tangled.write(root.shebang+'\n')
            tangled.write(expand_code(root))

def main():
    params = cli_args()
    files = find_files(params._in)
    contain_chunks(files)
    tangle(params.output_dir)

if __name__ == '__main__':
    main()

# code/tangle.sphweb:67 End of <tangle.py>
