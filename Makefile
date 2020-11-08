#IMAGE:=frolvlad/alpine-glibc
#VERSION:=alpine-3.12
IMAGE:=melito00/alpine-glibc-sbcl
VERSION:=0.0.2
UDIR:=/home/melito00
WPATH:=work

run:
	@echo $(PWD)
	@echo $(IMAGE):$(VERSION)
	docker run --volume $(PWD)/$(WPATH):$(UDIR)/$(WPATH) \
		-p 8888:8888 \
		--workdir "$(UDIR)/$(WPATH)" \
		--rm -it $(IMAGE):$(VERSION)

ros:
	@echo $(PWD)
	@echo $(IMAGE):$(VERSION)
	docker run --volume $(PWD)/$(WPATH):$(UDIR)/$(WPATH) \
		-p 8888:8888 \
		--workdir "$(UDIR)/$(WPATH)" \
		--rm -it $(IMAGE):$(VERSION) ros run

build:
	docker build -f ./Dockerfile -t $(IMAGE):$(VERSION) .

rmi:
	docker rmi $(IMAGE):$(VERSION)
