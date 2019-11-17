`include "sys_defs.svh"

module counter(
    input clock,
    input reset,
    input enable,
    input init,

    input bit_in,

    input [(`OUT_BIN_LEN - 1) : 0] init_val,

    output reg [(`OUT_BIN_LEN - 1):0] count
);

    always@(posedge clock)begin
        if(reset)begin
            count = 0;
        end else if(init == 1) begin
            count = init_val;
        end else if(enable == 1) begin
            count = count + bit_in;
        end
    end

endmodule
