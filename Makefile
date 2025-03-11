build:
	cmake -G "Unix Makefiles" -B build

all: build
	make -C build

clean:
	rm -rf build

.DEFAULT_GOAL := all
