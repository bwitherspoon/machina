#ifndef SIGMOID_INCLUDED
#define SIGMOID_INCLUDED

#include <cmath>
#include "memory.h"

namespace machina {

class Sigmoid : public Memory {
public:
  explicit Sigmoid(int width = 8, bool deriv = false)
    : Memory(width), is_deriv(deriv) { }

  Sigmoid& operator<<(int val) {
    if (is_deriv)
      Memory::operator<<(deriv(val));
    else
      Memory::operator<<(eval(val));
    return *this;
  }

  static double eval(double arg, double rate = 1.0) {
    return 1.0 / (1.0 + std::exp(-rate * arg));
  }

  int eval(int arg) const {
    return std::lround(scale() * eval(static_cast<double>(arg) / scale()));
  };

  static double deriv(double arg) {
    auto val = eval(arg);
    return val * (1.0 - val);
  }

  int deriv(int arg) const {
    return std::lround(scale() * deriv(static_cast<double>(arg) / scale()));
  }
private:
  int scale() const { return (1 << width()) - 1; }
  bool is_deriv;
};

} // namespace machina

#endif // SIGMOID_INCLUDED
