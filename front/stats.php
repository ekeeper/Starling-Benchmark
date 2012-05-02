<?
require_once 'config.inc.php';

$build = @trim($_REQUEST["build"]);
if ($build) {
    $build = xmlstr_to_array($build);
    $build['device'] = str_replace(" ", "_", $build['device']);
    if ($build['data'] && $fp = fopen("device_logs/{$build['device']}.txt", "w")) {
        fwrite($fp, $build['data']);
        fclose($fp);
    }
}    

$data = @trim($_REQUEST["data"]);
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

        if (trim($device['mac']) != "") {
            $sql ="SELECT id, device_id FROM `users` WHERE `mac` = '{$device['mac']}' LIMIT 1";
            $result = $db->query($sql);
            $num_rows = ($result) ? mysql_num_rows($result) : 0;
        } else {
            $result = true;
            $num_rows = 0;
        }
        
        if ($result) {
            if ($num_rows > 0) {
                $row = mysql_fetch_assoc($result);
                $userId = STR_FROM_DB($row['id']);
                $deviceId = STR_FROM_DB($row['device_id']);
                
                $fieldsKeys = array('os', 'osVersion', 'cpu', 'cpuHz', 'ram', 'screenWidth', 'screenHeight', 'dpi');
                $fieldsValues = array();
                foreach ($fieldsKeys as $value) {
                    $device[$value] = trim($device[$value]);
                    if ($device[$value] != "") {
                        $pos = strpos($device[$value], " ");
                        
                        if (in_array($value, array('cpuHz', 'ram')) && $pos !== false) {
                            $device[$value] = substr_replace($device[$value], "", $pos, 1);
                        }
                        
                        $fieldsValues[] = "`{$value}` = '{$device[$value]}'";
                    }
                }
                $fieldsValues = join(", ", $fieldsValues);
                
                $sql = "UPDATE `devices` SET {$fieldsValues} WHERE `id` = {$deviceId};";
                $db->query($sql);
            } else {
                $device["manufacturer"] = ucfirst($device["manufacturer"]);

                $userFields = array('mac', 'ip', 'country');
                $user = array();
                foreach ($userFields as $value) {
                    $user[$value] = $device[$value];
                    unset($device[$value]);
                }
                
                $dig = array('cpuHz', 'ram');
                foreach ($dig as $value) {
                    $device[$value] = trim($device[$value]);
                    $pos = strpos($device[$value], " ");
                    if ($device[$value] != "" && $pos !== false) {
                        $device[$value] = substr_replace($device[$value], "", $pos, 1);
                    }
                }
                
                $deviceSearchFields = array('manufacturer', 'model', 'os', 'osVersion', 'screenWidth', 'screenHeight');
                $deviceSearchValues = array();
                foreach ($deviceSearchFields as $value) {
                    $device[$value] = trim($device[$value]);
                    if ($device[$value] != "") {
                        $deviceSearchValues[] = "`{$value}` = '{$device[$value]}'";
                    }
                }
                $deviceSearchValues = join(" AND ", $deviceSearchValues);
                
                $sql = "SELECT id FROM `devices` WHERE {$deviceSearchValues} LIMIT 1";
                $result = $db->query($sql);
                $num_rows = ($result) ? mysql_num_rows($result) : 0;
                
                if ($num_rows > 0) {
                    $row = mysql_fetch_assoc($result);                
                    $deviceId = STR_FROM_DB($row['id']);
                } else {
                    $keys = join("`, `", array_keys($device));
                    $values = join("', '", array_values($device));
                    $sql = "INSERT INTO `devices` (`id`, `{$keys}`) VALUES (NULL, '{$values}');";
                    $db->query($sql);
                    $deviceId = $db->insert_id();
                }
                
                $user["device_id"] = $deviceId;
                
                if (trim($device['mac']) == "") {
                    $sql ="SELECT id FROM `users` WHERE `ip` = '{$device['ip']}' AND device_id = {$deviceId} LIMIT 1";
                    $result = $db->query($sql);
                    $num_rows = ($result) ? mysql_num_rows($result) : 0;
                
                    if ($num_rows > 0) {
                        $row = mysql_fetch_assoc($result);
                        $userId = STR_FROM_DB($row['id']);
                    } else {
                        $userId = -1;
                    }
                }
                
                if ($userId < 0 || trim($device['mac']) != "") {
                    $keys = join("`, `", array_keys($user));
                    $values = join("', '", array_values($user));
                    $sql = "INSERT INTO `users` (`id`, `{$keys}`) VALUES (NULL, '{$values}');";
                    $db->query($sql);
                    $userId = $db->insert_id();
                }
            }

            unset($data["device"]);
            $data["user_id"] = $userId;

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