`timescale 1ns / 1ps

module Layer1 # (parameter INDATA_WIDTH = 17,WEIGHT_WIDTH=16, NN1=30, PREVLAYER_COUNT =169, BEFORE_DEC=4, AFTER_DEC=28, PART_NO_WIDTH=6)(
    input clk,
    input rst1,
    input start1,
    input restart1,
    input shift1,
    input [INDATA_WIDTH-1:0]input_data,
    input valid_input,
    input [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weight_bus,
    input load_weights,
    input weight_valid,
    output reg neurons_finished1,
    output reg transferred1,
    output reg [INDATA_WIDTH+2:0]layer_1_SOUT,
    output reg layer_1_ready,
    output [0:NN1-1]neurons_instate_2
    );
    reg [1:0]count1 = 0;
    reg y=0;
    wire [0:NN1-1]finished1;
    reg [INDATA_WIDTH-1:0] in_data1;
    reg [0:PART_NO_WIDTH]part_no;
    reg signed [0:INDATA_WIDTH-1]weight_value1;
    integer counter1=1;
    integer i=0;
    parameter S0=0, S1=1, S2=2;
    reg [0:1]state1;
    reg valid_input1;
    wire [0:NN1-1]weights_loaded1;
    
    reg [(INDATA_WIDTH+3)*NN1-1:0]PISO_HOLD;
    wire[(INDATA_WIDTH+3)*NN1-1:0]neuron1_out_bus;
    genvar p;
    generate for(p=0;p<NN1;p=p+1)
    begin: gen_neuron_L1
    neuron  #(.INDATA_WIDTH(INDATA_WIDTH), .PREVLAYER_COUNT(PREVLAYER_COUNT), .neuron_part_number(p), .BEFORE_DEC(BEFORE_DEC), .AFTER_DEC(AFTER_DEC),.PART_NUMBER_WIDTH(PART_NO_WIDTH))NN (
    .clk(clk),
    .rstn(rst1),
    .restart(restart1),
    .in_data(input_data),
    .start(start1),
    .load_weights_in(load_weights),
    .weight_val_in(weight_bus[0:WEIGHT_WIDTH-1]),
    .weight_valid(weight_valid),
    .part_number(weight_bus[WEIGHT_WIDTH:WEIGHT_WIDTH+PART_NO_WIDTH-1]),
    .out_data(neuron1_out_bus[((NN1-1-p)*(INDATA_WIDTH+3)+INDATA_WIDTH+2):(NN1-1-p)*(INDATA_WIDTH+3)]),
    .finish(finished1[p]),
    .weights_loaded(weights_loaded1[p]),
    .valid_input(valid_input),
    .instate_2(neurons_instate_2[p])
    );
    end
    endgenerate


    always @(negedge clk)
    begin
    case(state1)
    S0: begin
        if(start1&&y==0)
        state1<=S1;
        end
    S1: begin
        if(neurons_finished1)
        state1<=S2;
        end
    S2: begin
        if(restart1 && transferred1)
        state1<=S0;
        end
    default state1<=S0;
    endcase
    end
    
    always @(negedge clk)
    case(state1)
    S0: begin
        PISO_HOLD=0;
        transferred1=0;
        y=0;
        counter1=1;
        neurons_finished1=0;
        end
    S1: begin
        if(!valid_input)
        begin
        end
        end
    S2: begin
        if(shift1)
        begin
        layer_1_SOUT=PISO_HOLD[(INDATA_WIDTH+3)*NN1-1:(NN1-1)*(INDATA_WIDTH+3)];
        PISO_HOLD=PISO_HOLD<<(INDATA_WIDTH+3);
        counter1=counter1+1;
        if(counter1==NN1+1)
        transferred1=1;
        end
        end
    endcase

    always @(negedge clk)
        begin
        if(y==0)
        begin
        for(i=0;i<NN1;i=i+1)
        begin
        PISO_HOLD[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)]<=neuron1_out_bus[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)];
        end
        if(finished1=={NN1{1'b1}})
        begin
        y<=1;
        neurons_finished1<=1;
        end
        end
        if(weights_loaded1=={NN1{1'b1}})
        begin
        layer_1_ready<=1;
        end
        end
endmodule
