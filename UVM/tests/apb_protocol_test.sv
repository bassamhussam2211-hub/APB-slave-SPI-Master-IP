class apb_protocol_test extends spi_base_test;
    `uvm_component_utils(apb_protocol_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); apb_protocol_vseq seq; seq = apb_protocol_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
