NAME=ifwatch
SRC=github.com/mickep76/$(NAME)
VER=$(shell awk -F '"' '/const version =/ {print $$2}' main.go)
REL=$(shell date -u +%Y%m%d%H%M)

all: linux

clean:
	rm -f $(NAME) $(NAME)*.rpm

linux: clean
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

rpm:
	docker build --pull=true --build-arg SRC=$(SRC) --build-arg VER=$(VER) --build-arg REL=$(REL) .

.PHONY: clean linux rpm
