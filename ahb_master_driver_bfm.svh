import uvm_pkg::*;
import apb_master_agent_pkg::*;
`include "uvm_macros.svh"

interface apb_master_driver_bfm(
    input HCLK,
    output logic HRESETn,
    output logic[31:0] HADDR, //param this
    output logic[2:0] HBURST,
    output logic[2:0] HSIZE,
    output logic[1:0] HTRANS,
    output logic[31:0] HWDATA, //parameterize this
    output logic HWRITE,
    input [31:0] HRDATA, //param this (comes from the MUX connected to all the slaves)
    input HREADY,
    input HRESP);

//   protocol_state_controller master_driver_state_controller = new("master_driver_state_controller");
   
   
    //import apb_master_agent_pkg::*;
    //`include "apb_master_seq_item.svh"

    //Not designing it for a multi master system, therefore there is no need for multiple
    //BFMs and hence no need to logically associate a BFM with the proxy

    task reset();
        @(posedge HCLK);
        HRESETn <= 1'b0;
    endtask : reset

    task no_reset();
        @(posedge HCLK);
        HRESETn <= 1'b1;
    endtask : no_reset

    task setup_phase(apb_master_setup_item req);
       //master_driver_state_controller.req_item_action(this, req);
       @(posedge HCLK);
       while(!HREADY == 1) begin
	  @(posedge HCLK);
       end
       //#2ns;
       HADDR <= req.HADDR;
       HWDATA <= req.HWDATA;
       HWRITE <= req.HWRITE;
       HBURST <= req.HBURST;
       HSIZE <= req.HSIZE;
       HTRANS <= req.HTRANS;
    endtask : setup_phase

    task access_phase(apb_master_access_item rsp);
       //master_driver_state_controller.rsp_item_action(this, rsp);
       @(posedge HCLK);
       while(!HREADY == 1) begin
	  @(posedge HCLK);
       end
       rsp.HRDATA = HRDATA;
       rsp.HRESP = HRESP;
       rsp.HREADY = HREADY;
    endtask : access_phase

endinterface : apb_master_driver_bfm
