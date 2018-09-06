NAME=ifwatch
SRC=github.com/imc-trading/ifwatch
BUILD=.build
VER=$(shell awk -F '"' '/const version =/ {print $$2}' main.go)
REL=$(shell date -u +%Y%m%d%H%M)

all: build

clean:
	rm -f $(NAME) $(NAME)*.rpm
	rm -rf $(BUILD)

deps:
	glide up

build: clean
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

build-rpm:
	docker pull mickep76/centos-golang:latest >/dev/null
	docker run --rm -v "$${TEAMCITY_BUILD_CHECKOUTDIR:-$$PWD}":/go/src/$(SRC) -w /go/src/$(SRC) mickep76/centos-golang:latest rpmbuild

rpmbuild: deps build
	mkdir -p $(BUILD)/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	cp -r $(NAME) rpm $(BUILD)/SOURCES
	sed -e "s/%NAME%/$(NAME)/g" -e "s/%VERSION%/$(VER)/g" -e "s/%RELEASE%/$(REL)/g" rpm/$(NAME).spec >$(BUILD)/SPECS/$(NAME).spec
	rpmbuild -vv -bb --target="x86_64" --clean --define "_topdir $$(pwd)/$(BUILD)" $(BUILD)/SPECS/$(NAME).spec
	mv $(BUILD)/RPMS/x86_64/*.rpm .
