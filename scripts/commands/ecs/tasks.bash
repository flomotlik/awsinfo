TASK_STATUS=""
TASK_FAMILY=""
TASK_NAME=""
SORT_BY="&to_string(createdAt)"

while getopts "dsf:n:" opt; do
  case "$opt" in
  s) TASK_STATUS="--desired-status STOPPED" ;;
  f) TASK_FAMILY="$OPTARG" ;;
  n) TASK_NAME="--service-name $OPTARG" ;;
  g) SORT_BY="&join('-',[taskDefinitionArn,to_string(createdAt)])" ;;
  esac
done

# To allow awsinfo ecs tasks -- TASK_FILTER without providing cluster arguments this is necessary
# to check if `--` is used. getopts will jump over `--` by default
if [[ "${@:$OPTIND-1:1}" == "--" ]]; then
  OPTIND=$OPTIND-1
fi

shift "$(($OPTIND - 1))"

split_args "$@"

if [[ ! -z "$TASK_FAMILY" ]]; then
  FAMILIES=$(awscli ecs list-task-definition-families --output text --query "families[$(auto_filter @ -- $TASK_FAMILY)].[@]")
  select_one Family "$FAMILIES"
  TASK_FAMILY="--family $SELECTED"
fi

CLUSTERS=$(awscli ecs list-clusters --output text --query "clusterArns[$(auto_filter @ -- $FIRST_RESOURCE)].[@]")
select_one Cluster "$CLUSTERS"

TASKS=$(awscli ecs list-tasks --output text $TASK_FAMILY $TASK_NAME --cluster $SELECTED $TASK_STATUS --query taskArns | sed "s/None//g")

if [[ "$(wc -w <<<"$TASKS")" -gt "100" ]]; then
  echo Too many tasks to show, use -f to limit to specific task family
  exit 1
fi

FILTER=$(auto_filter taskArn taskDefinitionArn containerInstanceArn lastStatus group cpu memory launchType -- $SECOND_RESOURCE)

if [[ ! -z "$TASKS" ]]; then
  awscli ecs describe-tasks --tasks $TASKS --cluster $SELECTED \
    --query "reverse(sort_by(tasks,$SORT_BY))[$FILTER].{ \
      \"1.Task\":taskArn, \
      \"2.Definition\":taskDefinitionArn, \
      \"3.Instance\":containerInstanceArn, \
      \"4.Status/Health\":join('/',[lastStatus,healthStatus]),
      \"5.CreatedAt\":createdAt,
      \"6.CPU/Memory\":join('/', [cpu , memory]),
      \"7.Containers\":length(containers),
      \"8.Group\":group,
      \"9.LaunchType\":launchType}" | sed "s/arn.*\///g" | print_table DescribeTasks
else
  echo "No Tasks Found"
fi
