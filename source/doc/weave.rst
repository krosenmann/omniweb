``sphweave`` the Program
========================

``sphweave`` creates almost readable documentation from the liteate
source.
``sphweave`` expands macro's and writes output to ``.rst``
files. User needs to run |Sphinx| or |docutils| or whatever for
readable (printable) versions of project source.
@test


.. code-block:: python
   :caption: **{weave.py}** =
   :name: code_weave.sphweb_11
   :force:

    @<Parsing@>
    @<Macro definition@>
    @<Register macro@>
    @<Processing the document@>
    @<Command line arguments@>
    @<Running the program@>
    @<Weaver function@>
    
    def main():
        params = cli_args()
        files = find_files(params._in)
        contain_chunks(files)
        weave(files, params.output_dir, params._in)
    
    if __name__ == '__main__':
        main()
    
    
Chunk defined at:

#. :ref:`weave.py 0 <code_weave.sphweb_11>`

Related chuks:

#. :ref:`Parsing <code_parser.sphweb_7>`
#. :ref:`Macro definition <code_weave.sphweb_99>`
#. :ref:`Register macro <code_weave.sphweb_240>`
#. :ref:`Command line arguments <code_config.sphweb_12>`
#. :ref:`Weaver function <code_weave.sphweb_36>`

Chunk used in:


Sphinxweb files from input translates directly to ``.rst`` files. That
means if you have file ``fancy_program.sphweb`` it translates to
``fancy_program.rst``, if you have ``dir/fancy_profram.sphweb`` then
you get ``dir/fancy_program.rst``.


.. code-block:: python
   :caption: **<Weaver function>** =
   :name: code_weave.sphweb_36
   :force:

    def build_rst_path(source, output, source_root):
        root_relative_path = source.relative_to(source_root).with_suffix('.rst')
        return pathlib.Path(output).joinpath(root_relative_path)
        
    
    def weave(files, output, source_root):
        for sphinx_source in files:
            target = build_rst_path(sphinx_source, output, source_root)
            @<Document processing@>
    
    
Chunk defined at:

#. :ref:`Weaver function 0 <code_weave.sphweb_36>`

Related chuks:

#. :ref:`Document processing <code_weave.sphweb_301>`

Chunk used in:

#. :ref:`weave.py <code_weave.sphweb_11>`
|sphinxweb| macroses
--------------------

Every |sphinxweb| specific syntax is just a macro wich expands into
valid reStructured sequence.

We can describe RST sequensce as two properties of text:
- header
- context
For more info about parsing macroses look at |Regexps definition and
prepare|. 

Context mostly is the indentation level of a text block. Untill I find
another types of the context in RST, we will use indentation as one
possible context.


.. code-block:: python
   :caption: **<Indentation context>** =
   :name: code_weave.sphweb_64
   :force:

    class Indentation:
        level = 0
    
        def __enter__(self):
            self.level += 1
    
        @property
        def context(self):
            """String of spaces represents current indentation level.
    
            3 spaces for 1st indentation level, 6 for lvl 2 and so on.
            """
            return ' ' * (self.level * 3)
    
        def __exit__(self):
            self.level -= 1
    
        def push_str_to_context(self, str):
            return self.context + str
    
    
Chunk defined at:

#. :ref:`Indentation context 0 <code_weave.sphweb_64>`

Related chuks:


Chunk used in:


Headers are simplier structures from this perspective, it's just
regular things in RST like ``..todo`` or ``..code-block`` and so
on. Actaully, we don't need to extract block header as an conceptual
object. More than enough put it as the first tag because it's just a
string and nothing more (from macro expansion perspective).

So, for every macro we need to describe:
- name (thing after ``@@``)
- type (singleline | multiline)
- body translation procedure.


.. code-block:: python
   :caption: **<Macro definition>** =
   :name: code_weave.sphweb_99
   :force:

    class Macro:
        name = ''
        is_multiline = True
    
        @classmethod
        def translate_body(cls, text):
            raise NotImplementedError(f"Line translator for macro {cls.name} undefined")
    
Chunk defined at:

#. :ref:`Macro definition 0 <code_weave.sphweb_99>`
#. :ref:`Macro definition 1 <code_weave.sphweb_113>`
#. :ref:`Macro definition 2 <code_weave.sphweb_130>`
#. :ref:`Macro definition 3 <code_weave.sphweb_158>`

Related chuks:


Chunk used in:

#. :ref:`weave.py <code_weave.sphweb_11>`

We use class based macro because we need only bind function with some
constant data. Here is no reason for instantation.
For example, ``@@ignore`` is the simpliest multiline macro.


