`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import apb_agent_pkg::*;
    import spi_agent_pkg::*;
    import spi_pkg::*;
    import spi_seq_pkg::*;
    import spi_test_pkg::*;

    bit PCLK = 1'b0;
    bit PRESETn = 1'b0;
    always #5 PCLK = ~PCLK;

    apb_if apb(.pclk(PCLK), .presetn(PRESETn));
    spi_if spi(.pclk(PCLK));
    dut_wrapper u_wrap(.apb(apb), .spi(spi));

    bind u_wrap.u_dut.u_regfile spi_regfile_sva u_regfile_sva(
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .int_stat(int_stat),
        .int_en(int_en),
        .IRQ(IRQ),
        .SS_n(SS_n),
        .ss_en(ss_en),
        .ss_val(ss_val),
        .tx_push_valid(tx_push_valid),
        .tx_push_dropped(tx_push_dropped),
        .tx_full_w(tx_full_w),
        .rx_push_valid(rx_push_valid),
        .rx_full_w(rx_full_w),
        .tx_count(tx_count),
        .tx_pop(tx_pop)
    );

    bind u_wrap.u_dut.u_core spi_core_sva u_core_sva(
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .cfg_en(cfg_en),
        .cfg_mstr(cfg_mstr),
        .cfg_mode(cfg_mode),
        .cfg_width(cfg_width),
        .cfg_clk_div(cfg_clk_div),
        .tx_empty(tx_empty),
        .ss_n_drive(ss_n_drive),
        .tx_pop(tx_pop),
        .rx_push_valid(rx_push_valid),
        .transfer_done_pulse(transfer_done_pulse),
        .busy(busy),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .state(state),
        .xfer_mode(xfer_mode),
        .xfer_lsb_first(xfer_lsb_first),
        .xfer_width(xfer_width),
        .xfer_div(xfer_div),
        .sclk_cnt(sclk_cnt)
    );

    initial begin
        apb.psel = 0;
        apb.penable = 0;
        apb.pwrite = 0;
        apb.paddr = 0;
        apb.pwdata = 0;
        spi.miso = 0;
    end

    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb);
        uvm_config_db#(virtual apb_if)::set(null, "*", "vif", apb);
        uvm_config_db#(virtual spi_if)::set(null, "*", "spi_vif", spi);
        uvm_config_db#(virtual spi_if)::set(null, "*", "vif", spi);
        run_test("sanity_test");
    end

    initial begin
        #200_000_000;
        $display("[TEST_FAILED] timeout errors=1");
        $finish;
    end
endmodule
