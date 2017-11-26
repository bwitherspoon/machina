#ifndef MEMORY_INCLUDED
#define MEMORY_INCLUDED

#include <ostream>
#include <iomanip>

namespace machina {

class Memory {
public:
  explicit Memory(std::ostream& stream, int width = 8) : stream(stream), width(width) { }

  Memory(const Memory&) = delete;

  Memory& operator=(const Memory&) = delete;

  virtual ~Memory() = default;

  virtual Memory& operator<<(int val) {
    auto digits = (width % 4) ? width / 4 + 1 : width / 4;
    auto fill = (val < 0) ? std::setfill('f') : std::setfill('0');
    stream << std::hex << fill << std::setw(digits) << val << std::endl;
    return *this;
  }

private:
  std::ostream& stream;
  const int width;
};

} // namespace machina

#endif // MEMORY_INCLUDED
