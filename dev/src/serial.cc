#include <stdexcept>

#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

#include "serial.hh"

namespace machina {

Serial::Serial() : tty(-1)
{
}

Serial::Serial(Serial&& other) : tty(other.tty)
{
  other.tty = -1;
}

Serial::~Serial()
{
  if (tty != -1)
    close(tty);
}

Serial & Serial::open(string port)
{
  string path = "/dev/tty" + port;
  tty = ::open(path.c_str(), O_RDWR | O_NOCTTY);
  if (tty == -1)
    throw std::runtime_error("unable to open TTY");
  if (!isatty(tty))
    throw std::runtime_error("not a TTY device");

  struct termios attr;
  cfmakeraw(&attr);
  attr.c_cc[VMIN] = 1;
  attr.c_cc[VTIME] = 0;
  if (cfsetspeed(&attr, B9600) < 0)
    throw std::runtime_error("unable to set TTY speed");
  if (tcsetattr(tty, TCSAFLUSH, &attr) < 0)
    throw std::runtime_error("unable to set TTY attributes");

  return *this;
}

Serial & Serial::read(vector<char>& data)
{
  auto n = ::read(tty, &data[0], data.size());
  if (n == -1)
    throw std::runtime_error("unable to read from TTY");
  else if (n < static_cast<decltype(n)>(data.size()))
    throw std::runtime_error("unable to complete read from TTY");
  return *this;
}

Serial & Serial::write(const vector<char>& data)
{
  auto n = ::write(tty, &data[0], data.size());
  if (n == -1)
    throw std::runtime_error("unable to write to TTY");
  else if (n < static_cast<decltype(n)>(data.size()))
    throw std::runtime_error("unable to complete write to TTY");
  return *this;
}

Serial& Serial::operator=(Serial&& other)
{
  tty = other.tty;
  other.tty = -1;
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
