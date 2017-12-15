#include <stdexcept>

#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

#include "serial.hh"

namespace machina {

Serial::Serial() : fd(-1)
{
}

Serial::Serial(Serial&& other) : fd(other.fd)
{
  other.fd = -1;
}

Serial& Serial::operator=(Serial&& other)
{
  fd = other.fd;
  other.fd = -1;
  return *this;
}

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

Serial & Serial::read(vector<char>& data)
{
  auto n = ::read(fd, &data[0], data.size());
  if (n == -1)
    throw std::runtime_error("unable to read from TTY");
  else if (n < static_cast<decltype(n)>(data.size()))
    throw std::runtime_error("unable to complete read from TTY");
  return *this;
}

Serial & Serial::write(const vector<char>& data)
{
  auto n = ::write(fd, &data[0], data.size());
  if (n == -1)
    throw std::runtime_error("unable to write to TTY");
  else if (n < static_cast<decltype(n)>(data.size()))
    throw std::runtime_error("unable to complete write to TTY");
  return *this;
}

Serial& Serial::operator>>(vector<char>& data)
{
  return read(data);
}

Serial& Serial::operator<<(const vector<char>& data)
{
  return write(data);
}

} // namespace machina
