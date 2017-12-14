#include <stdexcept>

#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

#include "serial.hh"

namespace machina {

Serial::~Serial()
{
  if (fd != -1)
    close(fd);
}

Serial & Serial::open(string port)
{
  string path = "/dev/tty" + port;
  fd = ::open(path.c_str(), O_RDWR | O_NOCTTY);
  if (fd == -1)
    throw std::runtime_error("unable to open TTY");
  if (!isatty(fd))
    throw std::runtime_error("not a TTY device");

  struct termios attr;
  cfmakeraw(&attr);
  attr.c_cc[VMIN] = 1;
  attr.c_cc[VTIME] = 0;
  if (cfsetispeed(&attr, B9600) < 0 || cfsetospeed(&attr, B9600) < 0)
    throw std::runtime_error("unable to set TTY speed");
  if (tcsetattr(fd, TCSAFLUSH, &attr) < 0)
    throw std::runtime_error("unable to set TTY attributes");

  return *this;
}

vector<char> Serial::read(int)
{
  vector<char> data;
  return std::move(data);
}

Serial & Serial::write(const vector<char>&)
{
  return *this;
}

} // namespace machina
