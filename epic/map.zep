namespace Epic;

class Map {

  protected _static;
  protected _map;
  protected _schema;

  public function __construct(var schema = null) {
    let this->_schema = schema;
  }

  public function getClass(string type) {
    if !isset(this->_map[type]) {
      if type == "doc" {
        let this->_map[type] = "Epic_Mongo_Document";
        return this->_map[type];
      }
      if type == "set" {
        let this->_map[type] = "Epic_Mongo_DocumentSet";
        return this->_map[type];
      }
      if type == "cursor" {
        let this->_map[type] = "Epic_Mongo_Iterator_Cursor";
        return this->_map[type];
      }
      throw new \Exception(type . " has not be defined.");
    }
    return this->_map[type];
  }

  public function addType(var className, string type = "") {
    if is_array(className) {
      array_walk(className, [this, "addType"]);
      return;
    }
    if !class_exists(className) {
      throw new \Exception(className . " is not a class.");
    }
    if isset(this->_map[type]) && !is_subclass_of(className, this->_map[type]) {
      throw new \Exception(className . " does not extend " . this->_map[type]);
    }
    let this->_map[type] = className;
  }

  public function getStatic(string type) {
    if isset(this->_static[type]) {
      return this->_static[type];
    }
    let this->_static[type] = this->getInstance(type);
    return this->_static[type];
  }

  public function getInstance(type) {
    var _class;
    var argv;
    var pass;
    var reflector;

    let _class = this->getClass(type);
    let argv = func_get_args();
    let pass = array_slice(argv, 1);
    let reflector = new \ReflectionClass(_class);
    if method_exists(_class, "isDocumentClass") && this->_schema {
      var config;
      let config = {_class}::isDocumentClass() ? 1 : 0;
      if !isset(pass[0]) {
        let pass[0] = [];
      }
      if !isset(pass[config]) {
        let pass[config] = [];
      }
      let pass[config]["schema"] = this->_schema;
      let pass[config]["schemaKey"] = type;
    }
    return call_user_func_array([reflector, "newInstance"], pass);
  }
}