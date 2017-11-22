#include <iostream>

#include "verilated.h"

#include "simulation.h"
#include "associate.h"

using namespace machina;

static Associate* associator = nullptr;

double sc_time_stamp() {
  if (associator)
    return static_cast<double>(associator->time());
  else
    return 0;
}

int main(int argc, char *argv[]) {
  Verilated::commandArgs(argc, argv);

  Associate::result_type res;

  associator = new Associate;
  if (!associator)
    return 1;
  associator->trace("associate.vcd");
  associator->reset();
  associator->tick();

  while (!Verilated::gotFinish()) {
    if (associator->time() > 500)
      break;
    res = associator->forward(0x7f7f);
    std::cout << res << " : ";
    std::cout << "0x" << res << std::endl;
  }

  return 0;
}
