/////////////////////////////// BarChart //////////////////////////////////

const barCharts = {};

window.drawBarChart = (chartid, labels, seriesList, responsive, animation, indexAxis) => {

    var ctx = document.getElementById(chartid).getContext('2d');

    var datasets = seriesList.map(series => ({
        label: series.label,
        data: series.data,
        backgroundColor: series.backgroundColor,
        borderColor: series.borderColor,
        borderWidth: series.borderWidth || 1
    }));

    barCharts[chartid] = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: datasets
        },
        options: {
            animation: animation || true,
            responsive: responsive || false,
            indexAxis: indexAxis || 'x',
            scales: {
                x: {
                    beginAtZero: true
                },
                y: {
                    beginAtZero: true
                }
            },
            plugins: {
                legend: {
                    position: 'bottom'
                },
                datalabels: {
                    anchor: 'center',
                    align: 'center',
                    formatter: Math.round,
                    font: {
                        weight: 'bold'
                    }
                }
            }
        },
        plugins: [ChartDataLabels],

    });
};

/////////////////////////////// LineChart //////////////////////////////////
const lineCharts = {};

window.drawLineChart = (chartid, labels, seriesList, responsive, animation, fill, tension) => {

    var ctx = document.getElementById(chartid).getContext('2d');
    var datasets = seriesList.map(series => ({
        label: series.label,
        data: series.data,
        backgroundColor: series.backgroundColor,
        borderColor: series.borderColor,
        borderWidth: series.borderWidth || 1,
        fill: series.fill || fill || false,
        tension: series.tension || tension || 0.2,
    }));

    lineCharts[chartid] = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: datasets
        },
        options: {
            animation: animation || true,
            responsive: responsive || false,
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            plugins: {
                legend: {
                    position: 'bottom'
                },
                datalabels: {
                    anchor: 'end',
                    align: 'top',
                    formatter: Math.round,
                    font: {
                        weight: 'bold'
                    }
                }
            }
        },
        plugins: [ChartDataLabels]
    });
};