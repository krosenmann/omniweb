all: check html

tangle: 
	python3 ./bootstrap/tangle.py --in ./code --out ./sphinx_lp/

check: tangle
	mv ./sphinx_lp/tangle.py ./sphinx_lp/tangle1
	python3 ./sphinx_lp/tangle1 --in ./code --out ./sphinx_lp
	cmp ./sphinx_lp/tangle.py ./sphinx_lp/tangle1

weave: tangle
	python3 ./sphinx_lp/weave.py --in ./code/ --out ./source/

html: weave
	sphinx-build -b html source/ build/

package: tangle
	python3 -m build
