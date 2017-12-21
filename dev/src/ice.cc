#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>

#include <boost/range/adaptor/reversed.hpp>

#include "serial.hh"

int main()
{
  machina::Serial ser;
  std::vector<char> arg{8, 6};
  std::vector<char> res(2);

  for (auto &val : arg)
    std::cout << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(val) << ' ';
  std::cout << std::endl;

  try {
    ser.open("USB1").write(arg).read(res);
  } catch (std::exception &e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }

  for (auto &val : boost::adaptors::reverse(res))
    std::cout << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(val) << ' ';
  std::cout << std::endl;

  return 0;
}
