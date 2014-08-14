namespace Epic;

class Document extends Collection implements \ArrayAccess, \Countable, \IteratorAggregate {

  protected _id;
  protected _config;
  protected _data;
  protected _cleanData;
  protected _requirements;
  protected _typeMap;

  public function __construct(data = [], config = []) {
    this->setRequirements(this->_typeMap ? this->_typeMap : []);
    parent::__construct(config);

    let this->_cleanData = data;

    if this->isNewDocument() && this->hasKey() {
      if isset(data["_id"]) {
        let this->_id = new \MongoId(data["_id"]);
      } else {
        let this->_id = new \MongoId;
      }
    }

    if this->hasId() {
      var criteria;
      let criteria = [];
      let criteria[this->getPathToProperty("_id")] = this->_id;
      this->setCriteria(criteria);
    }

  }

  public function getCriteria() {
    if !array_key_exists("criteria", this->_config) {
      return [];
    }
    return this->_config["criteria"];
  }

  public function setCriteria(array criteria) {
    if !array_key_exists("criteria", this->_config) {
      let this->_config["criteria"] = [];
    }
    let this->_config["criteria"] = array_merge(criteria, this->_config["criteria"]);
    return this;
  }

  public function isRootDocument() {
    return !(array_key_exists("pathToDocument", this->_config) && this->_config["pathToDocument"]);
  }

  public function getPathToDocument() {
    return this->_config["pathToDocument"];
  }

  public function setPathToDocument(path = "") {
    let this->_config["pathToDocument"] = path;
    return this;
  }

  public function doc(key, data = null) {
    var set, doc, config, schemaType; //ref, 
    if(array_key_exists(key,this->_data)) {
      return this->_data[key]->extend(data);
    }
    if (!is_array(data)) {
      let data = [];
    }
    let set = this->hasRequirement(key,"set");
    let doc = this->hasRequirement(key,"doc");
    // let ref = MongoDBRef::isRef(data);
    let config = [];
    // if ref {
    //   let config["collection"] = data["$ref"];
    //   let config["isReference"] = true;
    //   let data = MongoDBRef::get(this->getSchema()->getMongoDB(), data);
    //   // If this is a broken reference then no point keeping it for later
    //   if (!data) {
    //     if(this->hasRequirement(key,"auto")) {
    //       let data = [];
    //     } else {
    //       let this->_data[key] = null;
    //       return this->_data[key];
    //     }
    //   }
    // }
    if !(doc || set) {
      let set = this->_dataIsSimpleArray(data);
    }
    let schemaType = set ? "set" : "doc";
    if this->getRequirement(key, schemaType) {
      let schemaType .= ":" . this->getRequirement(key, schemaType);
    }
    let doc = this->getSchema()->resolve(schemaType, data, config);
    this->setProperty(key,doc);
    return doc;
  }

  protected function _resolveProperty(key, data) {
    var automatic;
    let automatic = this->hasRequirement(key, "auto");
    if this->hasRequirement(key, "array") {
      if (!data) {
        let data = [];
      }
      let this->_data[key] = data;
      return this->_data[key];
    }
    if automatic || is_array(data) {
      let data = this->doc(key, data);
    }
    if !is_null(data) {
      let this->_data[key] = data;
    }
    return data;
  }

  protected function _dataIsSimpleArray(data) {
    var k, keys;
    if(empty(data)) {
      return false;
    }
    let keys = array_keys(data);
    for k in keys {
      if is_string(k) {
        return false;
      }
    }
    return true;
  }

  public function getProperty(key) {
    // if the data has already been loaded
    if array_key_exists(key, this->_data) {
      return this->_data[key];
    }
    // read from cleanData
    if array_key_exists(key, this->_cleanData) {
      return this->_resolveProperty(key, this->_cleanData[key]);
    }
    return this->_resolveProperty(key, null);
  }

  public function setProperty(key, value) {
    var config;
    if (value instanceof new Document) && !this->hasRequirement(key, "ref") {
      let config = this->getConfigForProperty(key,value);
      value->setConfig(config);
    }
    let this->_data[key] = value;
    return value;
  }

  public function hasProperty(key) {
    if array_key_exists(key, this->_data) {
      return !is_null(this->_data[key]);
    }
    return (array_key_exists(key, this->_cleanData) && !is_null(this->_cleanData[key]));
  }

  public function createReference() {
    if !this->hasCollection() {
      throw new \Exception("Can not create reference. Document does not belong to a collection");
    }
    if !this->isRootDocument() {
      throw new \Exception("Can not create reference. Document is not root");
    }
    return \MongoDBRef::create(this->getCollection(), this->_id);
  }

  public function isEmpty() {
    var doNoCount, key, value;
    let doNoCount = [];

    for key, value in this->_data {
      if value instanceof Epic\Document {
        if !value->isEmpty() {
          return false;
        }
      } else {
        if !is_null(value) {
          return false;
        }
      }
      let doNoCount[] = key;
    }

    for key, value in this->_cleanData {
      if !(in_array(key, doNoCount) || is_null(value)) {
        return false;
      }
    }

    return true;
  }

