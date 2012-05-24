<?
require_once 'config.inc.php';

$quantiles = array("objects" => 5, "fps" => 5, "resolutions" => 5, "manufacturer" => 4);

$q = @$_REQUEST['q'];
$d = @$_REQUEST['d'];
$c = @$_REQUEST['c'];
$s = @$_REQUEST['s'];
$f = @$_REQUEST['f'];
$f = true;
$a = !$c;

$os = @SHOW($_REQUEST['os'], SHOW($_SESSION['os'], "Android"));
$ios = ($os == "iOS");
$_SESSION['ios'] = $ios;
$_SESSION['os'] = $os;

$f = $ios ? false : $f;

if ($s) {
    $sql = "SELECT `statistics`.`type`, MAX( `statistics`.`objects` ) AS `objects`\n"
    . "FROM `statistics`, `devices` , `users` \n"
    . "WHERE `users`.`device_id` = `devices`.`id` AND `users`.`id` = `statistics`.`user_id` AND `os` <> 'iOS' "
    . "AND `statistics`.`benchmarkName` = \"Classic\" AND `statistics`.`fps`=30 GROUP BY `statistics`.`type`;";
    
    $result = $db->query($sql);

    $max = array();
    
    if ($result && mysql_num_rows($result) > 0) {
        while($row = mysql_fetch_assoc($result)) {
            $max[$row['type']] = $row['objects'];
        }
    }    
    
    $sql = "SELECT `statistics`.`type` , `statistics`.`objects`\n"
    . "FROM `statistics`, `devices` , `users` \n"
    . "WHERE `users`.`device_id` = `devices`.`id` AND `users`.`id` = `statistics`.`user_id` AND `os` <> 'iOS' "
    . "AND `statistics`.`benchmarkName` = \"Classic\" AND `statistics`.`fps`=30 \n"
    . "GROUP BY `statistics`.`id` ORDER BY `statistics`.`type`, `statistics`.`objects`";
    
    $result = $db->query($sql);

    $rows = array();
    $arows = array();
    
    if ($result && mysql_num_rows($result) > 0) {
        while($row = mysql_fetch_assoc($result)) {
            if ((int)$row['objects'] > $max[$row['type']]*$quantiles["objects"]/100) {
                $arows[$row['type']][] = $row['objects'];
            }
        }
    }
    
    $minKey = -1; $min = 0; $max = 0; $t = 0;
    $a = array();
    $keys = array();
    foreach ($arows as $key => $value) {
        $t = count($value);
        if (!$min || $t < $min) { $min = $t; $minKey = $key; }
        if (!$max || $t > $max) $max = $t;
        sort($arows[$key]);
        $a[] = "'{$key}'";
        $keys[] = $key;
    }
    $rows[] .= "['', ".join(", ", $a)."]";

    $deltha = ceil($min / ($max - $min))-1;
    $j = 1; $tarray = array();
    
    for ($i = 0; $i < $min; $i++) {
        $tarray[] = $arows[$minKey][$i];
        if ($i == $deltha*$j) {
            $j++;
            $tarray[] = $arows[$minKey][$i];
            $min++;
        }
    }
    
    while ($min++ < $max) {
       $tarray[] = $arows[$minKey][$max-1]; 
    }
    
    $arows[$minKey] = $tarray;
    
    for ($i = 0; $i < $max; $i++) {
        $rows[] = "['{$i}', {$arows[$keys[0]][$i]}, {$arows[$keys[1]][$i]}]";
    }
    
    $rows = join(", \n", $rows);
    
    $title = "Classic benchmark, 30fps";
}

