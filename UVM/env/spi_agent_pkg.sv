package spi_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum int {SPI_CFG, SPI_MISO, SPI_CLEAR} spi_item_kind_e;

    class spi_item extends uvm_sequence_item;
        rand spi_item_kind_e kind;
        rand bit [1:0] mode;
        rand bit [1:0] width;
        rand bit lsb_first;
        rand bit [31:0] data;
        bit [31:0] mosi;
        `uvm_object_utils_begin(spi_item)
            `uvm_field_enum(spi_item_kind_e, kind, UVM_ALL_ON)
            `uvm_field_int(mode, UVM_ALL_ON)
            `uvm_field_int(width, UVM_ALL_ON)
            `uvm_field_int(lsb_first, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(mosi, UVM_ALL_ON)
        `uvm_object_utils_end
        function new(string name = "spi_item");
            super.new(name);
        endfunction
    endclass

    class spi_sequencer extends uvm_sequencer #(spi_item);
        `uvm_component_utils(spi_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class spi_driver extends uvm_driver #(spi_item);
        `uvm_component_utils(spi_driver)
        virtual spi_if vif;
        uvm_analysis_port #(spi_item) ap;
        bit [1:0] mode_cfg;
        bit [1:0] width_cfg;
        bit lsb_first_cfg;
        bit [31:0] miso_q[$];
        bit [31:0] current_miso;
        bit [31:0] recv_word;
        int bits_seen;
        int send_index;
        logic sclk_q;
        logic active_q;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "spi_if not found")
        endfunction
        task run_phase(uvm_phase phase);
            fork
                consume_items();
                drive_responder();
            join
        endtask
        task consume_items();
            spi_item tr;
            forever begin
                seq_item_port.get_next_item(tr);
                if (tr.kind == SPI_CFG) begin
                    mode_cfg = tr.mode;
                    width_cfg = tr.width;
                    lsb_first_cfg = tr.lsb_first;
                end else if (tr.kind == SPI_MISO) begin
                    miso_q.push_back(tr.data & width_mask());
                end else begin
                    miso_q.delete();
                    current_miso = 0;
                    recv_word = 0;
                    bits_seen = 0;
                    send_index = 0;
                    active_q = 0;
                    vif.cb_slave.miso <= 1'b0;
                end
                seq_item_port.item_done();
            end
        endtask
        task drive_responder();
            mode_cfg = 0;
            width_cfg = 0;
            lsb_first_cfg = 0;
            current_miso = 0;
            recv_word = 0;
            bits_seen = 0;
            send_index = 0;
            sclk_q = 0;
            active_q = 0;
            vif.cb_slave.miso <= 1'b0;
            forever begin
                @(posedge vif.pclk);
                sample_and_drive();
            end
        endtask
        function int width_bits();
            case (width_cfg)
                2'b00: width_bits = 8;
                2'b01: width_bits = 16;
                default: width_bits = 32;
            endcase
        endfunction
        function bit [31:0] width_mask();
            case (width_cfg)
                2'b00: width_mask = 32'h0000_00ff;
                2'b01: width_mask = 32'h0000_ffff;
                default: width_mask = 32'hffff_ffff;
            endcase
        endfunction
        function bit word_bit(input bit [31:0] word, input int index);
            int pos;
            if (lsb_first_cfg) pos = index;
            else pos = width_bits() - 1 - index;
            word_bit = word[pos];
        endfunction
        function void sample_and_drive();
            bit ss_act;
            bit edge_seen;
            bit leading;
            bit sample_edge;
            bit [31:0] next_word;
            int pos;
            ss_act = (vif.ss_n != 4'hf);
            edge_seen = (vif.sclk !== sclk_q);
            leading = edge_seen && (sclk_q === mode_cfg[1]) && (vif.sclk !== mode_cfg[1]);
            sample_edge = (mode_cfg[0] == 1'b0) ? leading : (edge_seen && !leading);
            if (!ss_act) begin
                active_q = 0;
                bits_seen = 0;
                send_index = 0;
                recv_word = 0;
                sclk_q = vif.sclk;
                if (miso_q.size() > 0) current_miso = miso_q[0];
                if (mode_cfg[0] == 1'b0 && miso_q.size() > 0) vif.cb_slave.miso <= word_bit(miso_q[0], 0);
                else vif.cb_slave.miso <= 1'b0;
            end else begin
                if (!active_q) begin
                    if (miso_q.size() > 0) next_word = miso_q.pop_front();
                    else next_word = 0;
                    active_q = 1;
                    bits_seen = 0;
                    send_index = (mode_cfg[0] == 1'b0) ? 1 : 0;
                    recv_word = 0;
                    current_miso = next_word;
                    vif.cb_slave.miso <= word_bit(next_word, 0);
                end else if (edge_seen) begin
                    if (sample_edge) begin
                        if (lsb_first_cfg) pos = bits_seen;
                        else pos = width_bits() - 1 - bits_seen;
                        recv_word[pos] = vif.mosi;
                        if (bits_seen == width_bits() - 1) begin
                            spi_item obs;
                            obs = spi_item::type_id::create("obs", this);
                            obs.kind = SPI_MISO;
                            obs.mode = mode_cfg;
                            obs.width = width_cfg;
                            obs.lsb_first = lsb_first_cfg;
                            obs.mosi = recv_word & width_mask();
                            ap.write(obs);
                            bits_seen = 0;
                            send_index = 1;
                            recv_word = 0;
                            if (miso_q.size() > 0) next_word = miso_q.pop_front();
                            else next_word = 0;
                            current_miso = next_word;
                            vif.cb_slave.miso <= word_bit(next_word, 0);
                        end else begin
                            bits_seen++;
                            send_index = bits_seen + 1;
                            vif.cb_slave.miso <= word_bit(current_miso, bits_seen);
                        end
                    end
                    sclk_q = vif.sclk;
                end
            end
        endfunction
    endclass

    class spi_monitor extends uvm_monitor;
        `uvm_component_utils(spi_monitor)
        virtual spi_if vif;
        uvm_analysis_port #(spi_item) ap;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "spi_if not found")
        endfunction
        task run_phase(uvm_phase phase);
            spi_item tr;
            logic ss_q;
            ss_q = 1'b0;
            forever begin
                @(vif.cb_mon);
                if ((vif.cb_mon.ss_n != 4'hf) && !ss_q) begin
                    tr = spi_item::type_id::create("ss_assert", this);
                    tr.kind = SPI_CFG;
                    tr.data = 32'h1;
                    ap.write(tr);
                    ss_q = 1'b1;
                end
                if ((vif.cb_mon.ss_n == 4'hf) && ss_q) begin
                    tr = spi_item::type_id::create("ss_deassert", this);
                    tr.kind = SPI_CLEAR;
                    tr.data = 32'h0;
                    ap.write(tr);
                    ss_q = 1'b0;
                end
            end
        endtask
    endclass

    class spi_agent extends uvm_agent;
        `uvm_component_utils(spi_agent)
        spi_sequencer sqr;
        spi_driver drv;
        spi_monitor mon;
        virtual spi_if vif;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "spi_if not found")
            mon = spi_monitor::type_id::create("mon", this);
            uvm_config_db#(virtual spi_if)::set(this, "mon", "vif", vif);
            if (is_active == UVM_ACTIVE) begin
                sqr = spi_sequencer::type_id::create("sqr", this);
                drv = spi_driver::type_id::create("drv", this);
                uvm_config_db#(virtual spi_if)::set(this, "drv", "vif", vif);
            end
        endfunction
        function void connect_phase(uvm_phase phase);
            if (is_active == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    class spi_cfg_seq extends uvm_sequence #(spi_item);
        `uvm_object_utils(spi_cfg_seq)
        rand bit [1:0] mode;
        rand bit [1:0] width;
        rand bit lsb_first;
        function new(string name = "spi_cfg_seq");
            super.new(name);
        endfunction
        task body();
            spi_item tr = spi_item::type_id::create("tr");
            start_item(tr);
            tr.kind = SPI_CFG;
            tr.mode = mode;
            tr.width = width;
            tr.lsb_first = lsb_first;
            finish_item(tr);
        endtask
    endclass

    class spi_miso_word_seq extends uvm_sequence #(spi_item);
        `uvm_object_utils(spi_miso_word_seq)
        rand bit [31:0] data;
        function new(string name = "spi_miso_word_seq");
            super.new(name);
        endfunction
        task body();
            spi_item tr = spi_item::type_id::create("tr");
            start_item(tr);
            tr.kind = SPI_MISO;
            tr.data = data;
            finish_item(tr);
        endtask
    endclass

    class spi_clear_seq extends uvm_sequence #(spi_item);
        `uvm_object_utils(spi_clear_seq)
        function new(string name = "spi_clear_seq");
            super.new(name);
        endfunction
        task body();
            spi_item tr = spi_item::type_id::create("tr");
            start_item(tr);
            tr.kind = SPI_CLEAR;
            finish_item(tr);
        endtask
    endclass
endpackage
