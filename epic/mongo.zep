namespace Epic;

class Mongo {

  static protected schemas;

  static protected connections;

  static public function addConnection(string name, string connection) {

    if isset(self::connections[name]) {

      throw new \Exception(name . " already exists");

    }

    let self::connections[name] = new Connection(connection);

  }

  static public function getConnection(string name = "default") {
    if !isset(self::connections[name]) {

      if name === "default" {

        self::addConnection("default");

      } else {

        throw new \Exception(name . " is not a defined connection.");

      }

    }

    return self::connections[name];

  }

  static public function addSchema(string name, var schema) {

    if isset(self::schemas[name]) {
      throw new \Exception(name . " already exists");
    }

    let self::schemas[name] = schema;

    return self::schemas[name];

  }

  static public function getSchema(string name) {

    if !isset(self::schemas[name]) {
      throw new \Exception(name . " does not exist");
    }

    return self::schemas[name];

  }

  static public function __callStatic(string name, array args) {

    return call_user_func_array([self::getSchema(name), "resolve"], args);

  }
}