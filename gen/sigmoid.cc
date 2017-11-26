#include <iostream>
#include "sigmoid.h"

int main (int argc, char *argv[]) {

  machina::Sigmoid sigmoid(std::cout);
  for (int val = 0; val < 1 << 11; val++)
    sigmoid << val;
  for (int val = -(1 << 11); val < 0; val++)
    sigmoid << val;

  return 0;
}
