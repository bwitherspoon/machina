#ifndef SIGMOID_INCLUDED
#define SIGMOID_INCLUDED

#include <cmath>

#include "memory.h"

namespace machina {

class Sigmoid : public Memory {
public:
  explicit Sigmoid(std::ostream& os) : Memory(os, 3) { };
  Sigmoid& operator<<(int val) {
    Memory::operator<<(eval(val));
    return *this;
  }

private:
  double eval(double val) { return 1.0 / (1.0 + std::exp(-1.0 * val)); }
  int eval(int val) { return std::lround((1 << 8) * eval(static_cast<double>(val) / (1 << 8))); };
};

} // namespace machina

#endif // SIGMOID_INCLUDED
