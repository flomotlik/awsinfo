ROLES=$(awscli iam list-roles --output text --query "Roles[$(auto_filter RoleName RoleId -- $@)].[RoleName]")
select_one Role "$ROLES"

awscli iam list-attached-role-policies --role-name $SELECTED --output table --query "AttachedPolicies[]"