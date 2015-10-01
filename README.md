Remake of GlobGlob in Elm.

Ignore the server file for now, just trying to match the functionality added by Clement in his awesome [remake](https://github.com/clemsos/spacegame) (without knowing it :)

The original is by [Jennifer Dewalt](http://jenniferdewalt.com/index.html) [Here](http://jenniferdewalt.com/glob_glob/globs/1), part of her [180 websites in 180 days](http://jenniferdewalt.com/index.html)

Build instructions
==================
Install elm: (installing globally here, you can also install it locally and fix your PATH variable afterwards)
sudo npm -g elm

Build:
./make.sh

The initial build will install all the required packages, you need to answer yes to the question when asked if you want to download them.

Subsequent builds will proceed without any more network access.

Running
=======
Start a server and open a browser, I use python 2's SimpleHTTPServer or 3's http.server, the file locations may vary, on Fedora they are:
python2 /usr/lib64/python2.7/SimpleHTTPServer.py
python3 /usr/lib64/python3.4/http/server.py

It starts an HTTP server serving files from the local directory on port 8000 by default, so open:

http://localhost:8000/globglob.html
