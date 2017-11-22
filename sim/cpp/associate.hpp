#include "Vassociate.h"

namespace machina {

class Associate : public Simulation<Vassociate> {
public:
  Associate() : Simulation<Vassociate>::Simulation("associate") {
    m_module->train = 0;
    m_module->argument_valid = 0;
    m_module->result_ready = 0;
    m_module->error_valid = 0;
    m_module->propagate_ready = 0;
  }

  Associate& operator= (const Associate&) = delete;

  Associate(const Associate&) = delete;

  using argument_type = decltype(Vassociate::argument_data);

  using result_type = decltype(Vassociate::result_data);

  result_type forward(argument_type arg);
};

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

} // namespace net
