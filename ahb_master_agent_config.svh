import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_master_agent_config extends uvm_object;
    `uvm_object_utils(apb_master_agent_config);

    //This is given because the BFMs are not a part of the uvm component hierarchy and there is not way to discover them otherwise.
    // We use this technique to finally connect the proxies to the BFM via this config object
    virtual apb_master_driver_bfm master_driver_bfm;
    virtual apb_master_monitor_bfm master_monitor_bfm;

    uvm_active_passive_enum active = UVM_ACTIVE;

    extern static function apb_master_agent_config get_config (uvm_component c);
    extern function new(string name = "apb_master_agent_config");

endclass : apb_master_agent_config

function apb_master_agent_config::new(string name = "apb_master_agent_config");
    super.new(name);
endfunction

function apb_master_agent_config apb_master_agent_config::get_config(uvm_component c);
    uvm_object o;
    apb_master_agent_config t;

    if(!uvm_config_db #(uvm_object)::get(null, "my_env", "apb_master_agent_config", o)) begin
        c.uvm_report_error("no config", "no config associated with apb_master_agent_config", UVM_NONE, `uvm_file, `uvm_line);
        return null;
    end

    if(!$cast(t, o)) begin
        c.uvm_report_error("config type error", $sformatf("config %s associated with config apb_master_agent_config is not of type my_config", o.sprint()), UVM_NONE, `uvm_file, `uvm_line);
    end

    return t;
endfunction