if ($d) {
    if ($d != "all") {
        $f = true;
        
        $sql = "SELECT COUNT( `users`.`device_id` ) AS `cnt`\n"
        . "FROM `users` \n"
        . "WHERE 1 ORDER BY `cnt` DESC LIMIT 1;";
        
        $result = $db->query($sql);

        if ($result && mysql_num_rows($result) > 0) {
            $row = mysql_fetch_assoc($result);
            $max = $row['cnt'];
        }
        
        $sql = "SELECT COUNT( `users`.`device_id` ) AS `cnt` , `screenWidth` , `screenHeight`, `manufacturer`\n"
        . "FROM `devices` , `users` \n"
        . "WHERE `users`.`device_id` = `devices`.`id` \n"
        . "AND `os` ".($ios?"=":"<>")." 'iOS' \n";
        
        if ($d == "resolutions") {
//            $sql .= "GROUP BY `screenWidth` , `screenHeight` ".($f?"HAVING `cnt`*100/{$max} > {$quantiles[$d]}":"")."\n"
            $sql .= "GROUP BY `screenWidth` , `screenHeight` \n"
                 .  "ORDER BY `screenWidth`;";        
        } else {
//            $sql .= "GROUP BY `manufacturer` ".($f?"HAVING (`cnt`*100/{$max}) > {$quantiles[$d]}":"")."\n"
            $sql .= "GROUP BY `manufacturer` \n"
                 .  "ORDER BY `manufacturer`;";        
        }
        
        $columnName = "Count";

        $base = ucfirst($d);
        $title = "Devices by {$d}";

        $result = $db->query($sql);

        if ($result && mysql_num_rows($result) > 0) {
            $rows = array();
            $others = 0;
            
            while ($row = mysql_fetch_assoc($result)) {
                if ($f && $row['cnt']*100/$max > $quantiles[$d]) {
                    $key = STR_FROM_DB(($d == "resolutions") ? $row['screenWidth']."x".$row['screenHeight'] : $row['manufacturer']);
                    $rows[] = "['".
                        STR_FROM_DB($key)."', ".
                        STR_FROM_DB($row['cnt'])."]";
                } else {
                    $key = "Other";
                    $others += $row['cnt'];
                }
            }
            
            if ($others) $rows[] = "['Other', {$others}]";

            $rows = join(", ", $rows);
        } else {
            $d = null;
        }
    } else {
        $sql = "SELECT COUNT(`users`.`device_id`) as `cnt`, `manufacturer` , `model` , `screenWidth` , `screenHeight`, `cpuHz`, `ram` \n"
        . "FROM `devices`, `users` \n"
        . "WHERE `users`.`device_id` = `devices`.`id` AND `os` ".($ios?"=":"<>")." 'iOS' \n"
        . "GROUP BY `manufacturer` , `model`, `screenWidth` , `screenHeight` \n"
        . "ORDER BY `manufacturer` , `model`;";
    
        $result = $db->query($sql);

        if ($result && mysql_num_rows($result) > 0) {
            $devices = array();
            while ($row = mysql_fetch_assoc($result)) {
                $devices[] = $row;
            }
        } else {
            $d = null;
        }    
    }
}

