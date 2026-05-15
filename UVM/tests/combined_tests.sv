// =============================================================================
// File: tests/combined_tests.sv
// Description: Consolidated, high-throughput test classes grouping virtual 
//              sequences sequentially to slash OS simulator load overhead.
// Specification Target: SPI Master Controller Contract Rev 1.2
// =============================================================================
`ifndef COMBINED_TESTS_SV
`define COMBINED_TESTS_SV

// ---- Suite 1: Core Configuration, Protocols, and Matrix Sweeps -------------
class spi_coverage_reg_test extends spi_base_test;
    `uvm_component_utils(spi_coverage_reg_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        sanity_vseq         seq1;
        reg_access_vseq     seq2;
        apb_protocol_vseq   seq3;
        mode_coverage_vseq  seq4;
        width_coverage_vseq seq5;

        phase.raise_objection(this);

        seq1 = sanity_vseq::type_id::create("seq1"); seq1.env = env; seq1.start(env.vseqr);
        seq2 = reg_access_vseq::type_id::create("seq2"); seq2.env = env; seq2.start(env.vseqr);
        seq3 = apb_protocol_vseq::type_id::create("seq3"); seq3.env = env; seq3.start(env.vseqr);
        seq4 = mode_coverage_vseq::type_id::create("seq4"); seq4.env = env; seq4.start(env.vseqr);
        seq5 = width_coverage_vseq::type_id::create("seq5"); seq5.env = env; seq5.start(env.vseqr);

        phase.drop_objection(this);
    endtask
endclass

// ---- Suite 2: FIFO Saturation, Sticky Interrupts, and Stress Validation ----
class spi_stress_interrupt_test extends spi_base_test;
    `uvm_component_utils(spi_stress_interrupt_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        fifo_stress_vseq       seq1;
        interrupt_vseq         seq2;
        error_injection_vseq   seq3;
        reset_flush_vseq       seq4;
        randomized_stress_vseq seq5;

        phase.raise_objection(this);

        seq1 = fifo_stress_vseq::type_id::create("seq1"); seq1.env = env; seq1.start(env.vseqr);
        seq2 = interrupt_vseq::type_id::create("seq2"); seq2.env = env; seq2.start(env.vseqr);
        seq3 = error_injection_vseq::type_id::create("seq3"); seq3.env = env; seq3.start(env.vseqr);
        seq4 = reset_flush_vseq::type_id::create("seq4"); seq4.env = env; seq4.start(env.vseqr);
        seq5 = randomized_stress_vseq::type_id::create("seq5"); seq5.env = env; seq5.start(env.vseqr);

        phase.drop_objection(this);
    endtask
endclass

// ---- Suite 3: Clock Scalers, Line Delays, Loopback, and Latching -----------
class spi_timing_features_test extends spi_base_test;
    `uvm_component_utils(spi_timing_features_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        clk_div_corner_vseq seq1;
        loopback_vseq       seq2;
        delay_transfer_vseq seq3;
        ss_ctrl_vseq        seq4;
        config_latch_vseq   seq5;

        phase.raise_objection(this);

        seq1 = clk_div_corner_vseq::type_id::create("seq1"); seq1.env = env; seq1.start(env.vseqr);
        seq2 = loopback_vseq::type_id::create("seq2"); seq2.env = env; seq2.start(env.vseqr);
        seq3 = delay_transfer_vseq::type_id::create("seq3"); seq3.env = env; seq3.start(env.vseqr);
        seq4 = ss_ctrl_vseq::type_id::create("seq4"); seq4.env = env; seq4.start(env.vseqr);
        seq5 = config_latch_vseq::type_id::create("seq5"); seq5.env = env; seq5.start(env.vseqr);

        phase.drop_objection(this);
    endtask
endclass

`endif