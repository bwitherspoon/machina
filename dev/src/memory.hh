#ifndef MEMORY_INCLUDED
#define MEMORY_INCLUDED

#include <vector>
#include <ostream>
#include <iomanip>

namespace machina {

class Memory {
public:
  explicit Memory(int width = 8) : m_width(width) { }

  ~Memory() = default;

  int width() const { return m_width; }

  std::vector<int>::size_type depth() const { return m_data.size(); }

  bool empty() const { return m_data.empty(); }

  std::vector<int>::const_iterator begin() const { return m_data.begin(); }

  std::vector<int>::const_iterator end() const { return m_data.end(); }

  Memory& operator>>(int& val) {
    val = m_data.back();
    m_data.pop_back();
    return *this;
  }

  Memory& operator<<(int val) {
    m_data.push_back(val);
    return *this;
  }

  int& operator[](std::vector<int>::size_type pos) { return m_data[pos]; }

  const int& operator[](std::vector<int>::size_type pos) const { return m_data[pos]; }

private:
  std::vector<int> m_data;
  const int m_width;
};

} // namespace machina

std::ostream& operator<<(std::ostream& os, const machina::Memory& mem) {
  int width = mem.width() % 4 ? mem.width() / 4 + 1 : mem.width() / 4;
  for (auto& val : mem) {
    os << std::hex << std::setfill(val < 0 ? 'f' : '0') << std::setw(width) << val << std::endl;
  }
  return os;
}

#endif // MEMORY_INCLUDED
