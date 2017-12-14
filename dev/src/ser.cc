#include <iostream>
#include <stdexcept>

#include "serial.hh"

using namespace machina;

int main()
{
  Serial ser;
  vector<char> dat;

  try {
    ser.open("USB0");
    ser.write(dat);
    ser.read();
  } catch (std::exception &e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
  }

  return 0;
}
