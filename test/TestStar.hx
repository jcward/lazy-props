@:build(LazyProps.build())
class TestStar
{

  @:propPublic('c')
  @:propPrivate('*')
  public function new(a:Int,
                      b:Bool,
                      c:String,
                      d:String)
  {
    report();
  }

  private function report()
  {
    var out = "";
    out += a;
    out += b;
    out += c;
    out += d;
  }

  public static function main()
  {
    var test = new TestStar(10, false, "foo", "bar");
    trace(test.c); // public
  }
}
