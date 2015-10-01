all: globglob.js

globglob.js: GlobGlob.elm
	elm-make --warn --output globglob.js GlobGlob.elm

.PHONY: run

run:
	python globglob-server.py
