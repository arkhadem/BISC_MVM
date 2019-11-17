`include "sys_defs.svh"

module down_counter(
    input clock,
    input reset,
    input enable,

    input [(`BIN_LEN - 1):0] count_init,
    output zero
);

    reg [(`BIN_LEN - 1):0] Count;

    always@(posedge clock)begin
        if(reset)begin
            Count = count_init;
        end else if(enable == 1 && Count != 0) begin
            Count = Count - 1;
        end
    end

    assign zero = (Count == 0) ? 1'b1 : 1'b0;

endmodule
