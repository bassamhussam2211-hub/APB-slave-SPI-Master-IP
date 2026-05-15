class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)
    uvm_analysis_imp_apb #(apb_item, spi_scoreboard) apb_export;
    uvm_analysis_imp_spi #(spi_item, spi_scoreboard) spi_export;
    int error_count;
    int check_count;
    bit [31:0] spi_mosi_q[$];
    apb_item apb_q[$];
    function new(string name, uvm_component parent);
        super.new(name, parent);
        apb_export = new("apb_export", this);
        spi_export = new("spi_export", this);
    endfunction
    function void write_apb(apb_item t);
        apb_item c;
        $cast(c, t.clone());
        apb_q.push_back(c);
        if (!t.pready) checker_fail("apb_pready", "PREADY low in access");
        if (t.pslverr) checker_fail("apb_pslverr", "PSLVERR asserted");
    endfunction
    function void write_spi(spi_item t);
        if (t.kind == SPI_MISO) spi_mosi_q.push_back(t.mosi);
    endfunction
    function void fail(string tag, string msg);
        $display("[SCOREBOARD_ERROR] %s %s", tag, msg);
        `uvm_error("SCOREBOARD_ERROR", {tag, " ", msg})
        error_count++;
    endfunction
    function void checker_fail(string tag, string msg);
        $display("[CHECKER_ERROR] %s %s", tag, msg);
        `uvm_error("CHECKER_ERROR", {tag, " ", msg})
        error_count++;
    endfunction
    function bit [31:0] width_mask(bit [1:0] width);
        case (width)
            2'b00: return 32'h0000_00ff;
            2'b01: return 32'h0000_ffff;
            default: return 32'hffff_ffff;
        endcase
    endfunction
    function bit [31:0] masked(bit [31:0] data, bit [1:0] width);
        return data & width_mask(width);
    endfunction
    function void check_equal(string tag, bit [31:0] exp, bit [31:0] obs);
        check_count++;
        if (obs !== exp) fail(tag, $sformatf("expected=0x%08h observed=0x%08h", exp, obs));
    endfunction
    function void check_bit(string tag, bit exp, bit obs);
        check_count++;
        if (obs !== exp) fail(tag, $sformatf("expected=%0b observed=%0b", exp, obs));
    endfunction
    function void check_masked(string tag, bit [31:0] exp, bit [31:0] obs, bit [31:0] mask);
        check_count++;
        if ((obs & mask) !== (exp & mask)) fail(tag, $sformatf("mask=0x%08h expected=0x%08h observed=0x%08h", mask, exp & mask, obs & mask));
    endfunction
    function void check_rx(string tag, bit [31:0] exp, bit [31:0] obs, bit [1:0] width);
        bit [31:0] mask = width_mask(width);
        check_masked({tag, "_rx"}, exp, obs, mask);
        if ((obs & ~mask) !== 0) fail({tag, "_zero_extend"}, $sformatf("observed=0x%08h", obs));
    endfunction
    task wait_mosi_count(int count, int cycles, virtual spi_if vif, string tag);
        bit done = 0;
        repeat (cycles) begin
            @(posedge vif.pclk);
            if (spi_mosi_q.size() >= count) begin
                done = 1;
                break;
            end
        end
        if (!done) fail({tag, "_mosi_timeout"}, $sformatf("wanted=%0d observed=%0d", count, spi_mosi_q.size()));
    endtask
    function bit pop_mosi(output bit [31:0] word);
        if (spi_mosi_q.size() == 0) begin
            word = 0;
            return 0;
        end
        word = spi_mosi_q.pop_front();
        return 1;
    endfunction
    function void clear_queues();
        spi_mosi_q.delete();
        apb_q.delete();
    endfunction
endclass