.. code-block:: python
   :caption: **<Macro definition>** =+
   :name: code_weave.sphweb_99
   :force:

    class IgnoreMacro(Macro):
        """``@iftangle`` macro. Don't read given section neigher on weave or tangle.
        """
        name = "ignore"
        is_multiline = True
    
        @classmethod
        def translate_body(cls, text):
            return ''
    
Chunk defined at:

#. :ref:`Macro definition 0 <code_weave.sphweb_99>`
#. :ref:`Macro definition 1 <code_weave.sphweb_113>`
#. :ref:`Macro definition 2 <code_weave.sphweb_130>`
#. :ref:`Macro definition 3 <code_weave.sphweb_158>`

Related chuks:


Chunk used in:

#. :ref:`weave.py <code_weave.sphweb_11>`

Weave helpfull macro
--------------------
In this section we create some usefull macroses for weave.



.. code-block:: python
   :caption: **<Macro definition>** =+
   :name: code_weave.sphweb_99
   :force:

    class DoubleAtMacro(Macro):
        """ ``@`` symbol quotation. Translates ``@@`` and ``@@sometext`` to ``@`` and ``@sometext``.
        """
        name = "@"
        is_multiline = False
    
        @classmethod
        def translate_body(cls, text):
            """Just delete first symbol from ``text``
            """
            return text[1:]
    
    
Chunk defined at:

#. :ref:`Macro definition 0 <code_weave.sphweb_99>`
#. :ref:`Macro definition 1 <code_weave.sphweb_113>`
#. :ref:`Macro definition 2 <code_weave.sphweb_130>`
#. :ref:`Macro definition 3 <code_weave.sphweb_158>`

Related chuks:


Chunk used in:

#. :ref:`weave.py <code_weave.sphweb_11>`



Chunk body translation
----------------------
For inserting chunk into final document we need to translate sphinxweb
header to the typical sphinx header, then insert code of chunk with
indentation and after it we need to insert links to usages of this
chunk, to all used chunks and to expancions of this chunk.

This macro has some differences with another macroses. On
``translate_body`` method we need to give the name of current chunk
for creating links and headers and operation (just for copying).


.. code-block:: python
   :caption: **<Macro definition>** =+
   :name: code_weave.sphweb_99
   :force:

    class ChunkMacro(Macro):
        name = "chunk"
        is_multiline = True
    
        @classmethod
        def translate_body(cls, text, chunk_name, op):
            @<Header translation@>
            @<Push code to indentation context@>
            @<Produce text for insertions@>
            return code_block
    
Chunk defined at:

#. :ref:`Macro definition 0 <code_weave.sphweb_99>`
#. :ref:`Macro definition 1 <code_weave.sphweb_113>`
#. :ref:`Macro definition 2 <code_weave.sphweb_130>`
#. :ref:`Macro definition 3 <code_weave.sphweb_158>`

Related chuks:

#. :ref:`Header translation <code_weave.sphweb_185>`
#. :ref:`Push code to indentation context <code_weave.sphweb_198>`
#. :ref:`Produce text for insertions <code_weave.sphweb_208>`

Chunk used in:

#. :ref:`weave.py <code_weave.sphweb_11>`

Let's start from the translation of header. Header of code block in
Sphinx looks like this

.. code-block:: rst

   .. code-block:: *language*
      :caption: <Chunk name> = (OR =+) (OR {filename.py} = )
      :name: |Chunk name| Chunk name
      :emphasize-lines: 3,5 (Or other lines, where another chunks used)


Most options we can get from chunk object itself
.. todo:: emphasize-lines


.. code-block:: python
   :caption: **<Header translation>** =
   :name: code_weave.sphweb_185
   :force:

    current_chunk = get_chunk(chunk_name)
    chunk_title = f"<{chunk_name}>" if isinstance(current_chunk, CodeChunk) else f"{{{chunk_name}}}"
    code_head = f"\n.. code-block:: {current_chunk.language}\n   :caption: **{chunk_title}** {op}\n   :name: {current_chunk.get_head_anchor()}\n   :force:\n"
    
Chunk defined at:

#. :ref:`Header translation 0 <code_weave.sphweb_185>`

Related chuks:


Chunk used in:

#. :ref:`Macro definition <code_weave.sphweb_99>`

The next step is adding indentation to code block.
In the source code block can start from the first line and can't have
the newline at the start of block. But for RST code block shall starts
with newline and indentation both.

.. todo:: correct link generation


.. code-block:: python
   :caption: **<Push code to indentation context>** =
   :name: code_weave.sphweb_198
   :force:

    text = '\n' + text if text[0] != '\n' else text
    text = text.replace('\n', '\n    ') # Lol, without contextmanager and much simplier, kek kek kek
    code_block = code_head + text +'\n' # Extra new line at the end of code block needs for parsing by Sphinx
    
Chunk defined at:

