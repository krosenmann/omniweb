===================================================
SphinxWEB. Sphinx based literate programming system
===================================================

.. toctree::
   :numbered:

Basics terms
============

Chunk
-----
Chunk is the main element of the literate code editing. It looks like
this:
::

    @<Chunk name@> = python
    for elem in collection:
        print(elem)
    @

.. note:: List of all sphinxweb markup commands you can see in
          :ref:`mark_spec`

Tangling
--------

Tangling is the procedure of preprocessing code from sphinxweb source
into regular source code files.

Weaving
-------

Weaving is the procedure for creating restructuredText files from the
SphinxWEB sources.
After weaving, you can build your documentation with Sphinx.


Master WEB file
---------------

.. note::
   Actually, you can run weave or tangle from single file. This
   produce one ``.rst`` file.
   Master WEB file needs only you want to split your source document
   on different files.

This files describe connection between files in current theme\\product
hierarchy. Actually, it's works the almost same as Sphinx master file,
also knows as ``index.rst``.

But for working with SphinxWEB we have some deffernces: you need to
use command @toc and @endtoc. Parameters for toctree used exactly the
same as in regular Sphinx.

Follow code

*<file: index.sqhweb>*
::

   @toc
   :maxdepth: 2

   source/first.sphweb
   source/second.sphweb
   source/third.sphweb
   @endtoc


translates into

*<file: index.rst>*
::

   .. toctree
      :maxdepth: 2

      weave/first.rst
      weave/second.rst
      weave/third.rst


For different indepent parts of project you can define different
document hierarchies. That means in one project you may have more than
one master WEB file. Use this if you can split your project into some subprojects.
**This is the strongly recommended way.**

.. warning:: You can use chunk application command (``=+``) ONLY in
   ONE sphinx-web file . But all chunks ready for use for all
   subproject.


Development framework with SphinxWEB
====================================

TBD


.. _mark_spec:

List of all metamarkup commands
=============================== 
**@** the root symbol of sphinxweb metamarkup. All web bounded
commands starts with this symbol. If next symbol after **@** not the
valid metamarkup command, then parser translates it as is.

SphinxWEB builded on top of the ReStructuredText (sphinx extension).
List of additional markups:

**@@**
  Escaping @ symbol. For example, if U wanna write
  an email address in document then you need to write double at symbol:
  *krosenmann@@example.com* and on weaving it will looks normally:
  *krosenmann@example.com*. This happens because @ is the main direct
  symbol I use for metaformatting commands.

  .. note::
     Actually, most of the ``@`` symbols ignores in most non-command
     cases. Recommended for situations, where your input looks like chunk
     definition or if you want to avoid interpretation of the
     command. As an example, for literal insertion or for some debug. 

**@<Chunk name@>**
  name of code chunk. This string will be replaced with
  code on tangling. On weaving it will be replaced with link to chunk
  definition.
  ReST formatting in chunk name is supported.

**@<Chunk name@> = language** 
  Definition of the code chunk on the *language* programming
  language. Language name uses on weaving (to create `.. code ::
  language` structures in final document.

**@<Chunk name@> =+ language** 
  Extension of the already defined code chunk. For file chunks works
  exactly the same.

**@iftangle**/ **@endif** 
  Only tangle reads this block. Weave ignores anything between *@iftange*
  and *@endif*.

**@ifweave** / **@endif** 
  Only weave reads this block. Tangle
  ignores it.

**@skip** / **@endskip**
  Skip code between commands both for weaving and tangling
