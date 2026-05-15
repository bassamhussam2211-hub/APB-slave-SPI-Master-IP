package spi_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import apb_agent_pkg::*;
    import spi_agent_pkg::*;
    import spi_pkg::*;
    import spi_seq_pkg::*;
    
    // Base and legacy granular definitions
    `include "spi_base_test.sv"
    `include "sanity_test.sv"
    `include "reg_access_test.sv"
    `include "mode_coverage_test.sv"
    `include "width_coverage_test.sv"
    `include "fifo_stress_test.sv"
    `include "interrupt_test.sv"
    `include "clk_div_corner_test.sv"
    `include "loopback_test.sv"
    `include "delay_transfer_test.sv"
    `include "error_injection_test.sv"
    `include "reset_flush_test.sv"
    `include "ss_ctrl_test.sv"
    `include "config_latch_test.sv"
    `include "apb_protocol_test.sv"
    `include "randomized_stress_test.sv"
    `include "ral_hw_reset_test.sv"
    
    // Export consolidated fast regression suites
    `include "combined_tests.sv"
endpackage