<?
function DUMP($var) {
?><xmp><?var_dump($var)?></xmp><hr><?
}

function SHOW($var, $default = FALSE) {
	return !empty($var)?$var:$default;
}

function CHECK($var, $val) {
	return (!empty($var) && $var===$val)?true:false;
}

function SET($var, $val) {
	if (empty($var)) return false;
	if ($var=$val) return true;
}

//read from db
function STR_FROM_DB($content) {
	return stripslashes (html_entity_decode ($content));
}

//write to db
function STR_TO_DB($content) {
	return  htmlspecialchars(addslashes (trim ($content)));
}

function getCountry($_ip = "")
{
    $ip=($_ip != "")?$_ip:PMA_getIp();
    include_once ('geoip/geoip.inc');
    $gi=geoip_open('geoip/GeoIP.dat', GEOIP_STANDARD);
    $cc=geoip_country_code_by_addr($gi, $ip);
    if ($_ip != "")
    	$cc = SHOW($cc, geoip_country_code_by_addr($gi, PMA_getIp()));
    //$cn=geoip_country_name_by_addr($gi, $ip);
    geoip_close($gi);
    return SHOW($cc, "UNKNOWN");
}

function getCountryName()
{
    $ip=PMA_getIp();
    include_once ('geoip/geoip.inc');
    $gi=geoip_open('geoip/GeoIP.dat', GEOIP_STANDARD);
    //$cc=geoip_country_code_by_addr($gi, $ip);
    $cc=geoip_country_name_by_addr($gi, $ip);
    geoip_close($gi);
    return SHOW($cc, "UNKNOWN");
}

function getLanguage()
{
	return SHOW(strtoupper(substr($_SERVER["HTTP_ACCEPT_LANGUAGE"],0,2)), "UNKNOWN");
}

function getCountryNameByCode($code)
{
    include_once ('geoip/geoip.inc');
    $gi=geoip_open('geoip/GeoIP.dat', GEOIP_STANDARD);
    $cn=$gi->GEOIP_COUNTRY_NAMES[$gi->GEOIP_COUNTRY_CODE_TO_NUMBER[$code]];
    geoip_close($gi);
    return SHOW($cn, "UNKNOWN");
}

?>
