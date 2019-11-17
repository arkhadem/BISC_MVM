`include "sys_defs.svh"

module FSM_selector(
    input clock,
    input reset,
    input enable,

    output [(`BIN_WIDTH - 1) : 0] selector,
    output zero_select
);


    reg [(`BIN_LEN - 1) : 0] count;

    reg [4:0] values [0:32767];

    initial begin
        $readmemh("C:/Users/arkhadem/Dropbox/Reading/codes/BISC/Selector_data.data", values);
    end

    always@(posedge clock) begin
        if(reset) begin
            count = 0;
        end else if(enable) begin
            count = count + 1;
        end
    end

    assign selector = `BIN_LEN - 1 - values[count][`BIN_WIDTH-1:0];
    assign zero_select = (count == `SC_LEN - 1) ? 1 : 0;

endmodule
