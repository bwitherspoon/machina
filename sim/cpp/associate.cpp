#include <stdexcept>

#include "associate.h"

namespace machina {

Associate::Associate() : Simulation<Vassociate>::Simulation("associate") {
  m_module->train = 0;
  m_module->argument_valid = 0;
  m_module->result_ready = 0;
  m_module->error_valid = 0;
  m_module->propagate_ready = 0;
}

Associate::res_t Associate::forward(arg_t arg) {
  unsigned long timeout = time() + 1000;
  m_module->argument_data = arg;
  m_module->argument_valid = 1;
  while (m_module->argument_ready == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on ready signal took to long.");
    tick();
  }
  tick();
  tick();
  timeout = time() + 1000;
  m_module->argument_valid = 0;
  m_module->result_ready = 1;
  while (m_module->result_valid == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on valid signal took to long.");
    tick();
  }
  res_t res = m_module->result_data;
  tick();
  tick();
  m_module->result_ready = 0;
  return res;
}

Associate::prp_t Associate::backward(err_t err) {
  if (m_module->train == 0)
    throw std::runtime_error("A backward pass requires training to be enabled.");
  unsigned long timeout = time() + 1000;
  m_module->error_data = err;
  m_module->error_valid = 1;
  while (m_module->error_ready == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on ready signal took to long.");
    tick();
  }
  tick();
  tick();
  timeout = time() + 1000;
  m_module->error_valid = 0;
  m_module->propagate_ready = 1;
  while (m_module->propagate_valid == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on valid signal took to long");
    tick();
  }
  prp_t prp = m_module->propagate_data;
  tick();
  tick();
  m_module->result_ready = 0;
  return prp;
}

} // namespace machina
