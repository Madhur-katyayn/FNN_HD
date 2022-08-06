`timescale 1ns / 1ps

module Layer3 # (parameter INDATA_WIDTH = 35, NN3=10,WEIGHT_WIDTH=16, PREVLAYER_COUNT =10, BEFORE_DEC=10, AFTER_DEC=28,PART_NO_WIDTH=6)(
    input clk,
    input rst3,
    input start3,
    input restart3,
    input shift3,
    input [INDATA_WIDTH-1:0]input_data,
    input valid_input,
    input [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weight_bus,
    input load_weights,
    input weight_valid,
    output reg neurons_finished3,
    output reg transferred3,
    output reg [INDATA_WIDTH+2:0]layer_3_SOUT,
    output reg layer_3_ready,
    output [0:NN3-1]neurons_instate_2
    );
    reg y=0;
    wire [0:NN3-1]finished3;
    integer counter3=1;
    integer i;
    reg [INDATA_WIDTH-1:0] in_data3;
    reg x=0;
    parameter S0=0, S1=1, S2=2;
    reg [0:1]state3;
    reg valid_input_3;
    wire [0:NN3-1]weights_loaded3;
   reg [(INDATA_WIDTH+3)*NN3-1:0]PISO_HOLD3;
   wire[(INDATA_WIDTH+3)*NN3-1:0]neuron3_out_bus;
      genvar p;
      generate for(p=0;p<NN3;p=p+1)
      begin: gen_neuron_L3
      neuron  #(.INDATA_WIDTH(INDATA_WIDTH), .PREVLAYER_COUNT(PREVLAYER_COUNT), .neuron_part_number(40+p+PREVLAYER_COUNT), .BEFORE_DEC(10), .AFTER_DEC(28),.PART_NUMBER_WIDTH(PART_NO_WIDTH))NN (
      .clk(clk),
      .rstn(rst3),
      .restart(restart3),
      .in_data(input_data),
      .start(start3),
      .load_weights_in(load_weights),
      .weight_val_in(weight_bus[0:WEIGHT_WIDTH-1]),
      .weight_valid(weight_valid),
      .part_number(weight_bus[WEIGHT_WIDTH:WEIGHT_WIDTH+PART_NO_WIDTH-1]),
      .out_data(neuron3_out_bus[((NN3-1-p)*(INDATA_WIDTH+3)+INDATA_WIDTH+2):(NN3-1-p)*(INDATA_WIDTH+3)]),
      .finish(finished3[p]),
      .weights_loaded(weights_loaded3[p]),
      .valid_input(valid_input),
      .instate_2(neurons_instate_2[p])
      );
      end
      endgenerate
    
always @(negedge clk)
    begin
    case(state3)
    S0: begin
        if(start3&&y==0)
        state3<=S1;
        end
    S1: begin
        if(finished3=={NN3{1'b1}})
        state3<=S2;
        end
    S2: begin
        if(restart3 && transferred3)
        state3<=S0;
        end
    default state3<=S0;
    endcase
    end
    
    always @(negedge clk)
    case(state3)
    S0: begin
        PISO_HOLD3=0;
        transferred3=0;
        y=0;
        counter3=1;
        neurons_finished3=0;
        end
    S1: begin
        end
    S2: begin
        if(shift3)
        begin
        layer_3_SOUT=PISO_HOLD3[(INDATA_WIDTH+3)*NN3-1:(NN3-1)*(INDATA_WIDTH+3)];
        PISO_HOLD3=PISO_HOLD3<<(INDATA_WIDTH+3);
        counter3=counter3+1;
        if(counter3==NN3+1)
        transferred3=1;
        end
        end
    endcase
    
    always @(negedge clk)
        begin
        if(y==0)
        begin
        for(i=0;i<NN3;i=i+1)
        begin
        PISO_HOLD3[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)]<=neuron3_out_bus[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)];
        end
        if(finished3=={NN3{1'b1}})
        begin
        y<=1;
        neurons_finished3<=1;
        end
        end
        if(weights_loaded3=={NN3{1'b1}})
        begin
        layer_3_ready=1;
        end
        end
endmodule
