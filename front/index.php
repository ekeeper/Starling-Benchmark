<?
require_once 'config.inc.php';

$q = $_REQUEST['q'];
$d = $_REQUEST['d'];

if ($d) {
    $sql = "SELECT count(`id`) as `cnt`, `manufacturer` , `model` , `screenWidth` , `screenHeight` \n"
    . "FROM `devices` \n"
    . "WHERE 1 \n"
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

if ($q) {
    $data = array();
    @list($data["benchmarkName"], $data["type"], $data["fps"], $root) = explode('_', $q);
    
    $fieldsKeys = array_keys($data);
    $fieldsValues = array();
    foreach ($fieldsKeys as $value) {
        $fieldsValues[] = "`{$value}` = '{$data[$value]}'";
    }
    $fieldsValues = join(" AND ", $fieldsValues);
    
    $sql = "SELECT AVG( `objects` ) AS `objects`, AVG( `time` ) AS `time`, `screenWidth`, `screenHeight`, `fps`, `starlingVersion` \n"
        . "`type`\n"
        . "FROM `statistics` \n"
        . "WHERE {$fieldsValues} \n"
        . "GROUP BY `screenWidth`, `screenHeight`, `fps`, `type`, `benchmarkName`, `benchmarkVersion`, `starlingVersion` \n"
        . "ORDER BY `screenWidth`, `screenHeight`;";

    $columnName = "Average {$root}";
    
    if ($root == "time") {
        $columnName .= " (sec.)";
    }
    
    $base = "Resolutions";
    $title = "{$data["benchmarkName"]}: {$data["type"]}, fps{$data["fps"]}, {$root}";

    $result = $db->query($sql);

    if ($result && mysql_num_rows($result) > 0) {
        $rows = array();
        while ($row = mysql_fetch_assoc($result)) {
            $rootData = ($root == "time") ? round($row['time']/1000,2) : $row[$root];
            $rows[] = "['".
                STR_FROM_DB($row['screenWidth'])."x".STR_FROM_DB($row['screenHeight'])."', ".
                STR_FROM_DB($rootData)."]";
        }
        
        $rows = join(", ", $rows);
    } else {
        $q = null;
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

    <? if ($q) { ?>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', '<?=$base?>');
        data.addColumn('number', '<?=$columnName?>');
        data.addRows([
          <?=$rows?>
        ]);

        var options = {
          title: '<?=$title?>',
          //hAxis: {title: 'Year', titleTextStyle: {color: 'red'}}
        };

        var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
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
          <a class="brand" href="/starling/benchmark">Starling Benchmark</a>
          <!--div class="nav-collapse">
            <ul class="nav">
              <li class="active"><a href="#">Home</a></li>
            </ul>
            <p class="navbar-text pull-right"></p>
          </div--><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container-fluid">
      <div class="row-fluid">
        <div class="span3" style="width:250px">
          <div class="well sidebar-nav">
            <ul class="nav nav-list">
              <li class="nav-header">Reports</li>
              <li><a href="/starling/benchmark?q=Classic_Images_30_objects">Classic: Images, 30fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_Images_30_time">Classic: Images, 30fps, time</a></li>
              <li><a href="/starling/benchmark?q=Classic_Images_60_objects">Classic: Images, 60fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_Images_60_time">Classic: Images, 60fps, time</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_30_objects">Classic: MovieClips, 30fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_30_time">Classic: MovieClips, 30fps, time</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_60_objects">Classic: MovieClips, 60fps, objects</a></li>
              <li><a href="/starling/benchmark?q=Classic_MovieClips_60_time">Classic: MovieClips, 60fps, time</a></li>
              <li class="nav-header">Devices</li>
              <li><a href="/starling/benchmark?d=all">All benchmarked devices</a></li>
            </ul>
          </div><!--/.well -->
        </div><!--/span-->
        <div class="span9">
          
          <? if ($d) { ?>
        <table class="table table-bordered table-striped">
            <tr>
                <th>Model</th>
                <th>Resolution</th>
                <th>Number</th>
            </tr>
            <? 
                foreach ($devices as $device) { 
                $model = "{$device['manufacturer']} {$device['model']}";
            ?>
            <tr>
                <td><a target="_blank" href="http://www.google.ru/search?q=<?=urlencode($model)?>"><?=$model?></a></td>
                <td><?="{$device['screenWidth']}x{$device['screenHeight']}"?></td>
                <td><?=$device['cnt']?></td>
            </tr>
            <? } ?>
        </table>
          <? } else if ($q) { ?>
          <div id="chart_div" style="width: 100%; height: 500px;"></div>
          <? } else { ?>
          <div class="hero-unit">
            <h1>Starling Benchmark</h1>
            <p>Hi folks! This is Starling Benchmark - a Starling Framework performance benchmarking application for mobile devices. <strong>Currently only Android is supported.</strong></p>
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
              <p><img src="http://qrcode.kaywa.com/img.php?s=5&d=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dair.com.dustunited.StarlingBenchmark"</p>
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
