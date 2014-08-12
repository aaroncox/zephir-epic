<?php

class EpicMongoTest extends PHPUnit_Framework_TestCase {

  /**
   * testEpicMongoExists
   *
   * Make sure our namespace\class exists
   *
   * @return void
   * @author Aaron Cox
   **/
  public function testEpicMongoExists()
  {
    $this->assertTrue(class_exists('Epic\Mongo'));
  }

  /**
   * testGetSchemaException
   *
   * Ensure that an invalid schema call throws an exception
   *
   * @expectedException \Exception
   */
  public function testGetSchemaException() {
    Epic\Mongo::getSchema('doesnt-exist');
  }

  /**
   * testAddSchemaException
   *
   * Ensure that we cannot add the same schema twice
   *
   * @expectedException \Exception
   */
  public function testAddSchemaException() {
    $schema = new epic_MongoTestSchema;
    Epic\Mongo::addSchema('dupe', $schema);
    Epic\Mongo::addSchema('dupe', $schema);   
  }

  /**
   * testAddSchemaException
   *
   * Ensure that we cannot add the same schema twice
   */
  public function testGetSchema() {
    $schema = new epic_MongoTestSchema;
    Epic\Mongo::addSchema('test', $schema);
    $this->assertInstanceOf('Epic\Schema', Epic\Mongo::getSchema('test'));
  }

  /**
   * testMagicMethod
   *
   * Add a schema and make sure it returns and can call documents
   */
  public function testMagicMethod() {
    $schema = new epic_MongoTestSchema;
    Epic\Mongo::addSchema('magic', $schema);
    $this->assertInstanceOf('epic_MongoTestSchema', Epic\Mongo::magic());
    $this->assertInstanceOf('epic_MongoTestDocument', Epic\Mongo::magic('test'));
  }

}

/**
 * epic_MongoTestSchema
 *
 * Example Schema for epic_MongoTest
 */
class epic_MongoTestSchema extends Epic\Schema {
  protected $typeMap = array(
    'test' => 'epic_MongoTestDocument'
  );
}

/**
 * epic_MongoTestDocument
 *
 * Example Document for epic_MongoTest
 */
class epic_MongoTestDocument extends Epic\Document {

}