#. :ref:`Push code to indentation context 0 <code_weave.sphweb_198>`

Related chuks:


Chunk used in:

#. :ref:`Macro definition <code_weave.sphweb_99>`

And now let's add all needed links after code block. For creating list
of used chunks we need to read text line by line and find, what chunks
was used in given chunk but not in the expansions.


.. code-block:: python
   :caption: **<Produce text for insertions>** =
   :name: code_weave.sphweb_208
   :force:

    # Find children
    finded_chunks = []
    for line in text.split('\n'):
        if child_name := re.match(RERE.CHUNK_NAME, line):
            child = get_chunk(child_name.group('chunk'))
            if child is not None:
                finded_chunks.append(child)
                bound_chunks(parent=current_chunk, child=child)
    # Add definitions  and extensions
    defined = "Chunk defined at:\n\n"
    used_in = "\nChunk used in:\n\n"
    uses = "\nRelated chuks:\n\n"
    for index, code in enumerate(current_chunk.code):
       defined += f'#. :ref:`{chunk_name} {index} <{code.get_rst_anchor()}>`\n' 
    
    for child in finded_chunks:
        uses += f'#. :ref:`{child.name} <{child.get_head_anchor()}>`\n'
    
    for parent in current_chunk.parents:
        used_in += f'#. :ref:`{parent.name} <{parent.get_head_anchor()}>`\n'
    
    code_block += defined + uses + used_in
    
Chunk defined at:

#. :ref:`Produce text for insertions 0 <code_weave.sphweb_208>`

Related chuks:


Chunk used in:

#. :ref:`Macro definition <code_weave.sphweb_99>`


Registration of macroses
------------------------
We register all macroses by the name to global dictionary. On
translation this dictionary will be used for getting macro by name
@test


.. code-block:: python
   :caption: **<Register macro>** =
   :name: code_weave.sphweb_240
   :force:

    MACRO_REG = {}
    def register_macroses():
        for macro in [IgnoreMacro, DoubleAtMacro, ChunkMacro, ]:
            MACRO_REG[macro.name] = macro
    
    def get_macro(name):
        return MACRO_REG.get(name, None)
    
Chunk defined at:

#. :ref:`Register macro 0 <code_weave.sphweb_240>`

Related chuks:


Chunk used in:

#. :ref:`weave.py <code_weave.sphweb_11>`


Macroexpand
-----------

.. code-block:: python
   :caption: **<Macroexpand init>** =
   :name: code_weave.sphweb_254
   :force:

    # General init
    INSIDE_MULTILINE = False
    current_macro = None
    lines_for_expansion = []
    # Init of chunk translation
    chunk_name = ''
    op = ''
    
Chunk defined at:

#. :ref:`Macroexpand init 0 <code_weave.sphweb_254>`

Related chuks:


Chunk used in:


@test2


.. code-block:: python
   :caption: **<Macroexpand>** =
   :name: code_weave.sphweb_266
   :force:

    if macro_in := REMACRO.match(line):
        macro = get_macro(macro_in.group('name'))
        if macro is not None:
            if macro.is_multiline:
                current_macro = macro
                INSIDE_MULTILINE = True
            else:
                line = macro.translate_body(line)
    
    if chunk_match := (RERE.CHUNK_DEF.match(line) or RERE.FILE_DEF.match(line)):
        current_macro = ChunkMacro
        INSIDE_MULTILINE = True
        chunk_name = chunk_match.group('chunk')
        op = chunk_match.group('op')
        continue
    
    if END_OF_MACRO.match(line) or RERE.END_OF_CHUNK.match(line):
        if current_macro is ChunkMacro:
            args = (''.join(lines_for_expansion), chunk_name, op)
        else:
            args = (''.join(lines_for_expansion,))
        line = current_macro.translate_body(*args)
        INSIDE_MULTILINE = False
        lines_for_expansion = []
    
    if INSIDE_MULTILINE:
        lines_for_expansion.append(line)
        continue
    
Chunk defined at:

#. :ref:`Macroexpand 0 <code_weave.sphweb_266>`

Related chuks:


Chunk used in:



Processing the document
-----------------------


.. code-block:: python
   :caption: **<Document processing>** =
   :name: code_weave.sphweb_301
   :force:

    with open(sphinx_source, "r") as document, open(target, "w") as TARGET_FILE:
        @<Macroexpand init@>
        for line in document:
            @<Macroexpand@>
            TARGET_FILE.write(line)
    
Chunk defined at:

#. :ref:`Document processing 0 <code_weave.sphweb_301>`

Related chuks:

#. :ref:`Macroexpand init <code_weave.sphweb_254>`
#. :ref:`Macroexpand <code_weave.sphweb_266>`

Chunk used in:

#. :ref:`Weaver function <code_weave.sphweb_36>`
