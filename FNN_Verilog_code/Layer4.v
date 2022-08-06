`timescale 1ns / 1ps

module Layer4 # (parameter INDATA_WIDTH = 44, NN4=10,WEIGHT_WIDTH=16, PREVLAYER_COUNT =10, BEFORE_DEC=13, AFTER_DEC=28,PART_NO_WIDTH=6)(
    input clk,
    input rst4,
    input start4,
    input restart4,
    input shift4,
    input [INDATA_WIDTH-1:0]input_data,
    input valid_input,
    input [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weight_bus,
    input load_weights,
    input weight_valid,
    output reg neurons_finished4,
    output reg transferred4,
    output reg [INDATA_WIDTH+2:0]layer_4_SOUT,
    output reg layer_4_ready,
    output neurons_in_state,
    output [0:NN4-1]neurons_instate_2
    );
    wire [0:NN4-1]finished4;
    reg [INDATA_WIDTH-1:0] in_data4;
    reg y=0;
    integer counter4=1;
    integer i;
    parameter S0=0, S1=1, S2=2;
    reg [0:1]state4;
    reg valid_input_4;
    wire [0:NN4-1]weights_loaded4;
    
    reg [(INDATA_WIDTH+3)*NN4-1:0]PISO_HOLD4;
    wire[(INDATA_WIDTH+3)*NN4-1:0]neuron4_out_bus;
      genvar p;
      generate for(p=0;p<NN4;p=p+1)
      begin: gen_neuron_L4
      neuron  #(.INDATA_WIDTH(INDATA_WIDTH), .PREVLAYER_COUNT(PREVLAYER_COUNT), .neuron_part_number(50+PREVLAYER_COUNT+p), .BEFORE_DEC(BEFORE_DEC), .AFTER_DEC(AFTER_DEC),.PART_NUMBER_WIDTH(PART_NO_WIDTH))NN (
      .clk(clk),
      .rstn(rst4),
      .restart(restart4),
      .in_data(input_data),
      .start(start4),
      .load_weights_in(load_weights),
      .weight_val_in(weight_bus[0:WEIGHT_WIDTH-1]),
      .weight_valid(weight_valid),
      .part_number(weight_bus[WEIGHT_WIDTH:WEIGHT_WIDTH+PART_NO_WIDTH-1]),
      .out_data(neuron4_out_bus[((NN4-1-p)*(INDATA_WIDTH+3)+INDATA_WIDTH+2):(NN4-1-p)*(INDATA_WIDTH+3)]),
      .finish(finished4[p]),
      .weights_loaded(weights_loaded4[p]),
      .valid_input(valid_input),
      .instate_2(neurons_instate_2[p])
      );
      end
      endgenerate
      
      
    always @(negedge clk)
    begin
    case(state4)
    S0: begin
        if(start4&&y==0)
        state4<=S1;
        end
    S1: begin
        if(finished4=={NN4{1'b1}})
        state4<=S2;
        end
    S2: begin
        if(restart4 && transferred4 )
        state4<=S0;
        end
    default state4<=S0;
    endcase
    end
    
    always @(negedge clk)
    case(state4)
    S0: begin
        PISO_HOLD4=0;
        transferred4=0;
        y=0;
        counter4=1;
        neurons_finished4=0;
        end
    S1: begin
        end
    S2: begin
        if(shift4)
        begin
        if(PISO_HOLD4 !=0)
        begin
        layer_4_SOUT=PISO_HOLD4[(INDATA_WIDTH+3)*NN4-1:(NN4-1)*(INDATA_WIDTH+3)];
        end
        PISO_HOLD4=PISO_HOLD4<<(INDATA_WIDTH+3);
        counter4=counter4+1;
        if(counter4==NN4+1)
        transferred4=1;
        end
        end
    endcase
    
    always @(negedge clk)
        begin
        if(y==0)
        begin
        for(i=0;i<NN4;i=i+1)
        begin
        PISO_HOLD4[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)]<=neuron4_out_bus[i*(INDATA_WIDTH+3)+:(INDATA_WIDTH+3)];
        end
        if(finished4=={NN4{1'b1}})
        begin
        y<=1;
        neurons_finished4<=1;
        end
        end
        if(weights_loaded4=={NN4{1'b1}})
        begin
        layer_4_ready=1;
        end
        end
endmodule
