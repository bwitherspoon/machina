#include <cstdint>
#include <utility>

#include "Vnode.h"

namespace net {

class Node : public Simulation<Vnode> {
public:
  Node() : Simulation<Vnode>::Simulation("node") {
    m_module->input_valid = 0;
    m_module->output_ready = 0;
  }

  Node& operator= (const Node&) = delete;

  Node(const Node&) = delete;

  using send_type = decltype(Vnode::input_data);
  void send(send_type);

  using recv_type = decltype(Vnode::output_data);
  recv_type recv();
};

void Node::send(send_type data) {
  step();
  m_module->input_data = data;
  m_module->input_valid = 1;
  step();
  while (m_module->input_ready == 0)
    cycle();
  step();
  m_module->input_valid = 0;
  m_module->input_data = 0;
  step();
}

Node::recv_type Node::recv() {
  step();
  m_module->output_ready = 1;
  step();
  while (m_module->output_valid != 1)
    cycle();
  recv_type data = m_module->output_data;
  step();
  m_module->output_ready = 0;
  step();
  return data;
}

} // namespace net
