import uvm_pkg::*;
import apb_master_agent_pkg::*;
`include "uvm_macros.svh"

interface apb_master_monitor_bfm(
    input HCLK,
    input HRESETn,
    input[31:0] HADDR,
    input[2:0] HBURST,
    input[2:0] HSIZE,
    input[1:0] HTRANS,
    input[31:0] HWDATA,
    input HWRITE,
    input[31:0] HRDATA,
    input HREADY,
    input HRESP
);

import uvm_pkg::uvm_sequence_item;
//import apb_master_agent_pkg::*;

apb_master_monitor proxy;

task run();
    uvm_sequence_item item, cloned_item;
    apb_master_access_item rsp, cloned_rsp;
    apb_master_setup_item req, cloned_req;

    req = apb_master_setup_item::type_id::create("req");
    rsp = apb_master_access_item::type_id::create("rsp");

    forever begin
        @(posedge HCLK);
        req.HADDR = HADDR;
        req.HBURST = HBURST;
        req.HSIZE = HSIZE;
        req.HTRANS = HTRANS;
        req.HWDATA = HWDATA;
        req.HWRITE = HWRITE;
        $cast(cloned_req, req.clone());
        proxy.notify_setup(cloned_req);

        if(HREADY) begin
            rsp.HRESP = HRESP;
            if(!HWRITE) rsp.HRDATA = HRDATA;
            $cast(cloned_rsp, rsp.clone());
            proxy.notify_access(cloned_rsp);
        end
    end
endtask : run

task wait_for_reset();
    wait (HRESETn);
endtask : wait_for_reset

endinterface : apb_master_monitor_bfm


