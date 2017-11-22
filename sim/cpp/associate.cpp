#include "associate.h"

namespace machina {

Associate::Associate() : Simulation<Vassociate>::Simulation("associate") {
  m_module->train = 0;
  m_module->argument_valid = 0;
  m_module->result_ready = 0;
  m_module->error_valid = 0;
  m_module->propagate_ready = 0;
}

Associate::result_type Associate::forward(argument_type data) {
  m_module->argument_data = data;
  m_module->argument_valid = 1;
  while (m_module->argument_ready == 0 || m_module->clock == 0) tick();
  tick();
  tick();
  m_module->argument_valid = 0;
  m_module->result_ready = 1;
  while (m_module->result_valid == 0 || m_module->clock == 0) tick();
  result_type result = m_module->result_data;
  tick();
  tick();
  m_module->result_ready = 0;
  return result;
}

} // namespace machina
