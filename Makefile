SUBDIR = rtl sim
.PHONY: all clean

all:
	for dir in $(SUBDIR); do make -C $$dir; done

test:
	for dir in $(SUBDIR); do make -C $$dir test; done

clean:
	for dir in $(SUBDIR); do make -C $$dir clean; done
