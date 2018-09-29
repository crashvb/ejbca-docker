#!/usr/bin/make -f

include makefile.config
-include makefile.config.local

.PHONY: build debug default diff get-cert logs remove run shell start status stop

default: build

build:
	docker build --force-rm=true --tag=$(registry)/$(image):$(tag) $(ARGS) .

clean:
	rm --force ./superadmin.p12
debug:
	docker run \
		--detach=true \
		--name=$(name)-db \
		--tty=true \
		$(dbrunargs) \
		$(registry)/mysql:ubuntu \
		$(ARGS)
	docker run \
		--link=$(name)-db:ejbca-db \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)/$(image):$(tag) \
		$(ARGS)

diff:
	docker diff $(name)

get-cert:
	docker cp $(name):/var/lib/ejbca/p12/superadmin.p12 ./
	docker exec $(name) cat /run/secrets/ejbca_admin_password

logs:
	docker logs --follow=true $(ARGS) $(name)

remove:
	docker rm --volumes=true $(ARGS) $(name) $(name)-db

run:
	docker run \
		--detach=true \
		--name=$(name)-db \
		--tty=true \
		$(dbrunargs) \
		$(registry)/mysql:ubuntu \
		$(ARGS)
	docker run \
		--detach=true \
		--link=$(name)-db:ejbca-db \
		--name=$(name) \
		--tty=true \
		$(runargs) \
		$(registry)/$(image):$(tag) \
		$(ARGS)

shell:
	docker exec --interactive=true --tty=true $(name) /bin/login -f root -p $(ARGS)

start:
	docker start $(ARGS) $(name)

status:
	docker ps $(ARGS) --all=true --filter=name=$(name)

stop:
	docker stop $(ARGS) $(name) $(name)-db
