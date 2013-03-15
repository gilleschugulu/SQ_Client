# 12-coups-midi-client
HTML5 application
====================

### Tools ###

* brunch (1.5.0-pre) ([website](http://brunch.io/), [github](https://github.com/brunch/brunch))
Clone and install it via :

```
git clone https://github.com/brunch/brunch
cd brunch
sudo npm -g install
```

If you are updating from an old version of brunch run:
```
cd brunch
npm cache clean
rm -rf node_modules
npm install
```

* nodejs (0.8.15) http://nodejs.org
* npm (1.1.66) installed with nodejs package


### Libraries ###

* Cordova/Phonegap ([website](http://phonegap.com))
* BackboneJS ([website](http://backbonejs.org/))
* ChaplinJS ([website](http://chaplinjs.org/), [github](https://github.com/chaplinjs/chaplin))
* ZeptoJS ([website](http://zeptojs.com/))
* fastclick ([github](https://github.com/ftlabs/fastclick))
* MorrisJS ([website](http://www.oesmith.co.uk/morris.js/), [github](https://github.com/oesmith/morris.js))
* Raphaël ([website](http://raphaeljs.com/), [guthub](https://github.com/DmitryBaranovskiy/raphael))


# Setup #
```
git submodule update --init
bundle install
cd brunch
npm install
```

## Compile and Launch ##
In the project directory

```
cd brunch
brunch watch -c config/web
```
If you have see this error :

```
Error: EMFILE, too many open files
```

You have to run this :

```
ulimit -n 10000
```

If you have see this error :

```
stream.js:81
      throw er; // Unhandled stream error in pipe.
            ^
Error: EMFILE, open 'build/web/images/interstage/stage_1.jpg'
```

You have to relaunch brunch !

In your browser, go to ``localhost:3333``


If you encounter ```X-Origin``` errors in Chrome (OSX), execute teh script

```bash
#!/bin/bash
chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
file_type=`file "$chrome_path"`
echo $file_type
if [[ "$file_type" != "$chrome_path: ASCII text" ]]; then
  mv "$chrome_path" "$chrome_path.bin"
  echo "\"$chrome_path.bin\" --disable-web-security" >> "$chrome_path"
  chmod u+x,g+x,o+x "$chrome_path"
fi
```
