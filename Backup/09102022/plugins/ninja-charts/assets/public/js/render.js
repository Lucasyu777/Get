/*eslint-disable*/

jQuery(document).ready(function () {
    (function () {
        var charts = jQuery('.ninja-charts-chart-js-container');
        if (charts.length) {
            const th = this;
            charts.each(function () {
                var chartId = jQuery(this).data('id');
                var uniqid = jQuery(this).data('uniqid');
                var chartInstance = 'ninja_charts_instance_' + chartId;
                var canvasDom = 'ninja_charts_instance' + uniqid;
                var renderData = window[chartInstance];
                var options = JSON.parse(renderData.options);
                var canvas = document.getElementById(canvasDom);
                var ctx = canvas.getContext('2d');
                var chartOptions = {
                    // responsive: options.chart.responsive,
                    maintainAspectRatio: false,
                    plugins: {
                        labels: {
                            render: 'percentage',
                            precision: 2
                        }
                    },
                    legend: {
                        display: options.legend.display === 'true' ? true : false,
                        position: options.legend.position,
                        labels: {
                            fontColor: options.legend.fontColor
                        }
                    },
                    tooltips: {
                        enabled: options.tooltip.enabled === 'true' ? true : false,
                        mode: options.tooltip.mode === 'true' ? 'index' : 'single',
                        backgroundColor: options.tooltip.backgroundColor,
                        titleFontSize: Number(options.tooltip.titleFontSize),
                        titleFontColor: options.tooltip.titleFontColor,
                        bodyFontColor: options.tooltip.bodyFontColor,
                        footerFontColor: options.tooltip.bodyFontColor,
                        footerFontSize: 12,
                        footerAlign: 'right',
                        footerFontStyle: 'normal',
                        bodyFontSize: Number(options.tooltip.bodyFontSize),
                        displayColors: true,
                        borderColor: options.tooltip.borderColor,
                        borderWidth: Number(options.tooltip.borderWidth)
                    },
                    title: {
                        display: options.title.display === 'true' ? true : false,
                        text: renderData.chart_name,
                        position: options.title.position,
                        fontColor: options.title.fontColor,
                        fontStyle: options.title.fontStyle,
                        fontSize: Number(options.title.fontSize)
                    },
                    animation: {
                        easing: options.animation ? options.animation : 'linear'
                    },
                    scales: {
                        yAxes: [{
                            stacked: options.axes.stacked === 'true' ? true : false,
                            scaleLabel: {
                                display: options.axes.display === 'true' ? true : false,
                                labelString: options.axes.y_axis_label === null ? '' : options.axes.y_axis_label,
                                fontColor: options.chart.fontColor,
                                fontSize: Number(options.chart.fontSize),
                                fontStyle: options.chart.fontStyle
                            },
                            gridLines: {
                                display: options.axes.display === 'true' ? true : false
                            },
                            ticks: {
                                display: options.axes.display === 'true' ? true : false,
                                fontColor: options.chart.fontColor,
                                fontSize: Number(options.chart.fontSize),
                                fontStyle: options.chart.fontStyle,
                                beginAtZero: true,
                                min: null,
                                max: null
                            }
                        }],
                        xAxes: [{
                            stacked: options.axes.stacked === 'true' ? true : false,
                            scaleLabel: {
                                display: options.axes.display === 'true' ? true : false,
                                labelString: options.axes.x_axis_label === null ? '' : options.axes.x_axis_label,
                                fontColor: options.chart.fontColor,
                                fontSize: Number(options.chart.fontSize),
                                fontStyle: options.chart.fontStyle
                            },
                            gridLines: {
                                display: options.axes.display === 'true' ? true : false,
                            },
                            ticks: {
                                display: options.axes.display === 'true' ? true : false,
                                fontColor: options.chart.fontColor,
                                fontSize: Number(options.chart.fontSize),
                                fontStyle: options.chart.fontStyle,
                                beginAtZero: true
                            }
                        }]
                    },
                    layout: {
                        padding: {
                            left: options.layout.padding.left,
                            right: options.layout.padding.right,
                            top: options.layout.padding.top,
                            bottom: options.layout.padding.bottom
                        }
                    }
                };

                if (!options.axes.verticle_min_tick || isNaN(options.axes.verticle_min_tick)) {
                    delete chartOptions.scales.yAxes[0].ticks.min;
                } else {
                    chartOptions.scales.yAxes[0].ticks.min = parseInt(options.axes.verticle_min_tick);
                }

                if (!options.axes.verticle_max_tick || isNaN(options.axes.verticle_max_tick)) {
                    delete chartOptions.scales.yAxes[0].ticks.max;
                } else {
                    chartOptions.scales.yAxes[0].ticks.max = parseInt(options.axes.verticle_max_tick);
                }
                let chartType = renderData.chart_type;
                if (chartType === 'area') {
                    chartType = 'line';
                } else if (chartType === 'combo') {
                    chartType = 'bar';
                }
                new Chart(ctx, {
                    type: chartType,
                    data: renderData.chart_data,
                    options: chartOptions
                });
            })
        }
    })();
});
