# ahb_verification
Verification of AMBA AHB 3 Lite protocol using SystemVerilog and UVM.

- Designed a UVM testbench with AHB Master and Slave agents and constrained random stimulus
using UVM Sequences, adhering to Transaction Level Modeling (TLM) to enhance modularity
- Implemented protocol violations checking using SystemVerilog Assertions (SVA) and assertion
coverage was done to ensure those assertions were exercised
- Implemented state machines of AHB Master and Slave agents using State Design Pattern to enhance
scalability and robustness
- Designed a functional coverage collector to assess if all possible combinations of test stimulus were
generated
- Implemented Master and Slave UVM drivers as pipelined drivers to decouple random stimulus
generation administration and response capture, thus speeding up testing simulation
- Synthesizable UVM driver and monitor BFMs were also integrated to make testing possible in both
emulation and simulation environments
