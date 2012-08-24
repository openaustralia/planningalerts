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
    var margin = 40;

    var x = d3.time.scale().domain(d3.extent(data, function(datum) { return datum.key})).range([0, width]);
    var y = d3.scale.linear()
      .domain([0, d3.max(data, function(datum) { return datum.values; })])
      .rangeRound([height, 0]);

    // add the canvas to the DOM
    var chart = d3.select(selector)
      .append("svg:svg")
      .attr("width", width + 2 * margin)
      .attr("height", height + 2 * margin);

    var axisGroup = chart
      .append("g")
      .attr("transform", "translate(" + margin + "," + margin + ")");

    axisGroup
      .append("svg:rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", width)
      .attr("height", height)
      .attr("stroke", "lightgray")
      .attr("fill", "none");

    axisGroup.selectAll(".xTicks")
      .data(x.ticks(d3.time.months.utc, 1))
      .enter().append("svg:line")
      .attr("class", "xTicks")
      .attr("x1", x)
      .attr("y1", 0)
      .attr("x2", x)
      .attr("y2", height)
      .attr("stroke", "lightgray");

    axisGroup.selectAll(".yTicks")
      .data(y.ticks(10))
      .enter().append("svg:line")
      .attr("class", "yTicks")
      .attr("x1", 0)
      .attr("y1", y)
      .attr("x2", width)
      .attr("y2", y)
      .attr("stroke", "lightgray");

    axisGroup.selectAll("text.xAxis")
      .data(x.ticks(5))
      .enter().append("text")
      .attr("class", "xAxis")
      .attr("x", x)
      .attr("y", height)
      .attr("dy", "20")
      .attr("text-anchor", "middle")
      .text(x.tickFormat(5));

    axisGroup.selectAll("text.yAxis")
      .data(y.ticks(5))
      .enter().append("text")
      .attr("class", "yAxis")
      .attr("x", 0)
      .attr("y", y)
      .attr("dx", "-10")
      .attr("dy", "5")
      .attr("text-anchor", "end")
      .text(y.tickFormat(5));

    var l = d3.svg.area().
      x(function(d) { return x(d.key); }).
      y0(height).
      y1(function(d) { return y(d.values); }).
      interpolate("basis");

    axisGroup.
      append("svg:path").
      attr("d", l(data)).
      attr("fill", "steelblue");
  });

}
