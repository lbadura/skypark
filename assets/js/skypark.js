$(document).ready(function(){
  data = $("#csvData").html();
  csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(data);
  $("#csvExport").attr({
    'download': 'skypark.csv',
    'href': csvData,
    'target': '_blank'
  });
});
