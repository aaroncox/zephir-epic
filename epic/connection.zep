namespace Epic;

class Connection {

  protected connection;
  protected connectionString;


  public function __construct(string connection = "mongodb://localhost:27017", options = []) {
    let this->connectionString = connection;
    let this->connection = new \MongoClient();
  }

  public function getConnectionInfo() {
    return this->connectionString;
  }

  public function selectDB(name) {
    return this->connection->{name};
  }

}