import uvm_pkg::*;
import env_pkg::*;
`include "uvm_macros.svh"

class base_test extends uvm_test;
    `uvm_component_utils(base_test);

    env my_env;
    env_config my_env_cfg;    

    extern function new(string name = "base_test", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    // at end_of_elaboration, print topology and factory state to verify 
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
    //extern function report_phase(uvm_phase phase);

    extern function void set_slave_agent_config();
    extern function void set_master_agent_config();
    extern function void get_slave_agent_bfms();
    extern function void get_master_agent_bfms();
    extern function void upload_config_to_DB();


endclass : base_test

function base_test::new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

function void base_test::build_phase(uvm_phase phase);
    my_env_cfg = env_config::type_id::create("my_env_config");
    set_slave_agent_config();
    set_master_agent_config();
    upload_config_to_DB();
    my_env = env::type_id::create("my_env", this);
endfunction : build_phase

function void base_test::set_slave_agent_config();
    my_env_cfg.slave_agt_cfg.active = UVM_ACTIVE;
    get_slave_agent_bfms();
endfunction : set_slave_agent_config

function void base_test::set_master_agent_config();
    my_env_cfg.master_agt_cfg.active = UVM_ACTIVE;
    get_master_agent_bfms();
endfunction : set_master_agent_config

function void base_test::get_slave_agent_bfms();
    if(!uvm_config_db #(virtual apb_slave_monitor_bfm)::get(this, "", "apb_slave_monitor_bfm", my_env_cfg.slave_agt_cfg.slave_monitor_bfm))
        `uvm_error("Monitor_BFM_Fetch_ERROR", "Could not fetch monitor BFM for slave");
    if(!uvm_config_db #(virtual apb_slave_driver_bfm)::get(this, "", "apb_slave_driver_bfm", my_env_cfg.slave_agt_cfg.slave_driver_bfm))
        `uvm_error("Driver_BFM_Fetch_ERROR", "Could not fetch driver BFM for slave");
endfunction : get_slave_agent_bfms

function void base_test::get_master_agent_bfms();
    if(!uvm_config_db #(virtual apb_master_monitor_bfm)::get(this, "", "apb_master_monitor_bfm", my_env_cfg.master_agt_cfg.master_monitor_bfm))
        `uvm_error("Monitor_BFM_Fetch_ERROR", "Could not fetch monitor BFM for master");

    if(!uvm_config_db #(virtual apb_master_driver_bfm)::get(this, "", "apb_master_driver_bfm", my_env_cfg.master_agt_cfg.master_driver_bfm))
        `uvm_error("Driver_BFM_Fetch_ERROR", "Could not fetch driver BFM for master");
endfunction : get_master_agent_bfms

function void base_test::upload_config_to_DB();
    uvm_config_db #(uvm_object)::set(null, "my_env", "env_config", my_env_cfg);
//        `uvm_error("env_config_set_ERROR", "Could not upload env config object to config_DB");
    uvm_config_db #(uvm_object)::set(null, "my_env", "apb_slave_agent_config", my_env_cfg.slave_agt_cfg);
//        `uvm_error("slave_agent_config_set_ERROR", "Could not upload the slave agent config object to config_DB");
    uvm_config_db #(uvm_object)::set(null, "my_env", "apb_master_agent_config", my_env_cfg.master_agt_cfg);
//        `uvm_error("master_agent_config_set_ERROR", "Could not upload the master agent config object to config_DB");
endfunction : upload_config_to_DB

task base_test::run_phase(uvm_phase phase);
    //apb_master_single_trans_sequence single_trans_seq = apb_master_single_trans_sequence::type_id::create("single_trans_seq");
    apb_master_complete_sequence master_complete_seq = apb_master_complete_sequence::type_id::create("master_complete_seq");
    apb_slave_complete_sequence slave_complete_seq = apb_slave_complete_sequence::type_id::create("slave_complete_seq");

    phase.raise_objection(this);
    fork
        //single_trans_seq.start(my_env.master_agent.master_sequencer);
        master_complete_seq.start(my_env.master_agent.master_sequencer);
        slave_complete_seq.start(my_env.slave_agent.slave_sequencer);
//        #10000;
    join_any
    phase.drop_objection(this);

endtask : run_phase

