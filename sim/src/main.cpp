#include <iostream>

#include "verilated.h"

#include "simulation.hpp"
#include "product.hpp"

using namespace net;

static Product* prod = nullptr;

double sc_time_stamp() {
  if (prod)
    return static_cast<double>(prod->time());
  else
    return 0;
}

int main(int argc, char *argv[]) {
  Verilated::commandArgs(argc, argv);

  Product::result_type res;

  prod = new Product;
  if (!prod)
    return 1;
  prod->trace("product.vcd");
  prod->reset();
  prod->tick();

  while (!Verilated::gotFinish()) {
    if (prod->time() > 500)
      break;
    res = prod->forward(0x7f7f);
    std::cout << res << " : ";
    std::cout << "0x" << res << std::endl;
  }

  return 0;
}
