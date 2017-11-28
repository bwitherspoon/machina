#include <algorithm>
#include <iostream>
#include <string>

#include <boost/program_options.hpp>

#include "sigmoid.h"

namespace po = boost::program_options;
using namespace machina;

int main(int argc, char *argv[])
{
  std::string funct;
  int width = 0;
  int depth = 0;
  int scale = 0;

  try {
    po::options_description desc{"Options"};
    desc.add_options()
      ("help,h", "Help")
      ("funct,f", po::value<std::string>(&funct)->required(), "Function")
      ("width,w", po::value<int>(&width)->default_value(8), "Width")
      ("depth,d", po::value<int>(&depth)->default_value(4096), "Depth")
      ("scale,s", po::value<int>(&scale)->default_value(255), "Scale");
    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    if (vm.count("help")) {
      std::cout << desc;
      return 0;
    }
    po::notify(vm);
  } catch (const po::error& ex) {
    std::cerr << "ERROR: " << ex.what() << std::endl;
    return 1;
  }

  std::transform(funct.begin(), funct.end(), funct.begin(), ::tolower);

  bool prime;
  if (funct.compare("sigmoid") == 0) {
    prime = false;
  } else if (funct.compare("sigmoid-prime") == 0) {
    prime = true;
  } else {
    std::cerr << "ERROR: unknown function: " << funct << std::endl;
    return 1;
  }

  Sigmoid memory(width, scale, prime);
  for (int val = 0; val < depth >> 1; val++)
    memory << val;
  for (int val = -(depth >> 1); val < 0; val++)
    memory << val;
  std::cout << memory;

  return 0;
}
