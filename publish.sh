rm lazyprops.zip
cat haxelib.json | grep -i ver
zip -j lazyprops.zip build.hxml haxelib.json src/LazyProps.hx LICENSE README.md
haxelib submit lazyprops.zip
