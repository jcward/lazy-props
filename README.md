<img align="right" src="https://cloud.githubusercontent.com/assets/2192439/13888490/5b058872-ed07-11e5-8244-931d338b5c80.png">

# Lazy Props

Haxe lazy (less typing) property definition macro

Motivation described in the writeup here: [jcward.com/Less+Glue+via+Haxe+Macro+Lazy+Props](http://jcward.com/Less+Glue+via+Haxe+Macro+Lazy+Props)

Declares and assigns class properties automatically based on constructor:
![less_glue](https://cloud.githubusercontent.com/assets/2192439/13889013/f779165e-ed09-11e5-8ce4-0aa02a190623.jpg)

Supported metadata tags:
-------------------------

All Lazy Props metadata tags go on the class constructor. The class itself must be prepended with the `@:build(LazyProps.build())` metadata to invoke the Lazy Props macro. See the [example](https://github.com/jcward/lazy-props/blob/master/test/Main.hx).

```
@:prop()
@:propPublic()
@:propPrivate()
@:propPublicGetSet()
@:propPrivateGetSet()
@:propPublicReadOnly()
@:propPublicWriteOnly()
@:propPublicGetOnly()
@:propPublicSetOnly()
@:propPrivateReadOnly()
@:propPrivateWriteOnly()
@:propPrivateGetOnly()
@:propPrivateSetOnly()
```

@:prop syntax
---------------

The syntax for `@:prop('')` is similar to the Haxe property declaraction syntax, except without the
type definition, and all the string constant names can be abbreviated. Examples include:

```
@:prop('public name(get,set)')
@:prop('pub name(g,s)')         // public get set
@:prop('pri name(def,n)')       // private default null
@:prop('u name(d,v)')           // public default never
@:prop('pu name(n,ne)')         // public null never
```

@:prop* syntax
---------------

The syntax for the other metatags (e.g. `@:propPrivate('')`, `@:propPublic('')`, etc) is typically
a comma separated list with no spaces. There is also a `*` which catches all remaining constructor
properties that haven't yet been defined. The `*` supports an ignore list (to avoid redeclarations
in classes where a property is defined by a super class.)

```
@:propPrivate('*')              // all properties in the constructor become private vars
@:propPrivate('*-name,age')     // all properties (except `name` and `age`)
```

In this example, two properties are declared public read-only, while the rest are declared private:

```
@:propPublicReadOnly('name,age')
@:propPrivate('*')
```

Note that `privateReadOnly` and `privateGetOnly` uses the `never` access pattern (e.g. `private name(default,never)`)
which means that the vairable cannot be set, even from within the class itself. The constructor assignment
inserted uses a dynamic assignment (e.g. `Reflect.setField(this, "name", name);` to avoid a compiler error,
thus assigning the constructed value, but never allowing it to be changed.
