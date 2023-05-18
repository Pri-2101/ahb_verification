import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class apb_slave_single_trans_sequence extends uvm_sequence;
    `uvm_object_utils(apb_slave_single_trans_sequence)

    extern function new(string name = "apb_slave_single_trans_sequence");
    extern task body;

    int invalid_hwrite = 1'bx;
endclass;

function apb_slave_single_trans_sequence::new(string name = "apb_slave_single_trans_sequence");
    super.new(name);
endfunction : new

task apb_slave_single_trans_sequence::body;
    apb_slave_setup_item req;
    apb_slave_access_item rsp;

    for(int i = 0; i < 100; i++) begin
    req = apb_slave_setup_item::type_id::create("req");
    rsp = apb_slave_access_item::type_id::create("rsp");

        start_item(req);
        finish_item(req);
        //`uvm_info("Slave_REQ_ITEM_RCVD_FROM_MASTER", $sformatf("REQ_ITEM_%0d_RCVD_FROM_MASTER is %s", i+1, req.convert2string()), UVM_LOW);

        start_item(rsp);
        assert(rsp.randomize());
        rsp.HSIZE = req.HSIZE;
	if(req.HWRITE == invalid_hwrite)
	    rsp.HWRITE = 1'b0;
	else
    	    rsp.HWRITE = req.HWRITE;
        finish_item(rsp);
        //`uvm_info("Slave_RSP_ITEM_SENT_TO_MASTER", $sformatf("RSP_ITEM_%0d_SENT_TO_MASTER is %s", i+1, rsp.convert2string()), UVM_LOW);

    end

endtask : body
