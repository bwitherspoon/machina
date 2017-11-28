#ifndef SIGMOID_INCLUDED
#define SIGMOID_INCLUDED

#include <cmath>
#include "memory.h"

namespace machina {

class Sigmoid : public Memory {
public:
  explicit Sigmoid(int width = 8, int scale = 1 << 8, bool deriv = false)
    : Memory(width), m_scale(scale), m_deriv(deriv) { }

  Sigmoid& operator<<(int val) {
    if (m_deriv)
      Memory::operator<<(deriv(val));
    else
      Memory::operator<<(eval(val));
    return *this;
  }

  static double eval(double arg, double rate = 1.0) {
    return 1.0 / (1.0 + std::exp(-rate * arg));
  }

  int eval(int arg) const {
    return std::lround(m_scale * eval(static_cast<double>(arg) / m_scale));
  };

  static double deriv(double arg) {
    auto val = eval(arg);
    return val * (1.0 - val);
  }

  int deriv(int arg) const {
    return std::lround(m_scale * deriv(static_cast<double>(arg) / m_scale));
  }
private:
  const int  m_scale;
  const bool m_deriv;
};

} // namespace machina

#endif // SIGMOID_INCLUDED
