#include <stdexcept>

#include "associate.h"

namespace machina {

Associate::Associate() : Simulation<Vassociate>::Simulation("associate") {
  m_module->train = 0;
  m_module->arg_valid = 0;
  m_module->res_ready = 0;
  m_module->err_valid = 0;
  m_module->fbk_ready = 0;
}

Associate::res_t Associate::forward(arg_t arg) {
  auto timeout = time() + TIMEOUT;
  m_module->arg_data = arg;
  m_module->arg_valid = 1;
  while (m_module->arg_ready == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on ready signal took to long.");
    tick();
  }
  tick();
  tick();
  timeout = time() + TIMEOUT;
  m_module->arg_valid = 0;
  m_module->res_ready = 1;
  while (m_module->res_valid == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on valid signal took to long.");
    tick();
  }
  res_t res = m_module->res_data;
  tick();
  tick();
  m_module->res_ready = 0;
  return res;
}

Associate::fbk_t Associate::backward(err_t err) {
  if (m_module->train == 0)
    throw std::runtime_error("A backward pass requires training to be enabled.");
  auto timeout = time() + TIMEOUT;
  m_module->err_data = err;
  m_module->err_valid = 1;
  while (m_module->err_ready == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on ready signal took to long.");
    tick();
  }
  tick();
  tick();
  timeout = time() + TIMEOUT;
  m_module->err_valid = 0;
  m_module->fbk_ready = 1;
  while (m_module->fbk_valid == 0 || m_module->clock == 0) {
    if (time() > timeout)
      throw std::runtime_error("Waiting on valid signal took to long");
    tick();
  }
  fbk_t fbk = m_module->fbk_data;
  tick();
  tick();
  m_module->res_ready = 0;
  return fbk;
}

} // namespace machina
