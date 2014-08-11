<?php

class TestSchema extends Epic\Schema {

  protected $typeMap = array(
    'test' => 'TestDocument',
  );

}

class TestDocument extends Epic\Document {

}

Epic\Mongo::addConnection('default', '127.0.0.1');
Epic\Mongo::addSchema('db', new TestSchema());
// var_dump(Epic\Mongo::getSchema('db')); 
var_dump(Epic\Mongo::db('test'));
