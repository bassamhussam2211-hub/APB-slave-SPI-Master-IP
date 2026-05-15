class config_latch_test extends spi_base_test;
    `uvm_component_utils(config_latch_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); config_latch_vseq seq; seq = config_latch_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
