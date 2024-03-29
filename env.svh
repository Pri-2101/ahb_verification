import uvm_pkg::*;
import env_pkg::*;
import apb_slave_agent_pkg::apb_slave_agent;
import apb_master_agent_pkg::apb_master_agent;
`include "uvm_macros.svh"

class env extends uvm_env;
    `uvm_component_utils(env)

    apb_master_agent master_agent;
    apb_slave_agent slave_agent;
    coverage_collector_for_master cvg_col_4_master;

    env_config env_cfg;

    extern function new(string name = "env", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass: env

function env::new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void env::build_phase(uvm_phase phase);
    env_cfg = env_config::get_config(this);

    if(env_cfg.instantiate_coverage_collector_for_master) begin
        cvg_col_4_master = coverage_collector_for_master::type_id::create("cvg_col_4_master", this);
    end
    master_agent = apb_master_agent::type_id::create("master_agent", this);
    slave_agent = apb_slave_agent::type_id::create("slave agent", this);
endfunction : build_phase

function void env::connect_phase(uvm_phase phase);
    if(env_cfg.instantiate_coverage_collector_for_master) begin
        slave_agent.setup_ap.connect(cvg_col_4_master.analysis_export);
    end
endfunction : connect_phase


