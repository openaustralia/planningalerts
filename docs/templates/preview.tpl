<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>PlanningAlerts.com | Alert area preview</title>
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key={$google_maps_key}"
      type="text/javascript"></script>
      <script src="./javascript/preview.js" type="text/javascript"></script>      
  </head>

  <body onload="load({$center_long}, {$center_lat}, {$bottom_left_long}, {$bottom_left_lat}, {$top_right_long}, {$top_right_lat})" onunload="GUnload()">
    <div id="map" style="width: 500px; height: 500px"></div>
  </body>
</html>
