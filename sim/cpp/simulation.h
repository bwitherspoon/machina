#ifndef NET_SIMULATION_HPP
#define NET_SIMULATION_HPP

#include <string>
#if VM_TRACE
  #include <verilated_vcd_c.h>
#endif

namespace machina {

template<typename MODULE>
class Simulation {
public:
  explicit Simulation(const std::string& name = "top") : m_trace(nullptr), m_time(0) {
    // TODO handle memory error
    m_module = new MODULE(name.c_str());
    m_module->clock = 0;
    m_module->reset = 0;
  }

  virtual ~Simulation() {
    m_module->final();
    delete m_module;
    if (m_trace) {
      m_trace->close();
      delete m_trace;
      m_trace = nullptr;
    }
  }

  void trace(const std::string& name = "dump.vcd") {
#if VM_TRACE
    if (!m_trace) {
      Verilated::traceEverOn(true);
      m_trace = new VerilatedVcdC;
      m_module->trace(m_trace, 99);
      m_trace->open(name.c_str());
    }
#endif
  }

  virtual void step() {
    m_module->eval();
    if (m_trace)
      m_trace->dump(m_time);
    m_time++;
  }

  virtual void tick() {
    m_module->clock = !m_module->clock;
    step();
  }

  virtual void cycle() {
    tick();
    tick();
  }

  virtual void reset() {
    m_module->reset = 1;
    cycle();
    cycle();
    m_module->reset = 0;
  }

  unsigned long time() const {
    return m_time;
  }

protected:
  MODULE* m_module;

private:
  VerilatedVcdC* m_trace;
  unsigned long m_time;

};

} // namespace net
#endif // NET_SIMULATION_HPP
