class reset_flush_test extends spi_base_test;
    `uvm_component_utils(reset_flush_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); reset_flush_vseq seq; seq = reset_flush_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
