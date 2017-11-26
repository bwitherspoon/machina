SUBDIR = syn sim

.PHONY: all test clean

all:
	for dir in $(SUBDIR); do make -C $$dir all; done

test:
	for dir in $(SUBDIR); do make -C $$dir test; done

clean:
	for dir in $(SUBDIR); do make -C $$dir clean; done
