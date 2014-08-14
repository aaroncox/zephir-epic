<?php

class TestSchema extends Epic\Schema {
  protected $_db = 'phpunit';
  protected $_typeMap = array(
    'test' => 'TestDocument',
  );

}

class TestDocument extends Epic\Document {
  protected $_collection = "test";
}

Epic\Mongo::addConnection('default', 'mongodb://localhost:27017');
Epic\Mongo::addSchema('db', new TestSchema());
// var_dump(Epic\Mongo::getSchema('db')); 
$queries = array(
  array('x' => array('$gt' => 10)),
  array('x' => array('$gt' => 20)),
  array('x' => array('$gt' => 30)),
  array('x' => array('$gt' => 40)),
  array('x' => array('$gt' => 50)),
  array('x' => array('$gt' => 60)),
  array('x' => array('$gt' => 70)),
  array('x' => array('$gt' => 80)),
  array('x' => array('$gt' => 90)),
  array('x' => array('$gt' => 100)),
  array('x' => array('$gt' => 150)),
  array('x' => array('$gt' => 200)),
  array('x' => array('$gt' => 250)),
);
foreach($queries as $query) {
  foreach(Epic\Mongo::db('test')->find($query) as $doc) {
    foreach($doc as $key => $value) {
      // var_dump("-----------", "key", $key, "value", $value);
    }
  }
}
