class sanity_test extends spi_base_test;
    `uvm_component_utils(sanity_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        set_type_override_by_type(apb_item::get_type(), apb_idle_item::get_type());
        super.build_phase(phase);
    endfunction
    task run_phase(uvm_phase phase);
        sanity_vseq seq;
        seq = sanity_vseq::type_id::create("seq");
        run_vseq(phase, seq);
    endtask
endclass
