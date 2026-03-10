MAKEFLAGS += --silent

OPTIONS ?= --build --quiet-pull --force-recreate --no-color --remove-orphans
APP ?= web

.PHONY: all init test ci clean
all:
	export ARM_CLIENT_SECRET="${ARM_CLIENT_SECRET:-fake-client-secret}"
	export ARM_SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:-00000000-0000-0000-0000-000000000000}"
	export ARM_CLIENT_ID="${ARM_CLIENT_ID:-00000000-0000-0000-0000-000000000000}"
	export ARM_TENANT_ID="${ARM_TENANT_ID:-00000000-0000-0000-0000-000000000000}"
	terraform init -upgrade
	terraform fmt -recursive
	terraform validate
	TF_LOG=${TF_LOG=:-debug} terraform plan

## Initialize terraform remote state
init:
	[ -d .terraform ] || terraform $@

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show validate: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt version:
	terraform $@

compose:
	docker compose up $(OPTIONS) -d

ci:
	COMPOSE_FILE=compose.yml:compose.ci.yml DOCKER_BUILDKIT=1 \
							 docker compose up $(OPTIONS) --exit-code-from ci

healthcheck:
	docker inspect $(APP) --format "{{ (index (.State.Health.Log) 0).Output }}"

test:
	[ -f ./test/test.sh ] && ./test/test.sh || true

release: ## Release (eg. V=v0.0.1)
	 @[ "$(V)" ] && [ ! -z "$(GITHUB_TOKEN)" ] \
		 && read -p "Press enter to confirm and push tag $(V) to origin, <Ctrl+C> to abort ..." \
		 && git tag $(V) -m "release: $(V)" \
		 && git push origin $(V) -f \
		 && git fetch --tags --force --all -p \
		 && curl -H "Authorization: token $(GITHUB_TOKEN)" \
				-X POST	\
				-H "Accept: application/vnd.github.v3+json"	\
				https://api.github.com/repos/atrakic/$(shell basename $$PWD)/releases \
				-d "{\"tag_name\":\"$(V)\",\"generate_release_notes\":true}"

clean:
	docker-compose down --remove-orphans -v --rmi local
	rm -rf .terraform *.tfstate

-include include.mk
