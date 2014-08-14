namespace Epic;

class Collection {
  protected _collection;
  protected _schema;
  protected _config;

  public function __construct(config = []) {
    this->setConfig(config);
  }

  public function setConfig(array config) {
    var k, v, calledClass, method;
    let calledClass = get_called_class();
    for k,v in config {
      let this->_config[k] = v;
      let method = "set" . ucfirst(k);
      if method_exists(calledClass, method) {
        call_user_func([this, method], v);
      }
    }
  }

  public function getConfig(string key) {
    if array_key_exists(key, this->_config) {
      return this->_config[key];
    }
    return null;
  }

  public function setSchema(schema) {
    let this->_schema = schema;
  }

  public function getSchema() {
    if !this->_schema {
      throw new \Exception("Schema Required");
    }
    return this->_schema;
  }

  public function setCollection(string name) {
    let this->_collection = name;
  }

  public function getCollection() {
    return this->_collection;
  }

  public function hasCollection() {
    return !!this->_collection;
  }

  public function update(array query, array update, array params = ["w": 1]) {
    var db, collection;
    let db = this->getSchema()->getMongoDb();
    let collection = db->selectCollection(this->getCollection());
    return collection->update(query, update, params);
  }

  public function find(array query = [], array fields = []) {
    var db, collection, cursor, config;
    let db = this->getSchema()->getMongoDb();
    let collection = db->selectCollection(this->getCollection());
    let cursor = collection->find(query, fields);
    let config = [
      "schema": this->getSchema(),
      "collection": this->getCollection(),
      "schemaKey": "doc:" . this->_config["schemaKey"]
    ];
    return this->getSchema()->resolve("cursor:".this->_config["schemaKey"], cursor, config);
  }

  public static function isDocumentClass() {
    var _class;
    let _class = get_called_class();
    return _class == "Epic\\Document" ||  is_subclass_of(get_called_class(), "Epic\\Document");
  }
}