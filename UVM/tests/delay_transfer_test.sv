class delay_transfer_test extends spi_base_test;
    `uvm_component_utils(delay_transfer_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); delay_transfer_vseq seq; seq = delay_transfer_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
