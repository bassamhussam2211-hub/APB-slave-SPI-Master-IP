class spi_ref_model extends uvm_component;
    `uvm_component_utils(spi_ref_model)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    function int width_bits(bit [1:0] width);
        case (width)
            2'b00: return 8;
            2'b01: return 16;
            default: return 32;
        endcase
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
endclass
