<?php
$testFolder = dirname(__FILE__);
if(file_exists($testFolder . '/config.php')) {
  require($testFolder . '/config.php');
}
if(!defined('TEST_CONNECTION_STRING')) {
  define('TEST_CONNECTION_STRING', '127.0.0.1');
}
Epic\Mongo::addConnection('default', TEST_CONNECTION_STRING);