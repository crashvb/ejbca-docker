#!/usr/bin/make -f

include makefile.config
-include makefile.config.local

.PHONY: build debug default diff logs remove run shell start status stop test-code

default: build

build: Dockerfile
	docker build --force-rm=true --tag=$(registry)$(namespace)/$(image):$(tag) $(buildargs) $(ARGS) .

debug:
	docker run \
		--detach=true \
		--hostname=$(name)-db \
		--name=$(name)-db \
		--tty=true \
		$(dbrunargs) \
		$(registry)$(namespace)/mysql:$(dbtag) \
		$(ARGS)
	docker run \
		--hostname=$(name) \
		--interactive=true \
		--link=$(name)-db:ejbca-db \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)$(namespace)/$(image):$(tag) \
		$(ARGS)

diff:
	@docker diff $(name)

logs:
	@docker logs --follow=true $(ARGS) $(name)

remove:
	-@docker rm --force=true --volumes=true $(ARGS) $(name) $(name)-db

run:
	docker run \
		--detach=true \
		--hostname=$(name)-db \
		--name=$(name)-db \
		--tty=true \
		$(dbrunargs) \
		$(registry)$(namespace)/mysql:$(dbtag) \
		$(ARGS)
	docker run \
		--detach=true \
		--hostname=$(name) \
		--link=$(name)-db:ejbca-db \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)$(namespace)/$(image):$(tag) \
		$(ARGS)

shell:
	@docker exec --interactive=true --tty=true --user=root $(name) /bin/bash $(ARGS)

start:
	docker start $(ARGS) $(name)-db $(name)

status:
	@docker ps $(ARGS) --all=true --filter=name=$(name)

stop:
	-@docker stop $(ARGS) $(name) $(name)-db

test-code: Dockerfile
	@docker run \
		--interactive=true \
		--rm=true \
		hadolint/hadolint:latest-debian \
		hadolint \
		$(ARGS) \
		- \
		< Dockerfile

