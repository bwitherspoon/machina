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

  using argument_type = decltype(Vassociate::argument_data);

  using result_type = decltype(Vassociate::result_data);

  result_type forward(argument_type arg);
};

} // namespace machina

#endif // ASSOCIATE_H
