import uvm_pkg::*;
import apb_master_agent_pkg::*;
//`include "apb_master_seq_item.svh"
//`include "apb_master_agent_config.svh"
`include "uvm_macros.svh"

class apb_master_single_trans_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(apb_master_single_trans_sequence)

    extern function new(string name = "apb_master_single_trans_sequence");
    extern task body;

endclass

function apb_master_single_trans_sequence::new(string name = "apb_master_single_trans_sequence");
    super.new(name);
endfunction

task apb_master_single_trans_sequence::body;
    apb_master_agent_config master_agent_cfg = apb_master_agent_config::get_config(m_sequencer);
    apb_master_setup_item req;
    apb_master_access_item rsp;

    for(int i=0; i<100; i++) begin
    req = apb_master_setup_item::type_id::create("req");
    rsp = apb_master_access_item::type_id::create("rsp");

    //req.HTRANS.rand_mode(0);
    
 	    start_item(req);
	    //req.randomize();
	    assert(req.randomize() with {req.HBURST inside {3'b000, 3'b001}; req.HTRANS == 2'b10;});
	    finish_item(req);
            `uvm_info("Master_REQ_ITEM_SENT_TO_SLAVE", $sformatf("REQ_ITEM_%0d_SENT_TO_SLAVE is %s", i+1, req.convert2string()), UVM_LOW);

	    start_item(rsp);
	    finish_item(rsp);
            //`uvm_info("Master_RSP_ITEM_RCVD_FROM_SLAVE", $sformatf("RSP_ITEM_%0d_RCVD_FROM_SLAVE is %s", i+1, rsp.convert2string()), UVM_LOW);
    end

endtask : body
