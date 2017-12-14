#include "serial.hh"

using namespace machina;

int main()
{
  Serial ser;
  vector<char> dat;

  ser.open("USB0", 9600);
  ser.write(dat);
  ser.read();

  return 0;
}
