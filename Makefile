# all xxx needs to be replaced

# nonproduction/production, defaults to nonproduction
ENV_TYPE:=nonproduction
# internal/internet-facing, defaults to internal
LOAD_BALANCER_SCHEME:=internet-facing

SUB_SYSTEM:=wke

GIT_REPO_URL:=https://github.com/cloudfactory/xxx.git

STACK_NAME:=$(SUB_SYSTEM)-subsystem

CLUSTER_STACK:=$(ENV_LABEL)-$(STACK_NAME)-cluster
RESOURCES_STACK:=$(ENV_LABEL)-$(STACK_NAME)-resources

create-cluster:
	aws cloudformation create-stack --stack-name $(CLUSTER_STACK) --template-body file://Infrastructure/cluster.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_IAM --parameters ParameterKey=EnvironmentName,ParameterValue=$(ENV_LABEL) ParameterKey=EnvironmentType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=LoadBalancerScheme,ParameterValue=$(LOAD_BALANCER_SCHEME)
update-cluster:
	aws cloudformation update-stack --stack-name $(CLUSTER_STACK) --template-body file://Infrastructure/cluster.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_IAM --parameters ParameterKey=EnvironmentName,UsePreviousValue=true ParameterKey=EnvironmentType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true ParameterKey=LoadBalancerScheme,UsePreviousValue=true
describe-cluster:
	aws cloudformation describe-stacks --stack-name $(CLUSTER_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'
delete-cluster:
	aws cloudformation delete-stack --stack-name $(CLUSTER_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

create-resources:
	aws cloudformation create-stack --stack-name $(RESOURCES_STACK) --template-body file://Infrastructure/resources.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --parameters ParameterKey=EnvironmentName,ParameterValue=$(ENV_LABEL) ParameterKey=EnvironmentType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM)
update-resources:
	aws cloudformation update-stack --stack-name $(RESOURCES_STACK) --template-body file://Infrastructure/resources.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --parameters ParameterKey=EnvironmentName,UsePreviousValue=true ParameterKey=EnvironmentType,UsePreviousValue=true ParameterKey=SubSystem,UsePreviousValue=true
describe-resources:
	aws cloudformation describe-stacks --stack-name $(RESOURCES_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'
delete-resources:
	aws cloudformation delete-stack --stack-name $(RESOURCES_STACK) --profile $(AWS_PROFILE) --region $(AWS_REGION)

create-ci:
	aws cloudformation create-stack --stack-name $(STACK_NAME)-ci-dum --template-body file://Infrastructure/ci.yaml --profile $(AWS_PROFILE) --region $(AWS_REGION) --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=GitRepoUrl,ParameterValue=$(GIT_REPO_URL)

test:
	echo "Command to test whole sub system. Not implemented yet."
