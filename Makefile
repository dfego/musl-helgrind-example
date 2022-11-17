.PHONY: default build musl glibc clean clean-all

docker-cmd = docker run --rm -it -v $(PWD):/host -w /host musl-helgrind-test

default:
	@echo "To build the Docker container, run: make build"
	@echo "Run the following to see no errors: make glibc"
	@echo "Run the following to see errors: make musl"

build:
	docker build -t musl-helgrind-test:latest .

main-glibc: main.c
	$(docker-cmd) gcc -Wall -lpthread -o $@ $^

main-musl: main.c
	$(docker-cmd) musl-gcc -Wall -lpthread -o $@ $^

musl: main-musl
	$(docker-cmd) valgrind --tool=helgrind ./$^

glibc: main-glibc
	$(docker-cmd) valgrind --tool=helgrind ./$^

clean:
	rm -f main-musl main-glibc

clean-all: clean
	docker rmi musl-helgrind-test:latest
