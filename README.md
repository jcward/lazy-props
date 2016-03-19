<img align="right" src="https://cloud.githubusercontent.com/assets/2192439/13888490/5b058872-ed07-11e5-8244-931d338b5c80.png">

# Lazy Props

Haxe lazy (less typing) property definition macro

Motivation described in the writeup here: [jcward.com/Less+Glue+via+Haxe+Macro+Lazy+Props](http://jcward.com/Less+Glue+via+Haxe+Macro+Lazy+Props)

Installation
------------

Install from haxelib:

`haxelib install lazyprops`

Or for the development version:

`haxelib git lazyprops https://github.com/jcward/lazy-props`

In a nutshell
-------------

Lazy Props declares and assigns class properties automatically based on constructor:
![less_glue](https://cloud.githubusercontent.com/assets/2192439/13889013/f779165e-ed09-11e5-8ce4-0aa02a190623.jpg)

Usage
-----

After installing from haxelib, add `-lib lazyprops` to your `build.hxml` file -- (library syntax varies for OpenFL, NME, Snow, Kha, etc.)

Any classes to be parsed by Lazy Props must have the `@:build(LazyProps.build())` metadata before the class declaration. Then, all Lazy Props metadata tags go on the class constructor. See the [example](https://github.com/jcward/lazy-props/blob/master/test/Main.hx).

Troubleshooting
---------------

I'm working on better error messages. In the meantime:

- Ensure the `@:build(LazyProps.build())` tag is present on the class
- Check the Lazy Props tag names are spelled properly, including the `@:`, and without a trailing semi-colon, e.g. `@:propPrivate('*')`
- Verify the validity of the syntax (no stray spaces, commas, etc)
- Verify the property names in the tags match the variable names in the constructor
- Ensure the property isn't already defined (in the class or super classes)

Supported metadata tags:
-------------------------

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
@:publicPrefix()
@:privatePrefix()
```

@:prop syntax
---------------

The syntax for `@:prop()` is similar to the Haxe property declaraction syntax, except without the
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

The syntax for the other property metatags (e.g. `@:propPrivate()`, `@:propPublic()`, etc) is typically
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

Note that private `readOnly`, `getOnly`, `writeOnly`, and `setOnly` are enforced with the `never` access pattern (e.g. `private name(default,never)`)
which means that the vairable cannot be written or read, even from within the class itself. The constructor assignment
for set-never variables uses a dynamic assignment (e.g. `Reflect.setField(this, "name", name);` to avoid a compiler error,
thus assigning the constructed value, but never allowing it to be changed in type-checked code.

@:*prefix syntax
---------------

The `@:privatePrefix('')`, `@:publicPrefix('')` metadata tags allow your class members to use a prefixed naming convention compared to your constructor parameters. For example, with a private prefix of `@:privatePrefix('_')`, the constructor arg `width:Float` becomes the private member variable `_width:Float`.

- The default prefix for both public and private is an empty string (no prefix.)
- The metatags are defined in order, so these tags should go at the top of the list.
