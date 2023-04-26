import uvm_pkg::*;
import apb_slave_agent_pkg::*;
`include "uvm_macros.svh"

interface apb_slave_driver_bfm (
  input HCLK,
  input HRESETn,
  input [31:0] HADDR,
  output logic[31:0] HRDATA,
  input logic[2:0] HBURST,
  input[31:0] HWDATA,
  input[31:0] HSEL,
  input HWRITE,
  input [1:0] HTRANS,
  input [2:0] HSIZE,
  output logic HRESP,
  output logic HREADYOUT
  ); 
  
  int apb_index = 0;
  
  function void set_apb_index(int index);
    apb_index = index;
  endfunction : set_apb_index

  task reset();
    while (!HRESETn) begin
      HREADYOUT <= 1'b0;
      @(posedge HCLK);
    end
  endtask : reset

  task setup_phase(apb_slave_setup_item req);
    @(posedge HCLK);
    while (HSEL[apb_index] != 1'b1) @(posedge HCLK);
    req.HADDR = HADDR;
    req.HWRITE = HWRITE;
    req.HBURST = HBURST;
    req.HSIZE = HSIZE;
    req.HTRANS = HTRANS;
    if (req.HWRITE) begin
        req.HWDATA = HWDATA;
    end
    else begin 
        req.HWDATA = 0;
    end
    HREADYOUT <= 1'b0;
  endtask : setup_phase

  task access_phase(apb_slave_access_item rsp);
    @(posedge HCLK);
    while (HSEL[apb_index] != 1'b1) @(posedge HCLK);
    if (!rsp.HWRITE) begin 
	HRDATA <= rsp.HRDATA;
    end
    HREADYOUT <= rsp.HREADY;
    HRESP <= rsp.HRESP; 
    //HWRITE <= rsp.HWRITE;
    //HSIZE <= rsp.HSIZE;
    
  endtask : access_phase //Check point 4 for clarification from points to remember.md in GenNotes Folder

endinterface: apb_slave_driver_bfm
