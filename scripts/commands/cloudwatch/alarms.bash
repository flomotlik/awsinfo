awscli cloudwatch describe-alarms --output table --query "MetricAlarms[$(auto_filter AlarmName StateValue Namespace MetricName -- $@)].{
  \"1.Name\":AlarmName,
  \"2.Status\":StateValue,
  \"3.Metric\":join('/',[Namespace||'',MetricName||'']),
  \"4.Dimension\":Dimensions[].join('/',[Name,Value])|join(',',@),
  \"5.Comparison\":join('/',[ComparisonOperator,to_string(Threshold)])}"
