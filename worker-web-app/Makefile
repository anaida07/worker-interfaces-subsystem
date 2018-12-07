MAKE_ARGS:=

ifeq ($(CODEBUILD_RESOLVED_SOURCE_VERSION),)
	MAKE_ARGS=--profile $(AWS_PROFILE) --region $(AWS_REGION)
endif

ACCOUNT_ID:=$(shell aws sts get-caller-identity $(MAKE_ARGS) --output text --query 'Account')

# all xxx needs to be updated, also modify other constants as required

# Service stack parameters
ENV_TYPE:=nonproduction
SUB_SYSTEM:=wke
SERVICE_NAME:=worker-web-app
APP_PORT:=8081
HEALTH_CHECK_PATH:=/service-status
URL_PATTERN:=/*
PRIORITY:=10
DESIRED_COUNT:=2
SOURCE_PATH:=xxx

GIT_REPO:=cloudfactory/xxx

# Latest service version, follow Semantic Versioning, always update this on release/deploy
SERVICE_VERSION=0.0.0

STACK_NAME:=$(ENV_LABEL)-$(SUB_SYSTEM)-$(SERVICE_NAME)
IMAGE_NAME:=$(SUB_SYSTEM)-$(SERVICE_NAME)
ECR_ADDR:=$(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE_NAME)

build:
	docker build -t $(SERVICE_NAME) .
run:
	docker run -it -p $(APP_PORT):$(APP_PORT) $(SERVICE_NAME):latest
test:
	# Replace this with service unit/functional tests
	docker build -t $(SERVICE_NAME) .

ecr:
	aws ecr create-repository --repository-name $(IMAGE_NAME) $(MAKE_ARGS)
ecr-delete:
	aws ecr delete-repository --repository-name $(IMAGE_NAME) $(MAKE_ARGS)
ecr-push:
	make build
	eval `aws ecr get-login --no-include-email $(MAKE_ARGS)`
	docker tag $(SERVICE_NAME):latest $(ECR_ADDR):$(SERVICE_VERSION)
	docker push $(ECR_ADDR):$(SERVICE_VERSION)

create-resources:
	aws cloudformation create-stack --stack-name $(STACK_NAME)-resources --template-body file://Infrastructure/resources.yaml $(MAKE_ARGS) --parameters $(RESOURCE_ARGS)
update-resources:
	aws cloudformation update-stack --stack-name $(STACK_NAME)-resources --template-body file://Infrastructure/resources.yaml $(MAKE_ARGS) --parameters $(RESOURCE_ARGS)

create-service:
	aws cloudformation create-stack --stack-name $(STACK_NAME) --template-body file://Infrastructure/service.yaml $(MAKE_ARGS) --capabilities CAPABILITY_IAM --parameters $(SERVICE_ARGS)
update-service:
	aws cloudformation update-stack --stack-name $(STACK_NAME) --template-body file://Infrastructure/service.yaml $(MAKE_ARGS) --capabilities CAPABILITY_IAM --parameters $(SERVICE_ARGS)
deploy-service:
	aws cloudformation deploy --stack-name $(STACK_NAME) --parameter-overrides ServiceVersion=$(SERVICE_VERSION) --template-file Infrastructure/service.yaml --capabilities CAPABILITY_IAM $(MAKE_ARGS)

create-deployment-stack:
	aws cloudformation create-stack --stack-name $(STACK_NAME)-deployment --template-body file://Infrastructure/deployment.yaml $(MAKE_ARGS) --capabilities CAPABILITY_IAM --parameters $(DEPLOYMENT_ARGS)
update-deployment-stack:
	aws cloudformation update-stack --stack-name $(STACK_NAME)-deployment --template-body file://Infrastructure/deployment.yaml $(MAKE_ARGS) --capabilities CAPABILITY_IAM --parameters $(DEPLOYMENT_ARGS)

create-release-stack:
	aws cloudformation create-stack --stack-name $(IMAGE_NAME)-release --template-body file://Infrastructure/release.yaml $(MAKE_ARGS) --capabilities CAPABILITY_IAM --parameters $(RELEASE_ARGS)
update-release-stack:
	aws cloudformation update-stack --stack-name $(IMAGE_NAME)-release --template-body file://Infrastructure/release.yaml $(MAKE_ARGS) --capabilities CAPABILITY_IAM --parameters $(RELEASE_ARGS)

version:
	echo $(SERVICE_VERSION)

RESOURCE_ARGS=ParameterKey=EnvLabel,ParameterValue=$(ENV_LABEL) ParameterKey=EnvType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME)

SERVICE_ARGS=ParameterKey=EnvLabel,ParameterValue=$(ENV_LABEL) ParameterKey=EnvType,ParameterValue=$(ENV_TYPE) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME) ParameterKey=ServiceVersion,ParameterValue=$(SERVICE_VERSION) ParameterKey=DockerRepoUrl,ParameterValue=$(ECR_ADDR) ParameterKey=AppPort,ParameterValue=$(APP_PORT) ParameterKey=UrlPattern,ParameterValue=$(URL_PATTERN) ParameterKey=Priority,ParameterValue=$(PRIORITY) ParameterKey=DesiredCount,ParameterValue=$(DESIRED_COUNT) ParameterKey=HealthCheckPath,ParameterValue=$(HEALTH_CHECK_PATH)

DEPLOYMENT_ARGS=ParameterKey=EnvLabel,ParameterValue=$(ENV_LABEL) ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=GitRepo,ParameterValue=$(GIT_REPO) ParameterKey=SourcePath,ParameterValue=$(SOURCE_PATH)

RELEASE_ARGS=ParameterKey=ServiceName,ParameterValue=$(SERVICE_NAME) ParameterKey=SubSystem,ParameterValue=$(SUB_SYSTEM) ParameterKey=GitRepo,ParameterValue=$(GIT_REPO) ParameterKey=SourcePath,ParameterValue=$(SOURCE_PATH)
