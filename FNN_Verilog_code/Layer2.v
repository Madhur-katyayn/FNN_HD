`timescale 1ns / 1ps

module Layer2 # (parameter INDATA_WIDTH = 26, NN2=10,WEIGHT_WIDTH=16, PREVLAYER_COUNT =30, BEFORE_DEC=7, AFTER_DEC=28, PART_NO_WIDTH=6)(
    input clk,
    input rst2,
    input start2,
    input restart2,
    input shift2,
    input [INDATA_WIDTH-1:0]input_data,
    input valid_input,
    input [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weight_bus,
    input load_weights,
    input weight_valid,
    output reg neurons_finished2,
    output reg transferred2,
    output reg [INDATA_WIDTH+2:0]layer_2_SOUT,
    output reg layer_2_ready,
    output [0:NN2-1]neurons_instate_2
    );
    integer counter2=1;
    integer i=0;
    reg x=0;
    reg y=0;
    parameter S0=0, S1=1, S2=2;
    reg [0:1]state2;
    wire [0:NN2-1]finished2;
    reg [INDATA_WIDTH-1:0]in_data2;
    wire [0:NN2-1]weights_loaded2;
    reg [(INDATA_WIDTH+3)*NN2-1:0]PISO_HOLD2;
    wire[(INDATA_WIDTH+3)*NN2-1:0]neuron2_out_bus;
    reg valid_input_2;
    genvar p;
    generate for(p=0;p< NN2 ;p=p+1)
    begin: gen_neuron_L2
    neuron  #(.INDATA_WIDTH(INDATA_WIDTH), .PREVLAYER_COUNT(PREVLAYER_COUNT), .neuron_part_number(p+PREVLAYER_COUNT), .BEFORE_DEC(BEFORE_DEC), .AFTER_DEC(AFTER_DEC),.PART_NUMBER_WIDTH(PART_NO_WIDTH))NN (
    .clk(clk),
    .rstn(rst2),
    .restart(restart2),
    .in_data(input_data),
    .start(start2),
    .load_weights_in(load_weights),
    .weight_val_in(weight_bus[0:WEIGHT_WIDTH-1]),
    .weight_valid(weight_valid),
    .part_number(weight_bus[WEIGHT_WIDTH:WEIGHT_WIDTH+PART_NO_WIDTH-1]),
    .out_data(neuron2_out_bus[((NN2-1-p)*(INDATA_WIDTH+3)+INDATA_WIDTH+2):(NN2-1-p)*(INDATA_WIDTH+3)]),
    .finish(finished2[p]),
    .weights_loaded(weights_loaded2[p]),
    .valid_input(valid_input),
    .instate_2(neurons_instate_2[p])
    );
    end
    endgenerate
    
always @(negedge clk)
    begin
    case(state2)
    S0: begin
        if(start2&&y==0)
        state2<=S1;
        end
    S1: begin
        if(finished2=={NN2{1'b1}})
        state2<=S2;
        end
    S2: begin
        if(restart2 && transferred2 )
        state2<=S0;
        end
    default state2<=S0;
    endcase
    end
    
    always @(negedge clk)
    case(state2)
    S0: begin
        PISO_HOLD2=0;
        transferred2=0;
        y=0;
        counter2=1;
        neurons_finished2=0;
        end
    S1: begin
        if(!valid_input)
        begin
        end
        end
    S2: begin
        if(shift2)
        begin
        layer_2_SOUT=PISO_HOLD2[(INDATA_WIDTH+3)*NN2-1:(NN2-1)*(INDATA_WIDTH+3)];
        PISO_HOLD2=PISO_HOLD2<<(INDATA_WIDTH+3);
        counter2=counter2+1;
        if(counter2==NN2+1)
        transferred2=1;
        end
        end
    endcase
    
    always @(negedge clk)
        begin
        if(y==0)
        begin
        for(i=0;i<NN2;i=i+1)
        begin
        PISO_HOLD2[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)]<=neuron2_out_bus[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)];
        end
        if(finished2=={NN2{1'b1}})
        begin
        y<=1;
        neurons_finished2<=1;
        end
        end
        if(weights_loaded2=={NN2{1'b1}})
        begin
        layer_2_ready<=1;
        end
        end

endmodule
