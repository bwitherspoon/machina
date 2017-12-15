#include <iostream>
#include <stdexcept>

#include "serial.hh"

using namespace machina;

int main()
{
  Serial ser;
  vector<char> dat(4, 0xff);

  try {
    ser.open("USB0").write(dat).read(dat);
  } catch (std::exception &e) {
    std::cerr << "ERROR: " << e.what() << std::endl;
    return 1;
  }

  return 0;
}
