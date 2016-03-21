import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class LazyProps {
  macro static public function build():Array<Field> {
    var private_prefix:String = '';
    var public_prefix:String = '';
    var fields = Context.getBuildFields();
    var fields_to_add:Array<Field> = [];
    var names_added:Array<String> = [];
    for (field in fields) {
      //trace(field);
      if (field.name=="new") {
        //trace("new at: "+Context.currentPos());

        function make_property(name:String, acc:Access, get:String=null, set:String=null)
        {
          var prefix:String = acc==APrivate ? private_prefix : public_prefix;
          var exceptions = [];
          if (name.indexOf('*')==0) { // *-foo,bar
            var exc = name.split('-')[1];
            if (exc!=null) for (x in exc.split(',')) exceptions.push(x);
            name = '*';
          }
          // 1) find the type in the constrctor args
          var t:Null<ComplexType> = null;
          var args:Array<FunctionArg> = field.kind.getParameters()[0].args; 
          for (arg in args) {
            if (arg.name==name) {
              t = arg.type;
            } else if (name=='*' && (names_added.indexOf(arg.name)<0 && exceptions.indexOf(arg.name)<0)) {
              make_property(arg.name, acc, get, set);
            }
          }
          if (name=='*') return;
          if (t==null) throw('LazyProps: Constructor arg ${name} not found!');

          if (get=="get") get = 'get_$prefix$name';
          if (set=="set") set = 'set_$prefix$name';

          if (Context.defined('LAZY_PROPS_DEBUG'))
            trace('Making property: $acc $prefix$name ($get, $set):$t');

          names_added.push(name);

          // 2) insert expression to assign local to prop (unless set=='never')
          if (set!='never') {
            var construct:Expr = field.kind.getParameters()[0].expr;
            var exprs:Array<Expr> = construct.expr.getParameters()[0];
            exprs.unshift(Context.parse('this.$prefix$name = $name', Context.currentPos()));
          } else {
            var construct:Expr = field.kind.getParameters()[0].expr;
            var exprs:Array<Expr> = construct.expr.getParameters()[0];
            exprs.unshift(Context.parse('Reflect.setField(this, "$prefix$name", $name)', Context.currentPos()));
          }

          // 3) insert property definition into class fields
          if (get==null && set==null) {
            fields_to_add.push({
              name: prefix+name,
              doc: null,
              meta: [],
              access: [acc],
              kind: FVar(t), //, e),
              pos: Context.currentPos()
            });
          } else {
            fields_to_add.push({
              name: prefix+name,
              doc: null,
              meta: [ { name:":isVar", params:[], pos:Context.currentPos() }],
              access: [acc],
              kind: FProp(get, set, t), //, e),
              pos: Context.currentPos()
            });
          }
        }

        function expand_shorthand(sh:String):String
        {
          if ("private".indexOf(sh)==0) return "private"; // p -> private
          if ("public".indexOf(sh)==0) return "public";
          if ("default".indexOf(sh)==0) return "default";
          if ("get".indexOf(sh)==0) return "get";
          if ("set".indexOf(sh)==0) return "set";
          if ("null".indexOf(sh)==0) return "null";       // n -> null
          if ("never".indexOf(sh)==0) return "never";     // ne -> never
          if (sh=='u') return 'public';
          if (sh=='v') return 'never';

          return sh;
        }

        function parse_prop(def:String):Void
        {
          var acc = APrivate;
          if (def.indexOf(' ')>=0) {
            var s = def.split(' '); 
            acc = (expand_shorthand(s[0])=='public') ? APublic : APrivate;
            def = s[1];
          }
          var name:String;
          var getset:Array<String> = [null, null];
          var idx = def.indexOf('(');
          if (idx>=0) {
            name = def.substr(0, idx);
            getset = def.substr(idx+1, def.length-idx-2).split(',');
            getset[0] = expand_shorthand(getset[0]);
            getset[1] = expand_shorthand(getset[1]);
          } else {
            name = def;
          }
          make_property(name, acc, getset[0], getset[1]);
        }

        // Scan meta tags for properties to build
        for (meta in field.meta) {
          if (meta.name==":prop") { // Syntax: public width(get,set)
            var def:String = ExprTools.getValue(meta.params[0]);
            if (def.indexOf('|')>=0) {
              for (prop in def.split('|')) parse_prop(prop);
            } else {
              parse_prop(def);
            }
          }
          else if (meta.name==":propPublic") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APublic);
          }
          else if (meta.name==":propPrivate") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APrivate);
          }
          else if (meta.name==":propPublicGetSet") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APublic, 'get', 'set');
          }
          else if (meta.name==":propPrivateGetSet") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APrivate, 'get', 'set');
          }
          else if (meta.name==":propPublicReadOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APublic, 'default', 'null');
          }
          else if (meta.name==":propPublicWriteOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APublic, 'null', 'default');
          }
          else if (meta.name==":propPublicGetOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APublic, 'get', 'null');
          }
          else if (meta.name==":propPublicSetOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APublic, 'null', 'set');
          }
          else if (meta.name==":propPrivateReadOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APrivate, 'default', 'never');
          }
          else if (meta.name==":propPrivateWriteOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APrivate, 'never', 'default');
          }
          else if (meta.name==":propPrivateGetOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APrivate, 'get', 'never');
          }
          else if (meta.name==":propPrivateSetOnly") {
            var def:String = ExprTools.getValue(meta.params[0]);
            for (name in def.split(',')) make_property(name, APrivate, 'never', 'set');
          }
          else if (meta.name==":privatePrefix") {
            private_prefix = ExprTools.getValue(meta.params[0]);
          }
          else if (meta.name==":publicPrefix") {
            public_prefix = ExprTools.getValue(meta.params[0]);
          }
        }
      }
    }

    for (field in fields_to_add) fields.push(field);

    return fields;
  }
}
