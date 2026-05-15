class error_injection_test extends spi_base_test;
    `uvm_component_utils(error_injection_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); error_injection_vseq seq; seq = error_injection_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
