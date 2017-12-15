#include <iostream>
#include <stdexcept>
#include <vector>

#include "serial.hh"

int main()
{
  machina::Serial ser;
  std::vector<char> xmt{'A', 'B', 'C', 'D'};
  std::vector<char> rcv(4);

  try {
    ser.open("USB1").write(xmt).read(rcv);
  } catch (std::exception &e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }

  for (auto &val : rcv)
    std::cout << val;
  std::cout << std::endl;

  try {
    ser << xmt >> rcv;
  } catch (std::exception &e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }

  for (auto &val : rcv)
    std::cout << val;
  std::cout << std::endl;

  return 0;
}
