#include <iostream>
#include <boost/program_options.hpp>
#include "sigmoid.h"

namespace po = boost::program_options;

int main(int argc, char *argv[])
{
  bool derivative = false;

  try {
    po::options_description desc{"Options"};
    desc.add_options()
      ("help,h", "Help")
      ("derivative,d", po::bool_switch(&derivative), "Derivative");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (vm.count("help")) {
      std::cout << desc;
      return 0;
    }

  } catch (const po::error& ex) {
    std::cerr << ex.what() << std::endl;
  }

  machina::Sigmoid sigmoid(std::cout, derivative);

  for (int val = 0; val < 1 << 11; val++)
    sigmoid << val;
  for (int val = -(1 << 11); val < 0; val++)
    sigmoid << val;

  return 0;
}
