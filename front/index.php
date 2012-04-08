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
    
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Year');
        data.addColumn('number', 'Legal Income');
        data.addColumn('number', 'Porn');
        data.addRows([
          ['2009', 1000, 8000],
          ['2010', 1170, 9060],
          ['2011', 2600, 11120],
          ['2012', 3030, 13540]
        ]);

        var options = {
          title: 'Bloody Hell',
          hAxis: {title: 'Year', titleTextStyle: {color: 'red'}}
        };

        //var chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
        //chart.draw(data, options);
      }
    </script>
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
          <a class="brand" href="#">Starling Benchmark</a>
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
          <!--div class="well sidebar-nav">
            <ul class="nav nav-list">
              <li class="nav-header">Reports</li>
              <li><a href="#">Link</a></li>
              <li class="nav-header">Models</li>
              <li><a href="#">Link</a></li>
            </ul>
          </div--><!--/.well -->
        </div><!--/span-->
        <div class="span9">
            
          <div class="hero-unit">
            <h1>Under construction!</h1>
            <p>Hi folks! This is Starling Benchmark - a Starling Framework performance benchmarking application for mobile devices.</p>
            <p>The application will be of great benefit to the game developers who use Starling Framework!</p>
            <p>Application will send results to the external server after each benchmark.</p>
            <p><strong>This page is under construction, because we have not enough data now.</strong></p>
            <p><a class="btn btn-primary btn-large" href="http://dl.dropbox.com/u/21347582/StarlingBenchmark.apk">Download Starling Benchmark &raquo;</a></p>
            <!--div id="chart_div" style="width: 100%; height: 500px;"></div-->
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
              <h2>Download</h2>
              <p>While our application is not appear on Google Play, you can use a temporary link below. </p>
              <p><a class="btn" href="http://dl.dropbox.com/u/21347582/StarlingBenchmark.apk">Download &raquo;</a></p>
            </div><!--/span-->
          </div><!--/row-->
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
