@:build(LazyProps.build())
class TestPrefix
{

  @:privatePrefix('PRIVATE_')
  @:publicPrefix('PUBLIC_')
  @:propPrivate('a')
  @:propPublic('b')
  public function new(a:Int,
                      b:Bool)
  {
    report();
    trace(a);
  }

  private function report()
  {
    trace("a="+PRIVATE_a+", b="+PUBLIC_b);
  }

  public static function main()
  {
    var test = new TestPrefix(10, false);
    trace(test.PUBLIC_b);
  }
}
