`include "sys_defs.svh"

module processing_unit(
    input clock,
    input reset,
    input start,

    output input_req,
    input [(`BIN_LEN - 1) : 0] input_val,
    input input_ready,


    input [(`BIN_LEN - 1) : 0] weight_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0],

    output [(`OUT_BIN_LEN - 1) : 0] output_val,
    output output_valid,

    output done
);

    wire zero_flag;
    genvar i, j;
    wire [(`OUT_BIN_LEN - 1) : 0] output_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];
    reg [(`OUT_BIN_LEN - 1) : 0] init_vals [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];
    wire [(`BIN_WIDTH - 1) : 0] selector;
    wire zero_select;

    reg enables [(`KERNEL_HEIGHT - 1) : 0][(`KERNEL_WIDTH - 1) : 0];

    reg [(`INPUT_WIDTH_LOG - 1) : 0] width_index;
    reg [(`INPUT_HEIGHT_LOG - 1) : 0] height_index;

    wire down_counter_reset, down_counter_enable;
    wire FSM_selector_reset, FSM_selector_enable;
    wire PE_reset, PE_enable, PE_init;
    wire index_reset, index_enable;
    wire partial_sum_reset, partial_sum_enable;

    wire output_valid_tmp;

    reg [(`OUT_BIN_LEN - 1) : 0] store_vals [(`KERNEL_HEIGHT - 1) : 0];
    wire [(`OUT_BIN_LEN - 1) : 0] fetch_vals [(`KERNEL_HEIGHT - 1) : 0];

    controller controller_inst(
        .clock(clock),
        .reset(reset),
        .start(start),
        .input_ready(input_ready),
        .zero_flag(zero_flag),

        .width_index(width_index),
        .height_index(height_index),

        .down_counter_reset(down_counter_reset),
        .down_counter_enable(down_counter_enable),
        .FSM_selector_reset(FSM_selector_reset),
        .FSM_selector_enable(FSM_selector_enable),
        .PE_reset(PE_reset),
        .PE_enable(PE_enable),
        .PE_init(PE_init),
        .index_reset(index_reset),
        .index_enable(index_enable),
        .partial_sum_reset(partial_sum_reset),
        .partial_sum_enable(partial_sum_enable),
        .output_valid(output_valid_tmp),
        .input_req(input_req),
        .done(done)
    );


    down_counter down_counter_inst(
        .clock(clock),
        .reset(down_counter_reset|reset),
        .enable(down_counter_enable),

        .count_init(input_val),
        .zero(zero_flag)
    );

    FSM_selector FSM_selector_inst(
        .clock(clock),
        .reset(FSM_selector_reset|reset),
        .enable(FSM_selector_enable),

        .selector(selector),
        .zero_select(zero_select)
    );

    for (i = 0; i < `KERNEL_HEIGHT; i = i + 1) begin : PE_row
        for (j = 0; j < `KERNEL_HEIGHT; j = j + 1) begin : PE_column
            processing_element PEs(
                .clock(clock),
                .reset(PE_reset|reset),
                .enable(enables[i][j] && PE_enable),
                .init(PE_init),
                .selector(selector),
                .zero_select(zero_select),
                .init_val(init_vals[i][j]),
                .weight_val(weight_vals[i][j]),
                .output_val(output_vals[i][j])
            );
        end
    end

    always@(*) begin
        for (int i = 0; i < `KERNEL_HEIGHT; i = i + 1) begin
            for (int j = 1; j < `KERNEL_HEIGHT; j = j + 1) begin
                init_vals[i][j] = output_vals[i][j-1];
            end
            for (int j = 0; j < `KERNEL_HEIGHT; j = j + 1) begin
                enables[i][j] = ((i <= height_index) && (j <= width_index) && (width_index + `KERNEL_WIDTH - 1 - j < `INPUT_WIDTH) && (height_index + `KERNEL_HEIGHT - 1 - i < `INPUT_HEIGHT)) ? 1 : 0;
            end
            store_vals[i] = output_vals[i][(`KERNEL_WIDTH - 1)];
            init_vals[i][0] = fetch_vals[i];
        end
    end

    assign output_val = output_vals[(`KERNEL_HEIGHT - 1)][(`KERNEL_WIDTH - 1)];
    assign output_valid = ((output_valid_tmp == 1) && (width_index >= (`KERNEL_WIDTH - 1)) && (height_index >= (`KERNEL_HEIGHT - 1))) ? 1 : 0;

    partial_result_buffer partial_result_buffer_inst(
        .clock(clock),
        .reset(partial_sum_reset),
        .enable(partial_sum_enable),

        .store_vals(store_vals),

        .width_index(width_index),

        .fetch_vals(fetch_vals)
    );

    always@(posedge clock) begin
        if(index_reset) begin
            width_index = 0;
            height_index = 0;
        end else if (index_enable) begin
            if(width_index == `INPUT_WIDTH - 1) begin
                width_index = 0;
                height_index = height_index + 1;
            end else begin
                width_index = width_index + 1;
            end
        end
    end

endmodule
