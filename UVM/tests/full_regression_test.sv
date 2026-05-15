`ifndef FULL_REGRESSION_TEST_SV
`define FULL_REGRESSION_TEST_SV

class full_regression_test extends spi_base_test;

    `uvm_component_utils(full_regression_test)

    function new(string name = "full_regression_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        sanity_seq              seq1;
        reg_access_seq          seq2;
        mode_coverage_seq       seq3;
        width_coverage_seq      seq4;
        fifo_stress_seq         seq5;
        interrupt_seq           seq6;
        clk_div_corner_seq      seq7;
        loopback_seq            seq8;
        delay_transfer_seq      seq9;
        error_injection_seq     seq10;

        phase.raise_objection(this);

        `uvm_info(get_type_name(), "Starting full_regression_test", UVM_LOW)

        seq1 = sanity_seq::type_id::create("seq1");
        seq1.start(env.vseqr);

        seq2 = reg_access_seq::type_id::create("seq2");
        seq2.start(env.vseqr);

        seq3 = mode_coverage_seq::type_id::create("seq3");
        seq3.start(env.vseqr);

        seq4 = width_coverage_seq::type_id::create("seq4");
        seq4.start(env.vseqr);

        seq5 = fifo_stress_seq::type_id::create("seq5");
        seq5.start(env.vseqr);

        seq6 = interrupt_seq::type_id::create("seq6");
        seq6.start(env.vseqr);

        seq7 = clk_div_corner_seq::type_id::create("seq7");
        seq7.start(env.vseqr);

        seq8 = loopback_seq::type_id::create("seq8");
        seq8.start(env.vseqr);

        seq9 = delay_transfer_seq::type_id::create("seq9");
        seq9.start(env.vseqr);

        seq10 = error_injection_seq::type_id::create("seq10");
        seq10.start(env.vseqr);

        `uvm_info(get_type_name(), "Finished full_regression_test", UVM_LOW)

        phase.drop_objection(this);

    endtask

endclass

`endif