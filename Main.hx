import haxe.ds.StringMap;

@:build(LazyProps.build())
class Main {

  @propPublicReadOnly("width,height")
  @prop("pu foo(g,s)|u name(d,d)")
  @propPrivateGetOnly("unwritable")
  @propPrivate("*") // Everything else

  public function new(width:Float,
                      height:Float,
                      name:String,
                      unwritable:String, // Writes value with Reflect.setField
                      config:StringMap<Dynamic>,
                      foo:Foo)
  {
    trace("Locals: "+width+", "+height+", "+name+", "+unwritable+", "+config+", "+foo);
    show_props();
    Test.test_access(this);
    show_props();

    //Reflect.setField(this, "unwritable", "foo");
    //trace(unwritable);
    //unwritable = "as";
  }

  public function get_foo():Foo { trace("Getting foo..."); return foo; }
  public function set_foo(f:Foo):Foo { trace("Setting foo..."); foo = f; return f; }

  public function get_unwritable():String { return "PREFIX:"+unwritable; }

  private function show_props() {
    trace("Props: "+width+", "+height+", "+name+", "+unwritable+", "+config+", "+foo);
  }

  static function main()
  {
    new Main(10, 20, "Human", "cannot change", ["hi"=>""], new Foo());
  }

}

class Foo {
  public function new() { }
}

class Test
{
  public static function test_access(m:Main):Void
  {

    // public read-only
    // m.width = 500;
    // m.height = 200;
    m.name = "yaya";
    // never setter
    //m.foo = new Foo();

    // private
    // m.config = ["no"=>""];

    var a = "";
    a += (m.width);
    a += (m.height);
    a += (m.foo);     // cannot access private field foo for writing
    a += (m.name);
    // trace(m.config); // cannot access private field config

  }
}


/*
  @:isVar
  public var someGSPrivate(get,set):Int;

  public function get_someGSPrivate():Int { return someGSPrivate; }
  public function set_someGSPrivate(f:Int):Int { someGSPrivate = f; return f; }
*/

  // { kind => FProp(get,set,TPath({ name => StringMap, pack => [], params => [TPType(TPath({ name => String, pack => [], params => [] }))] }),null), meta => [], name => someGSPublic, doc => null, pos => #pos(Main.hx:6: characters 9-53), access => [APublic] }
  // private var someGSPublic(get,set):StringMap<String>;

  // { kind => FVar(TPath({ name => Int, pack => [], params => [] }),null), meta => [], name => somePrivateIntProperty, doc => null, pos => #pos(Main.hx:5: characters 10-41), access => [APrivate] }
  // private var somePrivateIntProperty:Int;

  // { kind => FProp(default,null,TPath({ name => StringMap, pack => [], params => [TPType(TPath({ name => String, pack => [], params => [] }))] }),null), meta => [], name => someROStringMapProperty, doc => null, pos => #pos(Main.hx:9: characters 9-69), access => [APublic] }
  // public var someROStringMapProperty(default,null):StringMap<String>;

  //var width:Float;
