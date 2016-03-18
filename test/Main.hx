class Main {
  public static function main() {
    new Greeter("Jeff").greet();
    new PoliteGreeter("Warmest greetings", "Jeff").greet();
  }
}

@:build(LazyProps.build())
class Greeter {

  @:propPrivate('*')
	public function new(name:String)
  {
  }
  
  public function greet()
  {                    
    trace("Oh look, it's "+name);
  }
}

@:build(LazyProps.build())
class PoliteGreeter extends Greeter {

  @:propPrivate('*-name')
	public function new(salutation:String,
                      name:String)
  {
    super(name);
  }
  
  override public function greet()
  {                    
    trace(salutation+", "+name+"!");
  }
}
