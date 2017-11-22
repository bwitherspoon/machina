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
  m_module->argument_data = arg;
  m_module->argument_valid = 1;
  while (m_module->argument_ready == 0 || m_module->clock == 0) tick();
  tick();
  tick();
  m_module->argument_valid = 0;
  m_module->result_ready = 1;
  while (m_module->result_valid == 0 || m_module->clock == 0) tick();
  res_t res = m_module->result_data;
  tick();
  tick();
  m_module->result_ready = 0;
  return res;
}

} // namespace machina
