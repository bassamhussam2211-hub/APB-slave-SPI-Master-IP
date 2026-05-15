class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)
    spi_env env;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
    endfunction
    task run_vseq(uvm_phase phase, spi_base_vseq seq);
        phase.raise_objection(this);
        seq.env = env;
        seq.start(env.vseqr);
        phase.drop_objection(this);
    endtask
    function void report_phase(uvm_phase phase);
        int errs;
        errs = uvm_report_server::get_server().get_severity_count(UVM_ERROR) + env.sb.error_count;
        if (errs == 0) $display("[TEST_PASSED] %s", get_type_name());
        else $display("[TEST_FAILED] %s errors=%0d", get_type_name(), errs);
    endfunction
endclass
