package apb_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum int {APB_READ, APB_WRITE} apb_kind_e;

    class apb_item extends uvm_sequence_item;
        rand apb_kind_e kind;
        rand bit [7:0] addr;
        rand bit [31:0] data;
        bit [31:0] rdata;
        bit pslverr;
        bit pready;
        `uvm_object_utils_begin(apb_item)
            `uvm_field_enum(apb_kind_e, kind, UVM_ALL_ON)
            `uvm_field_int(addr, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(rdata, UVM_ALL_ON)
            `uvm_field_int(pslverr, UVM_ALL_ON)
            `uvm_field_int(pready, UVM_ALL_ON)
        `uvm_object_utils_end
        function new(string name = "apb_item");
            super.new(name);
        endfunction
    endclass

    class apb_idle_item extends apb_item;
        `uvm_object_utils(apb_idle_item)
        function new(string name = "apb_idle_item");
            super.new(name);
        endfunction
    endclass

    class apb_sequencer extends uvm_sequencer #(apb_item);
        `uvm_component_utils(apb_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class apb_driver extends uvm_driver #(apb_item);
        `uvm_component_utils(apb_driver)
        virtual apb_if vif;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "apb_if not found")
        endfunction
        task run_phase(uvm_phase phase);
            apb_item tr;
            idle();
            forever begin
                seq_item_port.get_next_item(tr);
                drive(tr);
                seq_item_port.item_done(tr);
            end
        endtask
        task idle();
            vif.cb_master.psel <= 1'b0;
            vif.cb_master.penable <= 1'b0;
            vif.cb_master.pwrite <= 1'b0;
            vif.cb_master.paddr <= '0;
            vif.cb_master.pwdata <= '0;
        endtask
        task drive(apb_item tr);
            @(vif.cb_master);
            vif.cb_master.psel <= 1'b1;
            vif.cb_master.penable <= 1'b0;
            vif.cb_master.pwrite <= (tr.kind == APB_WRITE);
            vif.cb_master.paddr <= tr.addr;
            vif.cb_master.pwdata <= tr.data;
            @(vif.cb_master);
            vif.cb_master.penable <= 1'b1;
            do @(vif.cb_master); while (!vif.cb_master.pready);
            tr.rdata = vif.cb_master.prdata;
            tr.pready = vif.cb_master.pready;
            tr.pslverr = vif.cb_master.pslverr;
            vif.cb_master.psel <= 1'b0;
            vif.cb_master.penable <= 1'b0;
            vif.cb_master.pwrite <= 1'b0;
            vif.cb_master.paddr <= '0;
            vif.cb_master.pwdata <= '0;
        endtask
    endclass

    class apb_monitor extends uvm_monitor;
        `uvm_component_utils(apb_monitor)
        virtual apb_if vif;
        uvm_analysis_port #(apb_item) ap;
        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "apb_if not found")
        endfunction
        task run_phase(uvm_phase phase);
            apb_item tr;
            forever begin
                @(vif.cb_monitor);
                if (vif.cb_monitor.psel && vif.cb_monitor.penable && vif.cb_monitor.pready) begin
                    tr = apb_item::type_id::create("tr", this);
                    tr.kind = vif.cb_monitor.pwrite ? APB_WRITE : APB_READ;
                    tr.addr = vif.cb_monitor.paddr;
                    tr.data = vif.cb_monitor.pwdata;
                    tr.rdata = vif.cb_monitor.prdata;
                    tr.pready = vif.cb_monitor.pready;
                    tr.pslverr = vif.cb_monitor.pslverr;
                    ap.write(tr);
                end
            end
        endtask
    endclass

    class apb_agent extends uvm_agent;
        `uvm_component_utils(apb_agent)
        apb_sequencer sqr;
        apb_driver drv;
        apb_monitor mon;
        virtual apb_if vif;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "apb_if not found")
            mon = apb_monitor::type_id::create("mon", this);
            uvm_config_db#(virtual apb_if)::set(this, "mon", "vif", vif);
            if (is_active == UVM_ACTIVE) begin
                sqr = apb_sequencer::type_id::create("sqr", this);
                drv = apb_driver::type_id::create("drv", this);
                uvm_config_db#(virtual apb_if)::set(this, "drv", "vif", vif);
            end
        endfunction
        function void connect_phase(uvm_phase phase);
            if (is_active == UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass

    class apb_write_seq extends uvm_sequence #(apb_item);
        `uvm_object_utils(apb_write_seq)
        rand bit [7:0] addr;
        rand bit [31:0] data;
        function new(string name = "apb_write_seq");
            super.new(name);
        endfunction
        task body();
            apb_item tr = apb_item::type_id::create("tr");
            start_item(tr);
            tr.kind = APB_WRITE;
            tr.addr = addr;
            tr.data = data;
            finish_item(tr);
        endtask
    endclass

    class apb_read_seq extends uvm_sequence #(apb_item);
        `uvm_object_utils(apb_read_seq)
        rand bit [7:0] addr;
        bit [31:0] data;
        function new(string name = "apb_read_seq");
            super.new(name);
        endfunction
        task body();
            apb_item tr = apb_item::type_id::create("tr");
            start_item(tr);
            tr.kind = APB_READ;
            tr.addr = addr;
            tr.data = 0;
            finish_item(tr);
            data = tr.rdata;
        endtask
    endclass
endpackage
