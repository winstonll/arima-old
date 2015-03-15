/*! visualization.js | Arima.io */

/*global nv,d3*/

var visualization = (function () {

    /**
    * Set sensible defaults for properties shared by different charts
    * @param {String} id - the id of the svg tag to which the graph will be attached
    * @param {Obj} chart - the chart object that has just been created
    * @param {JSON} params - parameters used in this function can be defined in any charts,
    *                        even tho it may or may not be rendered to the final chart.
    */
    var setDefaults = function (id, chart, params) {

        if (chart.showLegend) {
            chart.showLegend(!params.hideLegend);
        }

        if (!params.hideTooltips) {
            chart.tooltips(true);
            if (params.tooltipFunc) {
                chart.tooltipContent(params.tooltipFunc);
            }
        }

        if (chart.type === "stacked" || chart.type === "bar") {
            chart.showControls(!params.hideControls);
        }

        if (!params.width) {
            if (chart.type === "pie") {
                params.width = params.height || 300;
            } else {
                params.width = params.height * 2 || 780;
            }
        }

        if (!params.height) {
            if (chart.type === "pie") {
                params.height = params.width;       // 1:1
            } else {
                params.height = params.width / 2;   // 2:1
            }
        }

        if (!params.duration) {
            // Duration of other charts scaled for similar transition speed.
            // bar chart as base reference
            params.duration = 150;
            if (chart.type === "scatter" || chart.type === "stacked") {
                params.duration *= 5;
            } else if (chart.type === "line") {
                params.duration *= 10;
            } else if (chart.type === "pie" || chart.type === "line+bar") {
                // don't have transition delays
                params.duration = 10000;
            }
        }

        if (!params.responsive) {
            chart.width(params.width).height(params.height);

            // svg element should be wrapped by a div with width or height specified
            if (params.scalable) {
                d3.select(id)
                    .attr('viewBox', '0 0 ' + params.width + ' ' + params.height);
            }
        }

        if (chart.type !== "pie" && chart.type !== "bar") {
            if (chart.type === "line+bar") {
                // y1 and y2 axis instead of just y..
                chart.yAxis = chart.y1Axis;
                params.yLabel = params.y1Label;
                params.yFormat = params.y1Format;

                chart.y2Axis.axisLabel(params.y2Label);
                if (typeof (params.y2Format) === "function") {
                    chart.y2Axis.tickFormat(params.y2Format);
                } else {
                    chart.y2Axis.tickFormat(d3.format(params.y2Format));
                }
            }

            // x and y axis exist
            chart.xAxis.axisLabel(params.xLabel);
            chart.yAxis.axisLabel(params.yLabel);

            if (typeof (params.xFormat) === "function") {
                chart.xAxis.tickFormat(params.xFormat);
            } else {
                chart.xAxis.tickFormat(d3.format(params.xFormat));
            }

            if (typeof (params.yFormat) === "function") {
                chart.yAxis.tickFormat(params.yFormat);
            } else {
                chart.yAxis.tickFormat(d3.format(params.yFormat));
            }
        }

        // applicable on some charts
        if (params.colors) {
            chart.color(params.colors);
        }

        if (params.debugFunc) {
            params.debugFunc(chart);
        }

        d3.select(id)
            .attr('width', params.width)
            .attr('height', params.height);
    };

    /**
    * Creates a Pie Chart
    * @param {String} id - the id of the svg tag to which the graph will be attached
    *   eg. if <svg id="chart"></svg> then id="#chart"
    * @param {JSON} data - the json data to construct the pie chart
    *   eg. data is passed in view as <%= raw @data.to_json.html_safe %>
    *     @data = [
    *       {
    *        :key => "One",
    *        :y => 5
    *       },
    *       {
    *        :key => "Two",
    *        :y => 10
    *       }
    *     ];
    * @param {JSON} params - parameters such as width, height and duration
    * throws error incorrect syntax
    */
    var drawPieChart = function (id, data, params) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart = nv.models.pieChart()
                .x(function (d) { return d.key; })
                .y(function (d) { return d.val; })
                .labelType(params.labelType)
                .donut(params.donut);

            chart.type = "pie";
            setDefaults(id, chart, params);

            if (params.half) {
                chart.pie
                    .startAngle(function (d) { return d.startAngle / 2 - Math.PI / 2; })
                    .endAngle(function (d) { return d.endAngle / 2 - Math.PI / 2; });
            }

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    /**
    * Creates a Line Graph
    * @param {String} id - the id of the svg tag for which the graph will be attached to
    *   eg. if <svg id="chart"></svg> then id="#chart"
    * @param {Array} data - the array of json data for which to construct the line graph
    *   eg. data is passed in view as <%= raw @data.to_json.html_safe %>
    *     @data = [
    *        {
    *          :values => [
    *              {
    *                  :x => 1,
    *                  :y => 2
    *              },
    *              {
    *                  :x => 2,
    *                  :y => 4
    *              }
    *          ],
    *          :key => "name",
    *          :color => "#FF7F0E"
    *        }
    *     ];
    * @param {JSON} params - parameters such as width, height and duration
    * throws error incorrect syntax
    */
    var drawLineChart = function (id, data, params) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart;

            if (params.focus) {
                chart = nv.models.lineWithFocusChart();
            }
            else {
                chart = nv.models.lineChart();
            }

            chart.useInteractiveGuideline(params.guide).margin({ right: 35 });

            chart.type = "line";
            setDefaults(id, chart, params);

            chart.yAxis.axisLabelDistance(42);

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    /**
    * Creates a Scatter Plot
    * @param {String} id - the id of the svg tag for which the graph will be attached to
    * @param {Array} data - the array of json data for which to construct the scatter plot
    * @param {JSON} params - parameters..
    * throws error incorrect syntax
    */
    var drawScatterChart = function (id, data, params) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart, idx, hasLine = true;

            for (idx = 0; idx < data.length; idx += 1) {
                hasLine = hasLine && data[idx].slope && data[idx].intercept;
            }

            if (hasLine || params.forceLine) {
                chart = nv.models.scatterPlusLineChart();
            } else {
                chart = nv.models.scatterChart();
            }

            chart.type = "scatter";
            setDefaults(id, chart, params);

            chart.tooltipContent(function (key, x, y) {
                return "<h3>" + key + "</h3><p>" + y + " at " + x + "</p>";
            });

            chart.yAxis.axisLabelDistance(24);

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    /**
    * Creates a Stacked Area Chart
    * @param {String} id - the id of the svg tag for which the graph will be attached to
    * @param {Array} data - the array of json data for which to construct the stacked chart
    * @param {JSON} params - parameters..
    * throws error incorrect syntax
    */
    var drawStackedChart = function (id, data, params) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart = nv.models.stackedAreaChart()
                .useInteractiveGuideline(params.guide)
                .x(function (d) { return d[0]; })
                .y(function (d) { return d[1]; });

            chart.type = "stacked";
            setDefaults(id, chart, params);

            chart.yAxis.axisLabelDistance(32);

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    /**
    * Creates a Continous Bar Chart
    * @param {String} id - the id of the svg tag for which the graph will be attached to
    * @param {Array} data - the array of json data for which to construct the bar chart
    * @param {JSON} params - parameters..
    * throws error incorrect syntax
    */
    var drawContinousBarChart = function (id, data, params) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart;

            if (params.horizontal) {
                chart = nv.models.multiBarHorizontalChart()
                        .showValues(params.showValues);
            } else {
                chart = nv.models.multiBarChart().delay(250);
            }

            chart.type = "bar";
            setDefaults(id, chart, params);

            chart
                .x(function (d) { return d.label; })
                .y(function (d) { return d.value; })
                .transitionDuration(params.duration);

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    /**
    * Creates a Line Plus Bar Chart
    * @param {String} id - the id of the svg tag for which the graph will be attached to
    * @param {Array} data - the array of json data for which to construct the line plus bar chart
    * @param {JSON} params - parameters..
    * throws error incorrect syntax
    */
    var drawLinePlusBarChart = function (id, data, params) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart = nv.models.linePlusBarChart()
                .x(function (d, i) { return i; })
                .y(function (d, i) { return d[1]; })
                .margin({ left: 75 });

            chart.type = "line+bar";
            setDefaults(id, chart, params);

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    /**
    * Creates a Discrete Bar Chart
    * @param {String} id - the id of the svg tag for which the graph will be attached to
    * @param {Array} data - the array of json data for which to construct the line plus bar chart
    * @param {JSON} params - parameters..
    * throws error incorrect syntax
    */
    var drawDiscreteBarChart = function ( id, data, params ) {
        if (!id || !data || !params) {
            throw "incorrect syntax";
        }

        nv.addGraph(function () {
            var chart = nv.models.discreteBarChart()
                .x(function (d) { return d.label; })
                .y(function (d) { return d.value; });

            chart.type="discrete+bar";
            setDefaults(id, chart, params);

            d3.select(id).datum(data)
                .transition().duration(params.duration)
                .call(chart);

            nv.utils.windowResize(chart.update);
            return chart;
        });
    };

    return {
        drawPieChart: drawPieChart,
        drawLineChart: drawLineChart,
        drawScatterChart: drawScatterChart,
        drawStackedChart: drawStackedChart,
        drawContinousBarChart: drawContinousBarChart,
        drawLinePlusBarChart: drawLinePlusBarChart,
        drawDiscreteBarChart: drawDiscreteBarChart
    };
}());
