class width_coverage_test extends spi_base_test;
    `uvm_component_utils(width_coverage_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); width_coverage_vseq seq; seq = width_coverage_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
