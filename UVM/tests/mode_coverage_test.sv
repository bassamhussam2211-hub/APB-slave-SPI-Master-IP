class mode_coverage_test extends spi_base_test;
    `uvm_component_utils(mode_coverage_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); mode_coverage_vseq seq; seq = mode_coverage_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
