function barGraph(selector, url) {
  d3.json(url, function(data) {

    data = data.map(function(d, i) {
      return {key: new Date(d[0]), value: d[1]};
    });

    // Data comes in grouped by day but we want it grouped by week
    data = d3.nest()
      .key(function(d) {
        // Use the date of the beginning of the week
        date = d.key;
        return new Date(date.getFullYear(), date.getMonth(), date.getDate() - date.getDay());
      })
      .rollup(function(d) {
        return d3.sum(d, function(d2) { return d2.value; });
      })
      .entries(data);

    data.forEach(function(d, i) {
      d.key = new Date(d.key);
    });

    var width = 800;
    var barWidth = 5;

    var height = 200;

    var x = d3.time.scale().domain(d3.extent(data, function(datum) { return datum.key})).range([0, width]);
    var y = d3.scale.linear()
      .domain([0, d3.max(data, function(datum) { return datum.values; })])
      .rangeRound([height, 0]);

    // add the canvas to the DOM
    var chart = d3.select(selector)
      .append("svg:svg")
      .attr("width", width)
      .attr("height", height + 15)
      .append("g")
      .attr("transform", "translate(0,15)");

    chart.selectAll(".rule")
      .data(x.ticks(5))
      .enter().append("text")
      .attr("class", "rule")
      .attr("x", x)
      .attr("y", 0)
      .attr("dy", -3)
      .attr("text-anchor", "middle")
      .text(x.tickFormat(5));

    chart.selectAll(".xTicks")
      .data(x.ticks(d3.time.months.utc, 1))
      .enter().append("svg:line")
      .attr("x1", x)
      .attr("y1", -5)
      .attr("x2", x)
      .attr("y2", height+5)
      .attr("stroke", "lightgray")
      .attr("class", "xTicks");

    var l = d3.svg.area().
      x(function(d) { return x(d.key); }).
      y0(height).
      y1(function(d) { return y(d.values); }).
      interpolate("basis");

    chart.
      append("svg:path").
      attr("d", l(data)).
      attr("fill", "steelblue");
  });

}
