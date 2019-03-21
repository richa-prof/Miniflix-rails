
  // Pie chart JS code
$(document).on('ready turbolinks:load', function() {

  drawLineChart(m_months);

  $('select#unique_month_wise').on('change', function (e) {
    var textSelected = $('select#unique_month_wise option:selected').text();
    var valueSelected = this.value;
    $("#chat_title").empty().append("Revenue Chart for "+textSelected);
    ajaxLoadData(valueSelected);
  });

    $("select#unique_month_wise option:last").attr("selected","selected");
    var valueSelected = $('select#unique_month_wise option:selected').val();
    var textSelected = $('select#unique_month_wise option:selected').text();
    $("#chat_title").empty().append("Revenue Chart for "+textSelected);
    // ajaxLoadData(valueSelected);


  });

  // function ajaxLoadData (valueSelected) {
  //  $.ajax({
 //      type: "GET",
 //      url: "/provider/get_monthly_revenue/"+valueSelected,
 //      async: false,
 //      cache: false,
 //      timeout: 30000,
 //      success:function(response)
 //      {
 //        drawPieChart(response);
 //      },
 //      error:function (xhr, ajaxOptions, thrownError)
 //      {
 //        //On error, we alert user
 //        alert(thrownError);
 //      }
 //    });
  // }

  var drawPieChart = function(data)
  {
    // GRAPH 3
    $.plot($("#graph2"), data,
    {
      series: {
        pie: {
          show: true,
          radius: 1,
          label: {
            show: true,
            radius: 3/4,
            formatter: function(label, series){
              return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">  '+Math.round(series.percent)+'%</div>';
            },
            background: { opacity: 0.5 }
          }
        }
      }
    });
  }

  /*
   * BAR CHART
   * ---------
  */

 var drawLineChart = function(months_data) {
  var bar_data = {
    data: months_data,
    color: "#3c8dbc"
  };

  $.plot("#bar-chart", [bar_data], {
    grid: {
      borderWidth: 1,
      borderColor: "black",
      tickColor: "#f3f3f3"
    },
    series: {
      lines: {
        show: true,
        barWidth: 0.5,
        align: "center"
      }
    },
    xaxis: {
      mode: "categories",
      tickLength: 0
    },
    yaxis: {
      tickDecimals: 0
    }
  });
}
  /* END BAR CHART */
