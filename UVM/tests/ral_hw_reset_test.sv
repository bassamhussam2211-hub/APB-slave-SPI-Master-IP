class ral_hw_reset_test extends uvm_test;
    `uvm_component_utils(ral_hw_reset_test)
    spi_env env;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
    endfunction
    task run_phase(uvm_phase phase);
        uvm_reg_hw_reset_seq seq;
        uvm_status_e status;
        uvm_reg_data_t value;
        spi_base_vseq rst;
        bit [31:0] bd;
        phase.raise_objection(this);
        rst = spi_base_vseq::type_id::create("rst");
        rst.env = env;
        rst.hard_reset();
        seq = uvm_reg_hw_reset_seq::type_id::create("seq");
        seq.model = env.rb;
        seq.start(null);
        env.rb.CTRL.peek(status, value);
        if (status != UVM_IS_OK || value[7:0] != 0) begin
            $display("[SCOREBOARD_ERROR] ral_backdoor_ctrl expected=0 observed=0x%08h", value);
            `uvm_error("RAL", "CTRL backdoor mismatch")
        end
        if (!uvm_hdl_read("tb_top.u_wrap.u_dut.u_regfile.int_stat", bd) || bd[4:0] != 0) begin
            $display("[SCOREBOARD_ERROR] ral_hdl_int_stat expected=0 observed=0x%08h", bd);
            `uvm_error("RAL", "INT_STAT HDL backdoor mismatch")
        end
        phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
        int errs;
        errs = uvm_report_server::get_server().get_severity_count(UVM_ERROR);
        if (errs == 0) $display("[TEST_PASSED] ral_hw_reset_test");
        else $display("[TEST_FAILED] ral_hw_reset_test errors=%0d", errs);
    endfunction
endclass
