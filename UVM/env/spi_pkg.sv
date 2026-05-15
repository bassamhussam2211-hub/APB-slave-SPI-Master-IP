// =============================================================================
// File: env/spi_pkg.sv
// Description: Core configuration verification package aggregating sub-agents.
// =============================================================================
package spi_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Explicitly import verified underlying agent packages
    import apb_agent_pkg::*;
    import spi_agent_pkg::*;

    // Allocate required dynamic evaluation ports natively
    `uvm_analysis_imp_decl(_apb)
    `uvm_analysis_imp_decl(_spi)
    `uvm_analysis_imp_decl(_spi_cov)

    // Component source inclusions
    `include "ref_model.sv"
    `include "scoreboard.sv"
    `include "coverage.sv"
    `include "spi_reg_block.sv"
    `include "spi_env.sv"
endpackage