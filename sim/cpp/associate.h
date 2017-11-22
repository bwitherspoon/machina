#ifndef ASSOCIATE_H
#define ASSOCIATE_H

#include "Vassociate.h"
#include "simulation.h"

namespace machina {

class Associate : public Simulation<Vassociate> {
public:
  Associate();

  ~Associate() = default;

  Associate& operator= (const Associate&) = delete;

  Associate(const Associate&) = delete;

  using arg_t = decltype(Vassociate::argument_data);

  using res_t = decltype(Vassociate::result_data);

  res_t forward(arg_t arg);
};

} // namespace machina

#endif // ASSOCIATE_H
