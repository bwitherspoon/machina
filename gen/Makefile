SOURCES = sigmoid.cc
HEADERS = memory.h sigmoid.h
CXXFLAGS = -Wall -std=c++11
LDFLAGS = -lboost_program_options

all: sigmoid

sigmoid: $(SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(SOURCES)

test:

clean:
	-$(RM) sigmoid

.PHONY: all test clean
