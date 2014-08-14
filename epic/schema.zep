namespace Epic;

class Schema {

  protected _connection;
  protected _db;
  protected _typeMap;
  protected _extending;
  protected _extendSchema;

  public function __construct() {
    if this->_extending {
      var className;
      let className = this->_extending;
      let this->_extendSchema = new {className};
      if this->_db {
        this->_extendSchema->setDb(this->_db);
      }
      if this->_connection !== null {
        this->_extendSchema->setConnection(this->_connection);
      }
    }
  }

  public function setDb(db) {
    let this->_db = db;
  }

  public function getDb() {
    if !is_string(this->_db) {
      if this->_extendSchema {
        return this->_extendSchema->getDb();
      }
      throw new \Exception("No DB defined");
    }
    return this->_db;
  }

  public function getMongoDb() {
    return Mongo::getConnection(this->getConnection())->selectDb(this->getDb());
  }

  public function getConnection() {
    if this->_connection == null && this->_extendSchema {
      return call_user_func([this->_extendSchema, "getConnection"]);
    }
    if this->_connection == null {
      return "default";
    }
    return this->_connection;
  }

  public function setConnection(connection) {
    let this->_connection = connection;
  }

  public function init() {

  }

  public function map() {
    var initial;
    if is_array(this->_typeMap)  {
      let initial = this->_typeMap;
      if this->_extending {
        let this->_typeMap = this->_extendSchema->map();
      } else {
        let this->_typeMap = new Map(this);
      }
      if is_array(initial) {
        this->_typeMap->addType(initial);
      }
    }
    return this->_typeMap;
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

  public function resolveString(string type, cursor = null, schema = null) {
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

      let docType = explode(":", type)[0];
      let mapKey = explode(":", type)[1];
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
