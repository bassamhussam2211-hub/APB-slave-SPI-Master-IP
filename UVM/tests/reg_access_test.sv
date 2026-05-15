class reg_access_test extends spi_base_test;
    `uvm_component_utils(reg_access_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); reg_access_vseq seq; seq = reg_access_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
