.PHONY:=default FORCE build clean clean-all
.PHONY:=$(PHONY)

# For AWS Bedrock, we need newer AWS-cli and Boto3
# Automate the steps to set up the AWS Bedrock client
# See https://github.com/aws-samples/amazon-bedrock-workshop

# Directory contianing this file
MKFILE_DIR := $(shell cd $(dir $(abspath $(lastword $(MAKEFILE_LIST)))) && pwd)

REPO_DIR_PARENT:=$(HOME)/git
REPO_NAME:=amazon-bedrock-workshop
REPO_DIR:=$(REPO_DIR_PARENT)/$(REPO_NAME)
REPO:=https://github.com/aws-samples/amazon-bedrock-workshop.git

PYTHON3:=. $(REPO_DIR)/venv/bin/activate && python3
PIP:=. $(REPO_DIR)/venv/bin/activate && pip

default: test

FORCE:

# Undo all work
# Cleanup before checking this code into version control
clean-all: clean

clean:
	rm -rf $(REPO_DIR)/logs
	rm -rf $(REPO_DIR)/dependencies
	rm -rf $(REPO_DIR)/venv

$(REPO_DIR):
	$(info Install git repo $(REPO_DIR_PARENT))
	mkdir -p $(REPO_DIR_PARENT) && \
	cd $(REPO_DIR_PARENT) && \
	git clone $(REPO) $(REPO_NAME)

$(REPO_DIR)/logs: $(REPO_DIR)
	mkdir -p $(REPO_DIR)/logs

$(REPO_DIR)/logs/dependencies: $(REPO_DIR)/logs
	$(info Install dependencies under $(REPO_DIR) to $(REPO_DIR)/dependencies)
	cd $(REPO_DIR) && \
	bash ./download-dependencies.sh && \
	touch $(REPO_DIR)/logs/dependencies

$(REPO_DIR)/logs/venv: $(REPO_DIR)
	$(info Create venv under $(REPO_DIR))
	cd $(REPO_DIR) && python3 -m venv venv && \
	touch $(REPO_DIR)/logs/venv

# Avoid https://github.com/yaml/pyyaml/issues/724
# by adding the pip constraint
$(REPO_DIR)/logs/boto3: $(REPO_DIR)/logs $(REPO_DIR)/venv $(REPO_DIR)/dependencies
	$(info Run pip-install boto3)
	cd $(REPO_DIR)/dependencies && \
	echo 'cython < 3.0' > ./constraints.txt && \
	PIP_CONSTRAINT=constraints.txt $(PIP) install --force-reinstall \
	../dependencies/awscli-1.27.162-py3-none-any.whl \
	../dependencies/boto3-1.26.162-py3-none-any.whl \
	../dependencies/botocore-1.29.162-py3-none-any.whl \
	&& touch $(REPO_DIR)/logs/boto3

$(REPO_DIR)/logs/langchain: $(REPO_DIR)/logs/boto3
	$(info Run pip-install langchain)
	$(PIP) install --quiet langchain==0.0.249 && \
	touch $(REPO_DIR)/logs/langchain.done

$(REPO_DIR)/logs/aws-cli: $(REPO_DIR)/logs/langchain $(REPO_DIR)/logs/boto3
	$(info Test aws cli)
	aws --version && \
	aws sts get-caller-identity

test: $(REPO_DIR)/logs/aws-cli

