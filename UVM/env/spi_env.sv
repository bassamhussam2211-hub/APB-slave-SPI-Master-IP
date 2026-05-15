class spi_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(spi_virtual_sequencer)
    apb_sequencer apb_sqr;
    spi_sequencer spi_sqr;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class spi_env extends uvm_env;
    `uvm_component_utils(spi_env)
    virtual apb_if apb_vif;
    virtual spi_if spi_vif;
    apb_agent apb_ag;
    spi_agent spi_ag;
    spi_ref_model refm;
    spi_scoreboard sb;
    spi_coverage cov;
    spi_reg_block rb;
    spi_reg_adapter adapter;
    spi_virtual_sequencer vseqr;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) `uvm_fatal("NOVIF", "apb_vif missing")
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "spi_vif", spi_vif)) `uvm_fatal("NOVIF", "spi_vif missing")
        apb_ag = apb_agent::type_id::create("apb_ag", this);
        spi_ag = spi_agent::type_id::create("spi_ag", this);
        refm = spi_ref_model::type_id::create("refm", this);
        sb = spi_scoreboard::type_id::create("sb", this);
        cov = spi_coverage::type_id::create("cov", this);
        rb = spi_reg_block::type_id::create("rb", this);
        adapter = spi_reg_adapter::type_id::create("adapter");
        vseqr = spi_virtual_sequencer::type_id::create("vseqr", this);
        rb.build();
        uvm_config_db#(virtual apb_if)::set(this, "apb_ag", "vif", apb_vif);
        uvm_config_db#(virtual spi_if)::set(this, "spi_ag", "vif", spi_vif);
    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        apb_ag.mon.ap.connect(sb.apb_export);
        apb_ag.mon.ap.connect(cov.analysis_export);
        spi_ag.drv.ap.connect(sb.spi_export);
        spi_ag.drv.ap.connect(cov.spi_export);
        vseqr.apb_sqr = apb_ag.sqr;
        vseqr.spi_sqr = spi_ag.sqr;
        rb.default_map.set_sequencer(apb_ag.sqr, adapter);
        rb.default_map.set_auto_predict(1);
    endfunction
endclass
