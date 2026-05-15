`ifndef SPI_SVA_SV
`define SPI_SVA_SV
`timescale 1ns/1ps

module spi_regfile_sva(
    input wire PCLK,
    input wire PRESETn,
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [7:0] PADDR,
    input wire [31:0] PWDATA,
    input wire [31:0] PRDATA,
    input wire PREADY,
    input wire PSLVERR,
    input wire [4:0] int_stat,
    input wire [4:0] int_en,
    input wire IRQ,
    input wire [3:0] SS_n,
    input wire [3:0] ss_en,
    input wire [3:0] ss_val,
    input wire tx_push_valid,
    input wire tx_push_dropped,
    input wire tx_full_w,
    input wire rx_push_valid,
    input wire rx_full_w,
    input wire [3:0] tx_count,
    input wire tx_pop
);
    a_penable_psel: assert property(@(posedge PCLK) disable iff(!PRESETn) PENABLE |-> PSEL)
    else $error("[ASSERTION_ERROR] a_penable_psel");
    a_setup_access_stable: assert property(@(posedge PCLK) disable iff(!PRESETn) (PSEL && !PENABLE) |=> (PSEL && PENABLE && PADDR == $past(PADDR) && PWRITE == $past(PWRITE) && (!PWRITE || PWDATA == $past(PWDATA))))
    else $error("[ASSERTION_ERROR] a_setup_access_stable");
    a_zero_wait: assert property(@(posedge PCLK) disable iff(!PRESETn) (PSEL && PENABLE) |-> (PREADY && !PSLVERR))
    else $error("[ASSERTION_ERROR] a_zero_wait");
    a_irq_equation: assert property(@(posedge PCLK) disable iff(!PRESETn) IRQ == |(int_stat & int_en))
    else $error("[ASSERTION_ERROR] a_irq_equation");
    a_ss_equation: assert property(@(posedge PCLK) disable iff(!PRESETn) SS_n == (~ss_en | ss_val))
    else $error("[ASSERTION_ERROR] a_ss_equation");
    a_tx_overflow_detect: assert property(@(posedge PCLK) disable iff(!PRESETn) (tx_push_valid && tx_full_w) |-> tx_push_dropped)
    else $error("[ASSERTION_ERROR] a_tx_overflow_detect");
    a_rx_overflow_sticky: assert property(@(posedge PCLK) disable iff(!PRESETn) (rx_push_valid && rx_full_w) |=> int_stat[3])
    else $error("[ASSERTION_ERROR] a_rx_overflow_sticky");
    a_tx_empty_sticky: assert property(@(posedge PCLK) disable iff(!PRESETn) (tx_pop && tx_count == 4'd1) |=> int_stat[0])
    else $error("[ASSERTION_ERROR] a_tx_empty_sticky");
    a_reserved_read_zero: assert property(@(posedge PCLK) disable iff(!PRESETn) (PSEL && PENABLE && !PWRITE && PADDR >= 8'h24) |-> PRDATA == 32'h0)
    else $error("[ASSERTION_ERROR] a_reserved_read_zero");
endmodule

module spi_core_sva(
    input wire PCLK,
    input wire PRESETn,
    input wire cfg_en,
    input wire cfg_mstr,
    input wire [1:0] cfg_mode,
    input wire [1:0] cfg_width,
    input wire [15:0] cfg_clk_div,
    input wire tx_empty,
    input wire [3:0] ss_n_drive,
    input wire tx_pop,
    input wire rx_push_valid,
    input wire transfer_done_pulse,
    input wire busy,
    input wire SCLK,
    input wire MOSI,
    input wire [1:0] state,
    input wire [1:0] xfer_mode,
    input wire xfer_lsb_first,
    input wire [1:0] xfer_width,
    input wire [15:0] xfer_div,
    input wire [16:0] sclk_cnt
);
    function automatic bit is_sample_edge(input bit old_sclk, input bit new_sclk, input bit [1:0] mode);
        bit leading;
        leading = (old_sclk == mode[1]) && (new_sclk != mode[1]);
        is_sample_edge = (mode[0] == 1'b0) ? leading : !leading;
    endfunction
    a_idle_sclk: assert property(@(posedge PCLK) disable iff(!PRESETn) (!busy && !$past(busy) && cfg_mode == $past(cfg_mode)) |-> SCLK == cfg_mode[1])
    else $error("[ASSERTION_ERROR] a_idle_sclk");
    a_start_preconditions: assert property(@(posedge PCLK) disable iff(!PRESETn) tx_pop |-> (cfg_en && cfg_mstr && !tx_empty && ss_n_drive != 4'hf))
    else $error("[ASSERTION_ERROR] a_start_preconditions");
    a_busy_ss_asserted: assert property(@(posedge PCLK) disable iff(!PRESETn) busy |-> ss_n_drive != 4'hf)
    else $error("[ASSERTION_ERROR] a_busy_ss_asserted");
    a_config_latched: assert property(@(posedge PCLK) disable iff(!PRESETn) (busy && $past(busy)) |-> ($stable(xfer_mode) && $stable(xfer_lsb_first) && $stable(xfer_width) && $stable(xfer_div)))
    else $error("[ASSERTION_ERROR] a_config_latched");
    a_rx_push_done: assert property(@(posedge PCLK) disable iff(!PRESETn) rx_push_valid |-> transfer_done_pulse)
    else $error("[ASSERTION_ERROR] a_rx_push_done");
    a_sclk_terminal_count: assert property(@(posedge PCLK) disable iff(!PRESETn) (busy && SCLK != $past(SCLK)) |-> ($past(sclk_cnt) == {1'b0, $past(xfer_div)}))
    else $error("[ASSERTION_ERROR] a_sclk_terminal_count");
    a_mosi_sample_stable: assert property(@(posedge PCLK) disable iff(!PRESETn) (state == 2'd1 && SCLK != $past(SCLK) && is_sample_edge($past(SCLK), SCLK, xfer_mode)) |-> MOSI == $past(MOSI))
    else $error("[ASSERTION_ERROR] a_mosi_sample_stable");
endmodule

`endif
