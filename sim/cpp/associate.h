#ifndef ASSOCIATE_H
#define ASSOCIATE_H

#include "Vassociate.h"
#include "simulation.h"

namespace machina {

class Associate : public Simulation<Vassociate> {
public:
  using arg_t = decltype(Vassociate::arg_data);
  using res_t = decltype(Vassociate::res_data);
  using err_t = decltype(Vassociate::err_data);
  using fbk_t = decltype(Vassociate::fbk_data);

  Associate();

  ~Associate() = default;

  Associate& operator= (const Associate&) = delete;

  Associate(const Associate&) = delete;

  res_t forward(arg_t arg);

  fbk_t backward(err_t err);

private:
  static const unsigned int TIMEOUT = 1000;
};

} // namespace machina

#endif // ASSOCIATE_H
