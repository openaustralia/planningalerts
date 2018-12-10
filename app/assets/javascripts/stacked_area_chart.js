function stackedAreaTimeseries(selector, url, title) {
  if ( typeof(d3) === "object" ) {
    // Add the title
    var wrapper_element = document.querySelectorAll(selector)[0];

    var title_element = document.createElement('h3');
    title_element.textContent = title;

    wrapper_element.insertBefore(title_element, wrapper_element.firstChild);

    // Add chart
    var parseDate = d3.time.format("%Y-%m-%d");

    var width = 700;
    var height = 200;
    var margin = 30;
    var legend_offset = 200;

    var x = d3.time.scale()
      .range([0, width]);

    var y = d3.scale.linear()
      .range([height, 0]);

    var color = d3.scale.category20();
    var colors = ["#1d3d61", "#e3821f"]

    var xAxis = d3.svg.axis()
      .scale(x)
      .ticks(3)
      .tickPadding([5])
      .orient("bottom");

    var area = d3.svg.area()
      .x(function(d) { return x(d.date); })
      .y0(function(d) { return y(d.y0); })
      .y1(function(d) { return y(d.y0 + d.y); })
      .interpolate("monotone");

    var stack = d3.layout.stack()
      .values(function(d) { return d.values; })
      .order("reverse");

    var svg = d3.select(selector).append("svg")
      .attr("width", margin + width + legend_offset)
      .attr("height", height + 3 * margin)
      .attr("class", "chart-area-stacked")
      .append("g")
      .attr("transform", "translate(" + margin + "," + margin + ")");

    function onDataLoaded(error, data) {
      if (error) return console.warn(error);

      data.forEach(function(d) {
        d.date = parseDate.parse(d.date);
      });

      var layers = stack(colors.map(function(color, i) {
        if (i === 0) {
          name = "First time commenters";
        } else {
          name = "Returning commenters";
        }

        return {
          name: name,
          color: color,
          values: data.map(function(d) {
            if (i === 0) {
              val = d.first_time_commenters;
            } else {
              val = d.returning_commenters;
            }

            return {date: d.date, y: val};
          })
        };
      }));

      // Find the value of the day with highest total value
      maxDateVal = d3.max(data, function(d) {
        var vals = d3.keys(d).map(function(key) { return key !== "date" ? d[key] : 0 });
        return d3.sum(vals);
      });

      // Set domains for axes
      x.domain(d3.extent(data, function(d) { return d.date; }));
      y.domain([0, maxDateVal]);

      var layer = svg.selectAll(".chart-layer")
        .data(layers)
        .enter().append("g")
        .attr("class", "chart-layer");

      layer.append("path")
        .attr("class", "area")
        .attr("d", function(d) { return area(d.values); })
        .style("fill", function(d) { return d.color; });

      layer.append("rect")
        .datum(function(d) {
          return { color: d.color, value: d.values[d.values.length - 1] };
        })
        .attr("transform", function(d, i) {
          var y_position_or_fallback;
          if (d.value.y0 + d.value.y > 1) {
            y_position_or_fallback = y(d.value.y0 + d.value.y / 2);
          } else {
            y_position_or_fallback = y(maxDateVal / ( 2 - i ));
          }

          return "translate(" + x(d.value.date) + "," + y_position_or_fallback + ")";
        })
        .attr("x", width + 10)
        .attr("dy", ".35em")
        .attr("width", "1em")
        .attr("height", "1em")
        .style("fill", function(d) { return d.color; });

      layer.append("text")
        .datum(function(d) {
          return { name: d.name, value: d.values[d.values.length - 1] };
        })
        .attr("transform", function(d, i) {
            var y_position_or_fallback;
            if (d.value.y0 + d.value.y > 1) {
              y_position_or_fallback = y(d.value.y0 + d.value.y / 2);
            } else {
              y_position_or_fallback = y(maxDateVal / ( 2 - i ));
            }

            var x_position_plus_offset = x(d.value.date) + 30;
            var y_position_plus_offset = y_position_or_fallback + 8;
          return "translate(" + x_position_plus_offset + "," + y_position_plus_offset + ")";
        })
        .attr("x", width)
        .attr("dy", ".35em")
        .text(function(d) { return d.name; });

      svg.append("g")
        .attr("class", "axis x-axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

      var yAxis = d3.svg.axis()
        .scale(y)
        .tickPadding([5])
        .orient("left");

      if (maxDateVal > 10) {
        yAxis = yAxis.ticks(10);
      } else if (maxDateVal > 5 ) {
        yAxis = yAxis.ticks(5);
      } else {
        yAxis = yAxis.ticks(2);
      }

      // TODO: Add tooltip to show specific dates and values

      svg.append("g")
        .attr("class", "axis y-axis")
        .call(yAxis);
    }
    d3.json(url, onDataLoaded);
  }
}
