#include <iostream>

#include "verilated.h"

#include "simulation.hpp"
#include "node.hpp"

using namespace net;

static Node* node = nullptr;

double sc_time_stamp() {
  if (node)
    return static_cast<double>(node->time());
  else
    return 0;
}

int main(int argc, char *argv[]) {
  Verilated::commandArgs(argc, argv);

  Node::product_type data;

  node = new Node;
  if (!node)
    return 1;
  node->trace("node.vcd");
  node->reset();
  node->cycle();

  while (!Verilated::gotFinish()) {
    if (node->time() > 500)
      break;
    node->operand(0x7f7f);
    data = node->product();
    std::cout << data << " : ";
    std::cout << "0x" << data << std::endl;
  }

  return 0;
}
