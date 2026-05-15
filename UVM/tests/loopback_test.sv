class loopback_test extends spi_base_test;
    `uvm_component_utils(loopback_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); loopback_vseq seq; seq = loopback_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
