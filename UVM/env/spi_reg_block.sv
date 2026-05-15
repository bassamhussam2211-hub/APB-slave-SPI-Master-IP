class spi_reg32 extends uvm_reg;
    `uvm_object_utils(spi_reg32)
    rand uvm_reg_field F;
    bit [31:0] rst;
    string acc;
    function new(string name = "spi_reg32", bit [31:0] reset_value = 0, string access = "RW");
        super.new(name, 32, UVM_NO_COVERAGE);
        rst = reset_value;
        acc = access;
    endfunction
    virtual function void build();
        F = uvm_reg_field::type_id::create("F");
        F.configure(this, 32, 0, acc, 0, rst, 1, (acc != "RO"), 0);
    endfunction
endclass

class spi_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(spi_reg_adapter)
    function new(string name = "spi_reg_adapter");
        super.new(name);
        supports_byte_enable = 0;
        provides_responses = 1;
    endfunction
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        apb_item tr = apb_item::type_id::create("tr");
        tr.kind = (rw.kind == UVM_WRITE) ? APB_WRITE : APB_READ;
        tr.addr = rw.addr[7:0];
        tr.data = rw.data;
        return tr;
    endfunction
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        apb_item tr;
        if (!$cast(tr, bus_item)) begin
            `uvm_fatal("BADCAST", "bus item is not apb_item")
        end
        rw.kind = (tr.kind == APB_WRITE) ? UVM_WRITE : UVM_READ;
        rw.addr = tr.addr;
        rw.data = (tr.kind == APB_WRITE) ? tr.data : tr.rdata;
        rw.status = tr.pslverr ? UVM_NOT_OK : UVM_IS_OK;
    endfunction
endclass

class spi_reg_block extends uvm_reg_block;
    `uvm_object_utils(spi_reg_block)
    rand spi_reg32 CTRL;
    rand spi_reg32 STATUS;
    rand spi_reg32 TX_DATA;
    rand spi_reg32 RX_DATA;
    rand spi_reg32 CLK_DIV;
    rand spi_reg32 SS_CTRL;
    rand spi_reg32 INT_EN;
    rand spi_reg32 INT_STAT;
    rand spi_reg32 DELAY;
    function new(string name = "spi_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction
    virtual function void build();
        CTRL = spi_reg32::type_id::create("CTRL");
        CTRL.rst = 32'h0000_0000;
        CTRL.acc = "RW";
        CTRL.configure(this, null, "");
        CTRL.build();
        STATUS = spi_reg32::type_id::create("STATUS");
        STATUS.rst = 32'h0000_0014;
        STATUS.acc = "RO";
        STATUS.configure(this, null, "");
        STATUS.build();
        TX_DATA = spi_reg32::type_id::create("TX_DATA");
        TX_DATA.rst = 32'h0000_0000;
        TX_DATA.acc = "WO";
        TX_DATA.configure(this, null, "");
        TX_DATA.build();
        RX_DATA = spi_reg32::type_id::create("RX_DATA");
        RX_DATA.rst = 32'h0000_0000;
        RX_DATA.acc = "RO";
        RX_DATA.configure(this, null, "");
        RX_DATA.build();
        CLK_DIV = spi_reg32::type_id::create("CLK_DIV");
        CLK_DIV.rst = 32'h0000_0000;
        CLK_DIV.acc = "RW";
        CLK_DIV.configure(this, null, "");
        CLK_DIV.build();
        SS_CTRL = spi_reg32::type_id::create("SS_CTRL");
        SS_CTRL.rst = 32'h0000_0000;
        SS_CTRL.acc = "RW";
        SS_CTRL.configure(this, null, "");
        SS_CTRL.build();
        INT_EN = spi_reg32::type_id::create("INT_EN");
        INT_EN.rst = 32'h0000_0000;
        INT_EN.acc = "RW";
        INT_EN.configure(this, null, "");
        INT_EN.build();
        INT_STAT = spi_reg32::type_id::create("INT_STAT");
        INT_STAT.rst = 32'h0000_0000;
        INT_STAT.acc = "RW";
        INT_STAT.configure(this, null, "");
        INT_STAT.build();
        DELAY = spi_reg32::type_id::create("DELAY");
        DELAY.rst = 32'h0000_0000;
        DELAY.acc = "RW";
        DELAY.configure(this, null, "");
        DELAY.build();
        default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN);
        default_map.add_reg(CTRL, 'h00, "RW");
        default_map.add_reg(STATUS, 'h04, "RO");
        default_map.add_reg(TX_DATA, 'h08, "WO");
        default_map.add_reg(RX_DATA, 'h0c, "RO");
        default_map.add_reg(CLK_DIV, 'h10, "RW");
        default_map.add_reg(SS_CTRL, 'h14, "RW");
        default_map.add_reg(INT_EN, 'h18, "RW");
        default_map.add_reg(INT_STAT, 'h1c, "RW");
        default_map.add_reg(DELAY, 'h20, "RW");
        add_hdl_path("tb_top.u_wrap.u_dut.u_regfile");
        CTRL.add_hdl_path_slice("ctrl_en", 0, 1);
        CTRL.add_hdl_path_slice("ctrl_mstr", 1, 1);
        CTRL.add_hdl_path_slice("ctrl_mode", 2, 2);
        CTRL.add_hdl_path_slice("ctrl_lsb_first", 4, 1);
        CTRL.add_hdl_path_slice("ctrl_loopback", 5, 1);
        CTRL.add_hdl_path_slice("ctrl_width", 6, 2);
        CLK_DIV.add_hdl_path_slice("clk_div", 0, 16);
        SS_CTRL.add_hdl_path_slice("ss_en", 0, 4);
        SS_CTRL.add_hdl_path_slice("ss_val", 4, 4);
        INT_EN.add_hdl_path_slice("int_en", 0, 5);
        INT_STAT.add_hdl_path_slice("int_stat", 0, 5);
        DELAY.add_hdl_path_slice("delay_cfg", 0, 8);
        lock_model();
    endfunction
endclass
