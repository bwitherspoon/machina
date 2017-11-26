#ifndef SIGMOID_INCLUDED
#define SIGMOID_INCLUDED

#include <cmath>

#include "memory.h"

namespace machina {

class Sigmoid : public Memory {
public:
  explicit Sigmoid(std::ostream& stream, bool derivative = false)
    : Memory(stream, 12), is_derivative(derivative)  { };

  Sigmoid& operator<<(int val) {
    if (is_derivative)
      Memory::operator<<(derivative(val));
    else
      Memory::operator<<(evaluate(val));
    return *this;
  }

  static double evaluate(double arg) {
    return 1.0 / (1.0 + std::exp(-1.0 * arg));
  }

  static int evaluate(int arg) {
    return std::lround((1 << 8) * evaluate(static_cast<double>(arg) / (1 << 8)));
  };

  static double derivative(double arg) {
    auto val = evaluate(arg);
    return val * (1.0 - val);
  }

  static int derivative(int arg) {
    return std::lround((1 << 8) * derivative(static_cast<double>(arg) / (1 << 8)));
  }
private:
  bool is_derivative;
};

} // namespace machina

#endif // SIGMOID_INCLUDED
