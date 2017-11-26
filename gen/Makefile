SOURCES = sigmoid.cc
HEADERS = memory.h sigmoid.h
CXXFLAGS = -Wall -std=c++11

all: sigmoid

sigmoid: $(SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $(SOURCES)

test:

clean:
	-$(RM) sigmoid

.PHONY: all test clean
