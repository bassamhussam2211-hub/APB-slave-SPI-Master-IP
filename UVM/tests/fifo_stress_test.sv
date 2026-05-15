class fifo_stress_test extends spi_base_test;
    `uvm_component_utils(fifo_stress_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); fifo_stress_vseq seq; seq = fifo_stress_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
