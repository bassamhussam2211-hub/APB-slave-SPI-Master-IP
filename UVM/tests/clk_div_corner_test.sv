class clk_div_corner_test extends spi_base_test;
    `uvm_component_utils(clk_div_corner_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase); clk_div_corner_vseq seq; seq = clk_div_corner_vseq::type_id::create("seq"); run_vseq(phase, seq); endtask
endclass
