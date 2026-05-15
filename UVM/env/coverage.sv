class spi_coverage extends uvm_subscriber #(apb_item);
    `uvm_component_utils(spi_coverage)
    uvm_analysis_imp_spi_cov #(spi_item, spi_coverage) spi_export;
    bit [1:0] cv_mode;
    bit cv_lsb;
    bit [1:0] cv_width;
    bit [15:0] cv_div;
    bit [7:0] cv_addr;
    bit cv_write;
    bit [4:0] cv_irq;
    bit [3:0] cv_fifo_level;
    bit cv_loopback;
    covergroup cg_cfg;
        option.per_instance = 1;
        cp_mode: coverpoint cv_mode { bins modes[] = {[0:3]}; }
        cp_lsb: coverpoint cv_lsb { bins msb = {0}; bins lsb = {1}; }
        cp_width: coverpoint cv_width { bins w8 = {0}; bins w16 = {1}; bins w32 = {2}; bins illegal = {3}; }
        cx_cfg: cross cp_mode, cp_lsb, cp_width;
    endgroup
    covergroup cg_apb;
        option.per_instance = 1;
        cp_addr: coverpoint cv_addr { bins regs[] = {8'h00,8'h04,8'h08,8'h0c,8'h10,8'h14,8'h18,8'h1c,8'h20}; bins reserved = {[8'h24:8'hff]}; }
        cp_wr: coverpoint cv_write { bins rd = {0}; bins wr = {1}; }
        cx_apb: cross cp_addr, cp_wr;
    endgroup
    covergroup cg_misc;
        option.per_instance = 1;
        cp_div: coverpoint cv_div { bins zero = {0}; bins one = {1}; bins two = {2}; bins three = {3}; bins div_medium = {[4:255]}; bins div_large = {[1024:65535]}; }
        cp_irq: coverpoint cv_irq { bins tx_empty = {1}; bins rx_full = {2}; bins tx_ovf = {4}; bins rx_ovf = {8}; bins done = {16}; bins none = {0}; }
        cp_fifo: coverpoint cv_fifo_level { bins empty = {0}; bins one = {1}; bins mid = {4}; bins near_full = {7}; bins full = {8}; }
        cp_loop: coverpoint cv_loopback { bins off = {0}; bins on = {1}; }
    endgroup
    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_export = new("spi_export", this);
        cg_cfg = new();
        cg_apb = new();
        cg_misc = new();
    endfunction
    function void write(apb_item t);
        cv_addr = t.addr;
        cv_write = (t.kind == APB_WRITE);
        cg_apb.sample();
        if (t.addr == 8'h00 && t.kind == APB_WRITE) begin
            cv_mode = t.data[3:2];
            cv_lsb = t.data[4];
            cv_loopback = t.data[5];
            cv_width = t.data[7:6];
            cg_cfg.sample();
            cg_misc.sample();
        end
        if (t.addr == 8'h10 && t.kind == APB_WRITE) begin
            cv_div = t.data[15:0];
            cg_misc.sample();
        end
        if (t.addr == 8'h1c && t.kind == APB_READ) begin
            cv_irq = t.rdata[4:0];
            cg_misc.sample();
        end
    endfunction
    function void write_spi_cov(spi_item t);
        if (t.kind == SPI_MISO) begin
            cv_mode = t.mode;
            cv_width = t.width;
            cv_lsb = t.lsb_first;
            cg_cfg.sample();
        end
    endfunction
    function void sample_fifo(int level);
        cv_fifo_level = level[3:0];
        cg_misc.sample();
    endfunction
endclass
