#include "Vproduct.h"

namespace net {

class Product : public Simulation<Vproduct> {
public:
  Product() : Simulation<Vproduct>::Simulation("product") {
    m_module->train = 0;
    m_module->argument_valid = 0;
    m_module->error_valid = 0;
    m_module->result_ready = 0;
    m_module->propagate_ready = 0;
  }

  Product& operator= (const Product&) = delete;

  Product(const Product&) = delete;

  using argument_type = decltype(Vproduct::argument_data);

  using result_type = decltype(Vproduct::result_data);

  result_type forward(argument_type arg);
};

Product::result_type Product::forward(argument_type data) {
  m_module->argument_data = data;
  m_module->argument_valid = 1;
  tick();
  while (m_module->argument_ready == 0) tick();
  tick();
  m_module->argument_valid = 0;
  tick();
  m_module->result_ready = 1;
  tick();
  while (m_module->result_valid == 1) tick();
  result_type result = m_module->result_data;
  tick();
  m_module->result_ready = 0;
  tick();
  return result;
}

} // namespace net
