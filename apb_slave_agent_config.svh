import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_slave_agent_config extends uvm_object;

localparam string s_my_config_id = "apb_slave_agent_config";
localparam string s_no_config_id = "no config";
localparam string s_my_config_type_error_id = "config type error";

`uvm_object_utils(apb_slave_agent_config)


//This is given because the BFMs are not a part of the uvm component hierarchy and there is not way to discover them otherwise.
// We use this technique to finally connect the proxies to the BFM via this config object
virtual apb_slave_driver_bfm  slave_driver_bfm;
virtual apb_slave_monitor_bfm slave_monitor_bfm;

uvm_active_passive_enum active = UVM_ACTIVE;

logic[31:0] start_address[15:0];
logic[31:0] range[15:0];

int apb_index = 0;
extern static function apb_slave_agent_config get_config( uvm_component c );
extern function new(string name = "apb_slave_agent_config");

event wait_for_reset_event;
bit   wait_for_reset_called = 0;
 
task wait_for_reset();
  if (!wait_for_reset_called) begin
    wait_for_reset_called = 1;
    slave_monitor_bfm.wait_for_reset();
    -> wait_for_reset_event;
    wait_for_reset_called = 0;
  end else begin
    @(wait_for_reset_event);
  end
endtask : wait_for_reset

endclass: apb_slave_agent_config

function apb_slave_agent_config::new(string name = "apb_slave_agent_config");
  super.new(name);
endfunction

function apb_slave_agent_config apb_slave_agent_config::get_config( uvm_component c );
  uvm_object o;
  apb_slave_agent_config t;

  if(! uvm_config_db #(uvm_object)::get(null, "my_env", s_my_config_id, o)) begin
    c.uvm_report_error( s_no_config_id ,
                        $sformatf("no config associated with %s" ,
                                  s_my_config_id ) ,
                        UVM_NONE , `uvm_file , `uvm_line  );
    return null;
  end

  if( !$cast( t , o ) ) begin
    c.uvm_report_error( s_my_config_type_error_id ,
                        $sformatf("config %s associated with config %s is not of type my_config" ,
                                   o.sprint() , s_my_config_id ) ,
                        UVM_NONE , `uvm_file , `uvm_line );
  end

  return t;
endfunction
