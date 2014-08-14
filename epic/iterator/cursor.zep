namespace Epic\Iterator;

class Cursor implements \Iterator, \Countable {
  protected _cursor = null;
  protected _config = [];

  /**
   * __construct
   *
   * @return void
   */
  public function __construct(<\MongoCursor> cursor, config = []) {
    let this->_cursor = cursor;
    let this->_config = config;
  }

  /**
   * Returns the count of documents in the MongoCursor
   *
   * @return MongoCursor
   */
  public function count() {
    return this->getInnerIterator()->count();
  }

  /**
   * Get the inter iterator
   *
   * @return MongoCursor
   */
  public function getInnerIterator() {
    return this->_cursor;
  }

  /**
   * Get the collection name
   *
   * @return string
   */
  public function getCollection() {
    if array_key_exists("collection", this->_config) {
      return this->_config["collection"];
    }
    return null;
  }

  /**
   * Get the class name of a document
   *
   * @return string
   */
  public function getDocumentClass() {
    if isset(this->_config["documentClass"]) {
      return this->_config["documentClass"];
    }
    return "Epic\\Document";
  }

  public function getSchema() {
    if(!isset(this->_config["schema"])) {
      throw new \Exception("Requires Schema");
    }
    return this->_config["schema"];
  }

  /**
   * Export all data
   *
   * @return array
   */
  public function export() {
    this->rewind();
    return iterator_to_array(this->getInnerIterator());
  }

  /**
   * Get the current value
   *
   * @return mixed
   */
  public function current() {
    var data, config, documentClass;

    let data = this->getInnerIterator()->current();

    if(is_null(data)) {
      return null;
    }

    let config = this->_config;
    let config["hasKey"] = true;

    if(isset(config["schemaKey"])) {
      return this->getSchema()->resolve(config["schemaKey"], data, config);
    }
    let documentClass = this->getDocumentClass();
    return new {documentClass}(data, config);
  }

  public function key() {
    return this->getInnerIterator()->key();
  }

  public function next() {
    return this->getInnerIterator()->next();
  }

  public function rewind() {
    return this->getInnerIterator()->rewind();
  }

  public function valid() {
    return this->getInnerIterator()->valid();
  }

  public function __call(string method, array arguments) {
    call_user_func_array([this->getInnerIterator(), method], arguments);
    return this;
  }
}