  public function getPropertyKeys() {
    var keyList, ignore, key, value;
    let keyList = [];
    let ignore = [];
    if this->_data {
      for key, value in this->_data {
        if is_null(value) || ((value instanceof new Document) && value->isEmpty()) {
          let ignore[] = key;
        } else {
          let keyList[] = key;
        }
      }
    }
    for key, value in this->_cleanData {
      if in_array(key, ignore) || in_array(key,keyList) {
        continue;
      }
      if !is_null(value) {
        let keyList[] = key;
      }
    }
    return keyList;
  }

  public function getPathToProperty(property = null) {
    if is_null(property) {
      return this->getPathToDocument();
    }
    return this->isRootDocument() ? property : this->getPathToDocument() . "." . property;
  }

  protected function getConfigForProperty(key, data) {
    var config;
    let config = [
      "requirements": this->getRequirements(key . ".")
    ];
    if !this->isReference(key) {
      let config["collection"] = this->getCollection();
      let config["pathToDocument"] = this->getPathToProperty(key);
      let config["criteria"] = this->getCriteria();
    }
    if this->_schema {
      let config["schema"] = this->_schema;
    }
    return config;
  }


  public function getRequirement(property, requirement) {
    if !this->hasRequirement(property, requirement) {
      return false;
    }
    var value;
    switch(requirement) {
      case "doc":
      case "set":
        let value = this->_requirements[property][requirement];
        if !value {
          let value = false;
        }
        break;

      default:
        let value = true;
        break;
    }
    return value;
  }

  public function getRequirements(prefix = null) {
    if prefix === null {
      return this->_requirements;
    }
    var k,v,filtered;
    let filtered = [];
    for k,v in this->_requirements {
      if substr(k, 0, strlen(prefix)) == prefix {
        let filtered[substr(k, strlen(prefix))] = v;
      }
    }
    return filtered;
  }

  public function hasRequirement(property, requirement) {
    if !array_key_exists(property, this->_requirements) {
      return false;
    }
    return array_key_exists(requirement, this->_requirements[property]);
  }

  public function setRequirements(array requirements) {
    let this->_requirements = this->_parseRequirementsArray(this->_requirements);
    let this->_requirements = array_merge_recursive(this->_requirements, this->_parseRequirementsArray(requirements));
    return this;
  }

  protected function _parseRequirementsArray(array requirements) {
    var property, requirementList;
    for property, requirementList in requirements {
      if !is_array(requirementList) {
        let requirements[property] = [requirementList];
      }
      var newRequirements, parts, key, requirement;
      let newRequirements = [];
      for key, requirement in requirements[property] {
        if is_numeric(key) {
          let parts = explode(":", requirement, 2);
          if count(parts) > 1 {
            let newRequirements[parts[0]] = parts[1];
          } else {
            let newRequirements[requirement] = null;
          }
        } else {
          let newRequirements[key] = requirement;
        }
      }
      let requirements[property] = newRequirements;
    }
    return requirements;
  }

  public function isReference(string key) {
    var data;
    if array_key_exists(key, this->_data) {
      let data = this->_data[key];
      if get_class(data) == "Document" && data->getConfig("isReference") {
        return "data";
      }
    }
    if array_key_exists(key, this->_cleanData) { //  && \MongoDBRef::isRef(this->_cleanData[key])
      return "clean";
    }
    if this->hasRequirement(key, "ref") {
      return "requirement";
    }
    return false;
  }

  public function isNewDocument() {
    return empty(this->_cleanData);
  }

  public function hasId() {
    return !is_null(this->_id);
  }

  public function hasKey() {
    return this->isRootDocument() && this->hasCollection();
  }

    /**
   * Get an offset
   *
   * @param string offset
   * @return mixed
   */
  public function offsetGet(offset)
  {
    return this->getProperty(offset);
  }

  /**
   * set an offset
   *
   * @param string offset
   * @param mixed value
   */
  public function offsetSet(offset, value)
  {
    return this->setProperty(offset, value);
  }

  /**
   * Test to see if an offset exists
   *
   * @param string offset
   */
  public function offsetExists(offset) {
    return this->hasProperty(offset);
  }

  /**
   * Unset a property
   *
   * @param string offset
   */
  public function offsetUnset(offset)
  {
    this->setProperty(offset, null);
  }

  /**
   * Count all properties in this document
   *
   * @return int
   */
  public function count()
  {
    return count(this->getPropertyKeys());
  }

  /**
   * Get the document iterator
   *
   * @return Shanty_Mongo_DocumentIterator
   */
  public function getIterator()
  {
    var className;
    let className = "Epic\\Iterator\\Document";
    return new { className }(this);
  }

}