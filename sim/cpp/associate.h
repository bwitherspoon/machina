#ifndef ASSOCIATE_H
#define ASSOCIATE_H

#include "Vassociate.h"
#include "simulation.h"

namespace machina {

class Associate : public Simulation<Vassociate> {
public:
  using arg_t = decltype(Vassociate::argument_data);
  using res_t = decltype(Vassociate::result_data);
  using err_t = decltype(Vassociate::error_data);
  using prp_t = decltype(Vassociate::propagate_data);

  Associate();

  ~Associate() = default;

  Associate& operator= (const Associate&) = delete;

  Associate(const Associate&) = delete;

  res_t forward(arg_t arg);

  prp_t backward(err_t err);
};

} // namespace machina

#endif // ASSOCIATE_H
