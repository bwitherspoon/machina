# Interface

A common interface for unidirectional data transfer from a master device to a
slave device.

## Signals

- *dat* - Data to be transmitted from the master and received by the slave
- *rdy* - Asserted by the slave to indicate it is ready to receive data
- *stb* - Asserted by the master to indicate the data on the interface is valid

## Protocol

When the slave is ready to receive data it asserts *rdy*. To begin transmission
the master puts data on *dat* and asserts *stb*. If both *stb* and *rdy* are
asserted on the rising edge of the clock the transaction is complete. The master
shall then either start a new transaction by placing new data on *dat* and
keeping *stb* asserted or shall deassert *stb*.

Once the master has asserted *stb* it shall not be deasserted until the
transaction is complete. The master shall not wait for the slave's *rdy* signal
to be asserted before asserting *stb*.
