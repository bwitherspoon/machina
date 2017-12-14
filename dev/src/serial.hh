#ifndef SERIAL_INCLUDED
#define SERIAL_INCLUDED

#include <string>
#include <vector>

namespace machina {

using std::string;
using std::vector;

class Serial {
public:
  Serial();

  ~Serial();

  Serial & open(string port, int baud);

  vector<char> read(int n = -1);

  Serial & write(const vector<char>& data);

private:
  int dev;
};

}

#endif // SERIAL_INCLUDED
