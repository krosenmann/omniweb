Configuration
=============

Config file
-----------

Command line arguments
----------------------

List of files or wildcards


.. code-block:: python
   :caption: **<Command line arguments>** =
   :name: code_config.sphweb_12
   :force:

    import argparse
    
    
    def cli_args():
        parser = argparse.ArgumentParser()
        parser.add_argument('--in', dest='_in')
        parser.add_argument('--out', dest='output_dir')
        return parser.parse_args()
    
Chunk defined at:

#. :ref:`Command line arguments 0 <code_config.sphweb_12>`

Related chuks:


Chunk used in:

#. :ref:`tangle.py <code_tangle.sphweb_13>`
