function barGraph(selector, url) {
  d3.json(url, function(foo) {
    var data = d3.entries(foo);

    // Data comes in grouped by day but we want it grouped by week
    data = d3.nest()
      .key(function(d) {
        // Use the date of the beginning of the week
        date = new Date(d.key);
        return new Date(date.getFullYear(), date.getMonth(), date.getDate() - date.getDay());
      })
      .rollup(function(d) {
        return d3.sum(d, function(d2) { return d2.value; });
      })
      .entries(data);

    data.forEach(function(d, i) {
      d.key = new Date(d.key);
    });

    var width = "100%";
    var barWidth = 5;

    var height = 200;

    var x = d3.time.scale().domain(d3.extent(data, function(datum) { return datum.key})).range([0, width]);
    var y = d3.scale.linear()
      .domain([0, d3.max(data, function(datum) { return datum.values; })])
      .rangeRound([0, height]);

    // add the canvas to the DOM
    var barDemo = d3.select(selector)
      .append("svg:svg")
      .attr("width", width)
      .attr("height", height + 15)
      .append("g")
      .attr("transform", "translate(0,15)");

    barDemo.selectAll(".rule")
      .data(x.ticks(5))
      .enter().append("text")
      .attr("class", "rule")
      .attr("x", x)
      .attr("y", 0)
      .attr("dy", -3)
      .attr("text-anchor", "middle")
      .text(x.tickFormat(5));

    barDemo.selectAll(".xTicks")
      .data(x.ticks(d3.time.months.utc, 1))
      .enter().append("svg:line")
      .attr("x1", x)
      .attr("y1", -5)
      .attr("x2", x)
      .attr("y2", height+5)
      .attr("stroke", "lightgray")
      .attr("class", "xTicks");

    barDemo.selectAll("rect")
      .data(data)
      .enter()
      .append("svg:rect")
      .attr("x", function(datum) { return x(datum.key); })
      .attr("y", function(datum) { return height - y(datum.values); })
      .attr("height", function(datum) { return y(datum.values); })
      .attr("width", barWidth)
      .attr("fill", "#2d578b");
  });

}
