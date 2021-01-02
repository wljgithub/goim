# Go parameters
GOCMD=GO111MODULE=on go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test

all: test build

.PHONY:build
build:
	rm -rf target/
	mkdir target/
	cp cmd/comet/comet-example.toml target/comet.toml
	cp cmd/logic/logic-example.toml target/logic.toml
	cp cmd/job/job-example.toml target/job.toml
	$(GOBUILD) -o target/comet cmd/comet/main.go
	$(GOBUILD) -o target/logic cmd/logic/main.go
	$(GOBUILD) -o target/job cmd/job/main.go

.PHONY: test
test:
	$(GOTEST) -v ./...

.PHONY: clean
clean:
	rm -rf target/

.PHONY: run
run: build env-init run-program

.PHONY: stop
stop:
	pkill -f target/logic
	pkill -f target/job
	pkill -f target/comet
	docker-compose down

.PHONY: run-program
run-program:

	nohup target/logic -conf=target/logic.toml -region=sh -zone=sh001 -deploy.env=dev -weight=10 2>&1 > target/logic.log &
	nohup target/comet -conf=target/comet.toml -region=sh -zone=sh001 -deploy.env=dev -weight=10 -addrs=127.0.0.1 -debug=true 2>&1 > target/comet.log &
	nohup target/job -conf=target/job.toml -region=sh -zone=sh001 -deploy.env=dev 2>&1 > target/job.log &

.PHONY: env-init
env-init:
	docker-compose up -d && sleep 3


.PHONY: env-clean
env-clean:
	docker-compose down