#include "serial.hh"

namespace machina {

Serial::Serial() : dev(-1)
{
  // TODO
}

Serial::~Serial()
{
  // TODO
}

Serial & Serial::open(string port, int baud)
{
  // TODO
  (void)port;
  (void)baud;
  return *this;
}

vector<char> Serial::read(int n)
{
  vector<char> data(n);
  return std::move(data);
}

Serial & Serial::write(const vector<char>& data)
{
  (void)data;
  return *this;
}

} // namespace machina
