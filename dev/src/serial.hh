#ifndef SERIAL_INCLUDED
#define SERIAL_INCLUDED

#include <string>
#include <vector>

namespace machina {

using std::string;
using std::vector;

class Serial {
public:
  Serial() = default;

  ~Serial();

  Serial & open(string port);

  vector<char> read(int size = -1);

  Serial & write(const vector<char>& data);

private:
  int fd = -1;
};

}

#endif // SERIAL_INCLUDED
