
module hvl_top;
    import uvm_pkg::*;
    import env_pkg::*;
    `include "test.svh"

    initial begin
        run_test("base_test");
    end
endmodule : hvl_top
