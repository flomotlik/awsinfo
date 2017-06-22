TABLES=$(awscli dynamodb list-tables --output text --query "TableNames[$(filter @ $@)].[@]")
select_one Table "$TABLES"

awscli dynamodb describe-table --table-name $SELECTED --output table --query "Table.{\"1.Name\":TableName,\"2.Status\":TableStatus,\"3.Read/Write\":join('/',[to_string(ProvisionedThroughput.ReadCapacityUnits),to_string(ProvisionedThroughput.WriteCapacityUnits)]), \"4.DecreasesToday\":ProvisionedThroughput.NumberOfDecreasesToday, \"5.TableSize\":TableSizeBytes,\"6.ItemCount\":ItemCount,\"7.Attributes\":AttributeDefinitions,\"8.KeySchema\":KeySchema, \"9.Indexes\":{ \"1.LocalSecondaryIndexes\":LocalSecondaryIndexes,\"2.GlobalSecondaryIndexes\":GlobalSecondaryIndexes}}"