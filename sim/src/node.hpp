#include <cstdint>
#include <utility>

#include "Vnode.h"

namespace net {

class Node : public Simulation<Vnode> {
public:
  Node() : Simulation<Vnode>::Simulation("node") {
    m_module->train = 0;
    m_module->operand_valid = 0;
    m_module->delta_valid = 0;
    m_module->product_ready = 0;
    m_module->feedback_ready = 0;
  }

  Node& operator= (const Node&) = delete;

  Node(const Node&) = delete;

  using operand_type = decltype(Vnode::operand_data);
  void operand(operand_type);

  using product_type = decltype(Vnode::product_data);
  product_type product();
};

void Node::operand(operand_type data) {
  step();
  m_module->operand_data = data;
  m_module->operand_valid = 1;
  step();
  while (m_module->operand_ready == 0)
    cycle();
  step();
  m_module->operand_valid = 0;
  step();
}

Node::product_type Node::product() {
  step();
  m_module->product_ready = 1;
  step();
  while (m_module->product_valid != 1)
    cycle();
  product_type data = m_module->product_data;
  step();
  m_module->product_ready = 0;
  step();
  return data;
}

} // namespace net
