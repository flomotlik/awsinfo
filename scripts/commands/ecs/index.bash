CLUSTERS=$(aws ecs list-clusters --query clusterArns[$(filter '@' $@)] --output text)

aws ecs describe-clusters --clusters $CLUSTERS --output table --query "clusters[].{\"1.Name\":clusterName,\"2.Status\":status,\"3.Instances\":registeredContainerInstancesCount,\"4.RuningTasks\":runningTasksCount,\"5.PendingTasks\":pendingTasksCount,\"6.ActiveServices\":activeServicesCount}"