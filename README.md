Remake of GlobGlob in Elm.

Ignore the server file for now, just trying to match the functionality added by Clement in his awesome [remake](https://github.com/clemsos/spacegame) (without knowing it :)

The original is by [Jennifer Dewalt](http://jenniferdewalt.com/index.html) [Here](http://jenniferdewalt.com/glob_glob/globs/1), part of her [180 websites in 180 days](http://jenniferdewalt.com/index.html)

Build instructions
==================
Install elm: (installing globally here, you can also install it locally and fix your PATH variable afterwards)
sudo npm -g elm

Build:
make

The initial build will install all the required packages, you need to answer yes to the question when asked if you want to download them.

Subsequent builds will proceed without any more network access.

Running for testing/development
===============================
make run

It starts an HTTP server serving files from the local directory on port 8000 by default, so open:

http://localhost:8000/
