<?php
$testFolder = dirname(__FILE__);
if(file_exists($testFolder . '/config.php')) {
  require($testFolder . '/config.php');
}
if(!defined('TEST_CONNECTION_STRING')) {
  define('TEST_CONNECTION_STRING', 'mongodb://localhost:27017/');
}
Epic\Mongo::addConnection('default', TEST_CONNECTION_STRING);