namespace Epic;

class Schema {

  protected connection;
  protected db;
  protected typeMap;
  protected extending;
  protected extendSchema;

  public function __construct() {
    if this->extending {
      var className;
      let className = this->extending;
      let this->extendSchema = new {className};
      if this->db {
        this->extendSchema->setDb(this->db);
      }
      if this->connection !== null {
        this->extendSchema->setConnection(this->connection);
      }
    }
  }

  public function init() {

  }

  public function map() {
    var initial;
    if is_array(this->typeMap)  {
      let initial = this->typeMap;
      if this->extending {
        let this->typeMap = this->extendSchema->map();
      } else {
        let this->typeMap = new Map(this);
      }
      if is_array(initial) {
        this->typeMap->addType(initial);
      }
    }
    return this->typeMap;
  }

  public function resolve() {
    var result;
    var argv;
    int argc;
    let result = this;
    let argv = func_get_args();
    let argc = count(argv);
    if argc >= 1 && is_string(argv[0]) {
      let result = call_user_func_array([this, "resolveString"], argv);
    }
    return result;
  }

  public function resolveString(string type) {
    var result;
    var argv;
    var map;

    var matches;

    var docType;
    var mapKey;
    var pass;

    let argv = func_get_args();
    let map = this->map();
    let matches = preg_match("/^(doc|set|cursor)(?::(.*))?/", type);

    if matches {

      let docType = matches[1];
      let mapKey = matches[2];
      let pass = argv;

      if mapKey {
        switch docType {
          case "doc":
            let pass[0] = mapKey;
            break;
          case "set":
            while count(pass) < 3 {
              let pass[] = [];
            }
            let pass[0] = "set";
            if !isset(pass[2]["requirements"]) {
              let pass[2]["requirements"] = [];
            }
            if !isset(pass[2]["requirements"][""]) {
              let pass[2]["requirements"][""] = "doc:" . mapKey;
            }
            break;
          default:
            let pass[0] = "cursor";
            if !isset(pass[2]["schemaKey"]) {
              let pass[2]["schemaKey"] = "doc:" . mapKey;
            }
            break;
        }
      } else {
        let pass[0] = type;
      }

      let result = call_user_func_array([map, "getInstance"], pass);

    } else {

      let result = map->getStatic(type);

    }

    return result;

  }

}
