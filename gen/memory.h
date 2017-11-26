#ifndef MEMORY_INCLUDED
#define MEMORY_INCLUDED

#include <ostream>
#include <iomanip>

namespace machina {

class Memory {
public:
  explicit Memory(std::ostream& os, int width = 2) : out(os), w(width) { }

  Memory(const Memory&) = delete;

  Memory& operator=(const Memory&) = delete;

  virtual ~Memory() = default;

  virtual Memory& operator<<(int val) {
    auto fill = (val < 0) ? std::setfill('f') : std::setfill('0');
    out << std::hex << fill << std::setw(w) << val << std::endl;
    return *this;
  }

private:
  std::ostream& out;
  const int w;
};

} // namespace machina

#endif // MEMORY_INCLUDED
