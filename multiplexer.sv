`include "sys_defs.svh"

module multiplexer(
    input [(`BIN_LEN - 1) : 0] bin_in,
    input [(`BIN_WIDTH - 1) : 0] selector,
    input zero_select,
    output bin_out
);
    assign bin_out = (zero_select == 1'b1) ? 0 : bin_in[selector];
endmodule
