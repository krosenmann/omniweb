tangle: 
	python3 ./bootstrap/tangle.py --in ./code --out ./tangled/

check: tangle
	mv ./tangled/tangle.py ./tangled/tangle1
	python3 ./tangled/tangle1 --in ./code --out ./tangled
	cmp ./tangled/tangle.py ./tangled/tangle1

weave: tangle
	python3 ./tangled/weave.py --in ./code/ --out ./source/code-doc/

html: weave
	sphinx-build -b html source/ build/
