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

  Serial(Serial&& other);

  Serial(const Serial&) = delete;

  ~Serial();

  Serial& open(string port);

  Serial& read(vector<char>& data);

  Serial& write(const vector<char>& data);

  Serial& operator=(const Serial&) = delete;

  Serial& operator=(Serial&& other);

  Serial& operator>>(vector<char>& data);

  Serial& operator<<(const vector<char>& data);

private:
  int fd;
};

}

#endif // SERIAL_INCLUDED
