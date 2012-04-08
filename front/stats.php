<?
require_once 'config.inc.php';

$data = $_REQUEST["data"];
if ($data) {
/*
    header ("Content-type: text/xml");
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n";
    echo $data;
*/
    $data = xmlstr_to_array($data);
    $data["device"]["ip"] = PMA_getIp();
    $data["device"]["country"] = getCountry();

    $device = $data["device"];

    if ($device && count($device)) {
        foreach ($device as $key => $value) {
            $device[$key] = (is_array($value)) ? "" : trim($value);
        }

        $sql ="SELECT id FROM `devices` WHERE `mac` = '{$device["mac"]}' AND `model`='{$device["model"]}' LIMIT 1";
        $result = $db->query($sql);
        
        if ($result) {
            if (mysql_num_rows($result) > 0) {
                $row = mysql_fetch_assoc($result);
                $deviceId = STR_FROM_DB($row['id']);
            } else {
                $keys = join("`, `", array_keys($device));
                $values = join("', '", array_values($device));
                $sql = "INSERT INTO `devices` (`id`, `{$keys}`) VALUES (NULL, '{$values}');";
                $db->query($sql);
                $deviceId = $db->insert_id();
            }

            unset($data["device"]);
            $data["device_id"] = $deviceId;

            $keys = join("`, `", array_keys($data));
            $values = join("', '", array_values($data));
            $sql = "INSERT INTO `statistics` (`id`, `{$keys}`) VALUES (NULL, '{$values}');";
            $db->query($sql);
        }
    }
}

function xmlstr_to_array($xmlstr) {
  $doc = new DOMDocument();
  $doc->loadXML($xmlstr);
  return domnode_to_array($doc->documentElement);
}

function domnode_to_array($node) {
  $output = array();
  switch ($node->nodeType) {

    case XML_CDATA_SECTION_NODE:
    case XML_TEXT_NODE:
      $output = trim($node->textContent);
    break;

    case XML_ELEMENT_NODE:
      for ($i=0, $m=$node->childNodes->length; $i<$m; $i++) {
        $child = $node->childNodes->item($i);
        $v = domnode_to_array($child);
        if(isset($child->tagName)) {
          $t = $child->tagName;
          if(!isset($output[$t])) {
            $output[$t] = array();
          }
          $output[$t][] = $v;
        }
        elseif($v || $v === '0') {
          $output = (string) $v;
        }
      }
      if($node->attributes->length && !is_array($output)) { //Has attributes but isn't an array
        $output = array('@content'=>$output); //Change output into an array.
      }
      if(is_array($output)) {
        if($node->attributes->length) {
          $a = array();
          foreach($node->attributes as $attrName => $attrNode) {
            $a[$attrName] = (string) $attrNode->value;
          }
          $output['@attributes'] = $a;
        }
        foreach ($output as $t => $v) {
          if(is_array($v) && count($v)==1 && $t!='@attributes') {
            $output[$t] = $v[0];
          }
        }
      }
    break;
  }
  return $output;
}
?>