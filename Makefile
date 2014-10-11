LIB = lib
BIN = bin
SRC = src
BIN_SOURCES = $(SRC)/$(BIN)/miyo-shiolink.coffee
LIB_SOURCES = $(SRC)/$(LIB)/miyo.coffee $(SRC)/$(LIB)/miyo-dictionaryloader.coffee
TARGETS = $(LIB)/miyo.js $(BIN)/miyo-shiolink.js

all: $(TARGETS)

clean :
	rm  $(TARGETS)

$(LIB)/miyo.js: $(LIB_SOURCES)
	coffee -cmbj $@ $^

$(BIN)/miyo-shiolink.js: $(BIN_SOURCES)
	coffee -cmbj $@ $^
	node -e "fs=require('fs');c='#!/usr/bin/env node\n'+fs.readFileSync('$@');fs.writeFileSync('$@', c)"

test:
	mocha test
cov:
	istanbul.cmd cover --report html c:\usr\nodist\bin\node_modules\mocha\bin\_mocha

doc: doc/index.html
doc/index.html:  $(LIB_SOURCES) $(BIN_SOURCES)
	codo --name "Miyo" --title "Miyo Documentation" src

.PHONY: test doc
