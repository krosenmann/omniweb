# code/parser.sphweb:317 <../test.mk>
.ONESHELL:
SHELL = python3
test:
	@import doctest
	doctest.testfile("code/parser.sphweb")

# code/parser.sphweb:323 End of <../test.mk>