if ($q) {
    $data = array();
    @list($data["benchmarkName"], $data["type"], $count, $root) = explode('_', $q);
    
    if ($f) {
        $sql = "SELECT COUNT( `users`.`device_id` ) AS `cnt`\n"
        . "FROM `users` \n"
        . "WHERE 1 ORDER BY `cnt` DESC LIMIT 1;";
        
        $result = $db->query($sql);

        if ($result && mysql_num_rows($result) > 0) {
            $row = mysql_fetch_assoc($result);
            $max = $row['cnt'];
        }
        
        $sql = "SELECT COUNT( `users`.`device_id` ) AS `cnt` , `screenWidth` , `screenHeight`\n"
        . "FROM `devices` , `users` \n"
        . "WHERE `users`.`device_id` = `devices`.`id` \n"
        . "AND `os` ".($ios?"=":"<>")." 'iOS' \n"
        . "GROUP BY `screenWidth` , `screenHeight` ".($f?"HAVING `cnt`*100/{$max} > {$quantiles[$root]}":"")."\n"
        .  "ORDER BY `screenWidth`;";        
        
        $result = $db->query($sql);

        if ($result && mysql_num_rows($result) > 0) {
            $resolutions = array();
            while ($row = mysql_fetch_assoc($result)) {
                $resolutions[] = STR_FROM_DB($row['screenWidth'])."x".STR_FROM_DB($row['screenHeight']);
            }
        }
    }
    
    if ($data["benchmarkName"] == "Classic") {
        $aroot = "fps";
    } else {
        $aroot = "objects";
    }
    
    if (!$c) $data[$aroot] = $count;
    
    $fieldsKeys = array_keys($data);
    $fieldsValues = array();
    foreach ($fieldsKeys as $value) {
        $fieldsValues[] = "`{$value}` = '{$data[$value]}'";
    }
    $fieldsValues = join(" AND ", $fieldsValues);
    
    
    if ($ios) {
        $filter = "`devices`.`manufacturer`, `devices`.`model`";
    } else {
        $filter = "`statistics`.`screenWidth`, `statistics`.`screenHeight`";
    }
    
    $sql = "SELECT AVG( `{$root}` ) AS `{$root}`, {$filter}, `type`, `{$aroot}` \n"
        . "FROM `statistics`, `devices`, `users` \n"
        . "WHERE {$fieldsValues} AND `devices`.`id` = `users`.`device_id` AND `users`.`id` = `statistics`.`user_id` AND `devices`.`os` ".($ios?"=":"<>")." 'iOS' \n"
        . "GROUP BY {$filter}, `{$aroot}`, `type`, `benchmarkName`, `benchmarkVersion` \n" //, `starlingVersion`
        . "ORDER BY {$filter};";

    $columnName = ucfirst($root);
    
    if ($root == "time") {
        $columnName .= " (sec.)";
    }
    
    $base = "Resolutions";
    $title = "{$data["benchmarkName"]}: {$data["type"]}, ".($c?"":"{$data[$aroot]} ")."{$aroot}, {$root}";

    $result = $db->query($sql);

    if ($result && mysql_num_rows($result) > 0) {
        $rows = array();
        if ($c) $keys = array();
        if ($a) $sum = 0;
        $others = array();
        $others_keys = array();
        
        while ($row = mysql_fetch_assoc($result)) {
            $rootData = ($root == "time") ? round($row['time']/1000,2) : $row[$root];

            if ($ios) {
                $rkey = STR_FROM_DB($row['model']);
            } else {
                $rkey = STR_FROM_DB($row['screenWidth'])."x".STR_FROM_DB($row['screenHeight']);
                if ($f && !in_array($rkey, $resolutions)) {
                    if (!$others[$row[$aroot]]) {
                        $others[$row[$aroot]] = 0;
                        $others_keys[$row[$aroot]] = 0;
                    }
                    $others[$row[$aroot]] += $rootData;
                    $others_keys[$row[$aroot]]++;
                    continue;
                }
            }
                    
            if ($a) $sum += $rootData;
            if ($c) {
                $rows[$rkey][$row[$aroot]] = STR_FROM_DB($rootData);
                if (!in_array($row[$aroot], $keys)) {
                    $keys[] = $row[$aroot];
                }
            } else {
                $rows[] = "['{$rkey}', ".
                    STR_FROM_DB($rootData).($a?"":"]");
            }
        }
        
        if ($c && count($others)) {
            foreach ($others as $_k => $_v) {
                $rows["Other"][$_k] = $_v/$others_keys[$_k];
            }
        }

        if (!$c) {
            if ($a) {
                $avg = $sum/count($rows);
                $h = "['{$base}', '{$columnName}'".($a?", 'Average']":"]");

                foreach ($rows as $k => $v) { 
                    $rows[$k] .= ", {$avg}]";
                }

                array_unshift($rows, $h);
                $q = 1;
            }
            
            $rows = join(", \n", $rows);
        } else if (count($rows)) {
            $avgs = array();
            $trows = array();
            $trows[] = "['{$base}', '".join(" {$aroot}', '", $keys)." {$aroot}'".($a?", 'Average']":"]");
            
            foreach ($rows as $res => $vals) { 
                $brk = false;
                if ($a) $avg = 0;
                foreach ($keys as $key) {
                    //if (!$vals[$key]) $vals[$key] = 0;
                    if (!$vals[$key]) $brk = true;
                    if ($a) $avg += $vals[$key];
                }
                if ($brk) continue;
                
                $avgs[] = $avg / count($keys);
                
                $trows[] = "['{$res}', ".join(", ", $vals).($a?"":"]");;
            }
            
            if ($a) {
                $avg = array_sum($avgs)/count($avgs);
            
                foreach ($trows as $k => $v) { 
                    if ($k) $trows[$k] .= ", {$avg}]";
                }
                $q = count($keys);
            }
            
            $rows = join(", \n", $trows);
        }
    } else {
        $q = null;
        $c = null;
    }
}
?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Starling Benchmark</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- Le styles -->
    <link href="assets/css/bootstrap.css" rel="stylesheet">
    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
      .sidebar-nav {
        padding: 9px 0;
      }
    </style>
    <link href="assets/css/bootstrap-responsive.css" rel="stylesheet">

    <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Le fav and touch icons
    <link rel="shortcut icon" href="assets/ico/favicon.ico">
    <link rel="apple-touch-icon-precomposed" sizes="114x114" href="assets/ico/apple-touch-icon-114-precomposed.png">
    <link rel="apple-touch-icon-precomposed" sizes="72x72" href="assets/ico/apple-touch-icon-72-precomposed.png">
    <link rel="apple-touch-icon-precomposed" href="assets/ico/apple-touch-icon-57-precomposed.png"> -->

    <? if ($s || $q || ($d && $d != "all")) { ?>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
    <? if ($s) { ?>
        var data = google.visualization.arrayToDataTable([
          <?=$rows?>
        ]);

        var options = {
          title: '<?=$title?>',
          vAxis: {title: "Objects", gridlines: {count: 8}},
          hAxis: {gridlines: {count: 3}, textPosition:'none'},
          fontSize: 20
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
    <? } else if ($d && $d != "all") { ?>
        var data = new google.visualization.DataTable();
        data.addColumn('string', '<?=$base?>');
        data.addColumn('number', '<?=$columnName?>');
        data.addRows([
          <?=$rows?>
        ]);

        var options = {
          title: '<?=$title?>',
          fontSize: 20
        };

        var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
    <? } else if ($q) { ?>
        var data = google.visualization.arrayToDataTable([
            <?=$rows?>
        ]);

<?
    $value = "";
    if ($root=="fps") {
        $value = ", minValue: 0, maxValue: 50";
    } else if ($root=="objects" && $ios) {
        $value = ", minValue: 0, maxValue: 1100";
    }
?>
        var options = {
          height: 600,
          title : '<?=$title?>',
          vAxis: {title: "<?=ucfirst($root)?>"<?=$value?>},
          hAxis: {title: "<?=$base?>"},
          fontSize: 20,
          seriesType: "bars",
          <? if ($a) { ?>series: {<?=$q?>: {type: "line"}}<? } ?>
        };

        var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));        
    <? } ?>
        chart.draw(data, options);
      }
    </script>
    <? } ?>
  </head>

  <body>

    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="/starling/benchmark">Starling Benchmark: <?=$os?></a>
          <!div class="nav-collapse">
            <ul class="nav">
              <li class="active"><a href="/starling/benchmark?os=Android">Android</a></li>
              <li class="active"><a href="/starling/benchmark?os=iOS">iOS</a></li>
            </ul>
            <p class="navbar-text pull-right"></p>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row-fluid">
        <div class="span3" style="width:250px">
          <div class="well sidebar-nav">
            <ul class="nav nav-list">
              <li class="nav-header">Classic Benchmark Reports</li>
              <li><a href="/starling/benchmark?q=Classic_Images_30_objects">Images, 30fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_Images_60_objects">Images, 60fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_30_objects">MovieClips, 30fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_60_objects">MovieClips, 60fps, objects</a></li>
              <li class="nav-header"></li>
              <li><a href="/starling/benchmark?q=Classic_Images_0_objects&c=true">Composite chart: Images</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_0_objects&c=true">Composite chart: MovieClips</a></li>
              <li class="nav-header">Stress Benchmark Reports</li>
              <li><a href="/starling/benchmark?q=Stress_Images_100_fps">Images, 100 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_Images_500_fps">Images, 500 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_Images_1000_fps">Images, 1000 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_Images_2000_fps">Images, 2000 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_MovieClips_100_fps">MovieClips, 100 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_MovieClips_500_fps">MovieClips, 500 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_MovieClips_1000_fps">MovieClips, 1000 objects, fps</a></li>
              <li><a href="/starling/benchmark?q=Stress_MovieClips_2000_fps">MovieClips, 2000 objects, fps</a></li>
              <li class="nav-header"></li>
              <li><a href="/starling/benchmark?q=Stress_Images_0_fps&c=true">Composite chart: Images</a></li>
              <li><a href="/starling/benchmark?q=Stress_MovieClips_0_fps&c=true">Composite chart: MovieClips</a></li>
              <li class="nav-header">Devices</li>
              <li><a href="/starling/benchmark?d=all">All benchmarked devices</a></li>
              <li><a href="/starling/benchmark?d=resolutions">Resolutions chart</a></li>
              <? if (!$ios) { ?>
              <li><a href="/starling/benchmark?d=manufacturer">Manufacturers chart</a></li>
              <li><a href="/starling/benchmark?s=true">Composite chart</a></li>
              <? } ?>
            </ul>
          </div><!--/.well -->
        </div><!--/span-->
        <div class="span9">
          
          <? if ($d && $d == "all") { ?>
        <table class="table table-bordered table-striped">
            <tr>
                <th>Model</th>
                <th>Search links</th>
                <th>Resolution</th>
                <th>CPU</th>
                <th>RAM</th>
                <th>Count</th>
            </tr>
            <? 
                $total = 0;    
                foreach ($devices as $device) { 
                    $model = "{$device['manufacturer']} {$device['model']}";
                    $model = str_replace("HTC HTC", "HTC", $model);
                    $total += $device['cnt'];
            ?>
            <tr>
                <td><strong><?=$model?></strong></td>
                <td>
                    <a target="_blank" href="http://www.google.ru/search?q=<?=urlencode($model)?>">Google</a>, 
                    <? if (!$ios) { ?><a target="_blank" href="http://www.gsmarena.com/results.php3?sName=<?=urlencode($model)?>">GSMArena</a>,<? } ?>
                    <a target="_blank" href="http://wikipedia.org/wiki/<?=urlencode(str_replace(" ", "_", $model))?>">Wiki</a>
                </td>
                <td><?="{$device['screenWidth']}x{$device['screenHeight']}"?></td>
                <td><?=$device['cpuHz']?></td>
                <td><?=$device['ram']?></td>
                <td><?=$device['cnt']?></td>
            </tr>
            <? } ?>
            <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td><strong>Total:</strong></td>
                <td><?=$total?></td>
            </tr>
        </table>
          <? } else if ($s || $q || ($d && $d != "all")) { $height = $s ? 800: 600;?>
          <div align="center">
            <div id="chart_div" style="width: 100%; height: <?=$height?>px;"></div>
          </div>
          <? } else { ?>
          <div class="hero-unit">
            <h1>Starling Benchmark</h1>
            <p>Hi folks! This is Starling Benchmark - a Starling Framework performance benchmarking application for mobile devices.</p>
            <p>The application will be of great benefit to the game developers who use Starling Framework!</p>
            <p>Application will send results to the external server after each benchmark.</p>
            <p><a class="btn btn-primary btn-large" href="https://play.google.com/store/apps/details?id=air.com.dustunited.StarlingBenchmark">Download Starling Benchmark &raquo;</a></p>
          </div>
          <div class="row-fluid">
            <div class="span4">
              <h2>Open Source</h2>
              <p>Starling Becnmark is an Open Source project. </p>
              <p><a class="btn" href="http://github.com/ekeeper/Starling-Benchmark">Fork me on github &raquo;</a></p>
            </div><!--/span-->
            <div class="span4">
              <h2>We need your support!</h2>
              <p>Please, read this special topic on Starling Forum. </p>
              <p><a class="btn" href="http://forum.starling-framework.org/topic/starling-benchmark-for-mobile-devices">View details &raquo;</a></p>
            </div><!--/span-->
            <div class="span4">
              <p><img src="http://qrcode.kaywa.com/img.php?s=5&d=market%3A%2F%2Fdetails%3Fid%3Dair.com.dustunited.StarlingBenchmark"</p>
            </div><!--/span-->
          </div><!--/row-->
          <? } ?>
        </div><!--/span-->
      </div><!--/row-->

      <hr>

      <footer>
        <p>&copy; Valeriy Bokhan 2012</p>
      </footer>

    </div><!--/.fluid-container-->

    <!-- Le javascript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="assets/js/jquery.js"></script>
    <script src="assets/js/bootstrap-transition.js"></script>
    <script src="assets/js/bootstrap-alert.js"></script>
    <script src="assets/js/bootstrap-modal.js"></script>
    <script src="assets/js/bootstrap-dropdown.js"></script>
    <script src="assets/js/bootstrap-scrollspy.js"></script>
    <script src="assets/js/bootstrap-tab.js"></script>
    <script src="assets/js/bootstrap-tooltip.js"></script>
    <script src="assets/js/bootstrap-popover.js"></script>
    <script src="assets/js/bootstrap-button.js"></script>
    <script src="assets/js/bootstrap-collapse.js"></script>
    <script src="assets/js/bootstrap-carousel.js"></script>
    <script src="assets/js/bootstrap-typeahead.js"></script>

  </body>
</html>
