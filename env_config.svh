import uvm_pkg::*;
import apb_master_agent_pkg::apb_master_agent_config;
import apb_slave_agent_pkg::apb_slave_agent_config;
`include "uvm_macros.svh"

class env_config extends uvm_object;
    `uvm_object_utils(env_config);

    apb_slave_agent_config slave_agt_cfg;
    apb_master_agent_config master_agt_cfg;

    extern static function env_config get_config(uvm_component c);
    extern function new(string name = "env_config");
endclass : env_config

function env_config::new(string name = "env_config");
    super.new(name);
    slave_agt_cfg = apb_slave_agent_config::type_id::create("apb_slave_agent_config");
    master_agt_cfg = apb_master_agent_config::type_id::create("apb_master_agent_config");
endfunction

function env_config env_config::get_config(uvm_component c);
    uvm_object o;
    env_config t;

    if(!uvm_config_db #(uvm_object)::get(null,"my_env","env_config", o)) begin
        c.uvm_report_error("env_config", "no config associated with env_config", UVM_NONE, `uvm_file, `uvm_line);
        return null;
    end

    if(!$cast(t,o)) begin
        c.uvm_report_error("config type error", "config associated with config env_config is not of type my_config", UVM_NONE, `uvm_file, `uvm_line);
    end

    return t;
endfunction : get_config
