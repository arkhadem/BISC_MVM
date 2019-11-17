`include "sys_defs.svh"

module processing_element(
    input clock,
    input reset,
    input enable,
    input init,
    input [(`BIN_WIDTH - 1) : 0] selector,
    input zero_select,
    input [(`OUT_BIN_LEN - 1) : 0] init_val,
    input [(`BIN_LEN - 1) : 0] weight_val,
    output [(`OUT_BIN_LEN - 1) : 0] output_val
);

    wire bit_med;

    counter counter_inst(
        .clock(clock),
        .reset(reset),
        .enable(enable),
        .init(init),

        .init_val(init_val),

        .bit_in(bit_med),

        .count(output_val)
    );

    multiplexer multiplexer_inst(
        .bin_in(weight_val),
        .selector(selector),
        .zero_select(zero_select),
        .bin_out(bit_med)
    );

endmodule
