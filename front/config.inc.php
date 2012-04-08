<?
//error_reporting(E_ALL ^ E_NOTICE);
//error_reporting(0);

//------- main configuration --------------------//
class config {};
$config = new config;

//------- db ------------------------------------//
$config->dbhost = "localhost";
$config->dbname = "starling_benchmark";
$config->dbuser = "sb_user";
$config->dbpass = "sb_pass";
//------- basic ---------------------------------//
$config->wwwroot = str_replace(realpath(getenv('DOCUMENT_ROOT')), '', dirname(__FILE__));
$config->wwwroot = str_replace('\\', '/', $config->wwwroot).'/';
$config->urlroot = 'http://'.getenv('HTTP_HOST').$config->wwwroot;
$config->dirroot = dirname(__FILE__);

require_once('database.php');
require_once('fns.inc.php');
require_once('ip.inc.php');

$db = new CDatabase($config->dbname, $config->dbhost, $config->dbuser, $config->dbpass);
//mysql_query("SET NAMES 'UTF8'");

//session_start();
?>
