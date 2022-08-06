`timescale 1ns / 1ps

module neuron#(parameter INDATA_WIDTH = 17, PREVLAYER_COUNT =169, neuron_part_number=0, BEFORE_DEC=4, AFTER_DEC=28, WEIGHT_WIDTH=16, PART_NUMBER_WIDTH=6)(
    input clk,
    input rstn,
    input restart,
    input [0:INDATA_WIDTH-1]in_data,
    input start,
    input valid_input,
    input load_weights_in,
    input  signed [0:WEIGHT_WIDTH-1] weight_val_in,
    input weight_valid,
    input [0:PART_NUMBER_WIDTH-1]part_number,
    output [0:BEFORE_DEC+14]out_data,
    output reg finish,
    output weights_loaded,
    output reg instate_2
    );
    reg x;
    reg k=0,p;
    reg bias_added=0;
    reg [9:0]count=0;
    reg signed [0:BEFORE_DEC+AFTER_DEC] bias=0;
    reg signed [0:WEIGHT_WIDTH-1] bias_from_RAM;
    reg signed [0:BEFORE_DEC+AFTER_DEC-1]product;
    reg signed [0:BEFORE_DEC+AFTER_DEC]sum;
    reg load_weight;
    reg [9:0] weight_adress;
    reg [0:INDATA_WIDTH-1]in_data1;
    wire signed [0:WEIGHT_WIDTH-1] weight_val_out;
    reg read_enable;
    reg signed [WEIGHT_WIDTH-1:0]weight_val_in_buff;
    reg weight_valid_buff;
    reg [0:BEFORE_DEC+14]neuron_out;
    integer i=0;
    assign out_data =neuron_out ;
    
    neuron_RAM #(.Depth(PREVLAYER_COUNT)) getWeights (clk,weight_val_in_buff,load_weight,weight_adress,weight_valid_buff,read_enable,weight_val_out,weights_loaded);
    
    reg [2:0] state;
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101;
       
    always @ (negedge clk)
    begin
       case(state)
        S0: begin   
            if(load_weights_in && k==0)
            state<=S1;
            if(start&& p==0)
            state<=S2;
            end
        S1: if(weights_loaded && start ) state <= S0;
        S2: begin
            if(count >= (PREVLAYER_COUNT) )       
            state <= S3; 
            end
        S3: begin
            if(bias_added) state<= S4;
            end       
        S4: begin
            if(restart && finish) state <= S0;
            else state<= S4;
            end       
        default: state <= S0;
       endcase
     end
     
    always @ (negedge clk)  
    begin
           
        case(state)
        S0: begin
            if(!rstn)
            begin
            count = 0;
            sum=0;
            product=0;
            finish=0;
            in_data1=0;
            bias_added=0;
            load_weight=0;
            neuron_out=0;
            weight_adress=0;
             instate_2=0;
             p=0;
            x=0;
            i=0;
            end
            end
        S1: begin
                if((part_number ==neuron_part_number)&&(weight_valid) )
                    begin
                        load_weight=1;
                        weight_valid_buff=1;
                        weight_val_in_buff=weight_val_in;
                        k=1;
                    end
            end
        S2: begin 
            instate_2=1;
            load_weight=0;
            finish=0;
            p=1;
            if(!valid_input)
            begin
            read_enable=1;
            weight_adress = count;
            if(weight_val_out!=={(WEIGHT_WIDTH ){1'bx}} && in_data !=={INDATA_WIDTH{1'bx}})
            product = $signed(weight_val_out)*$signed(in_data);
            if(count <= (PREVLAYER_COUNT-1))
            count = count+1;
            if(product!=={INDATA_WIDTH+16{1'bx}})
            begin          
            sum = $signed(sum) + $signed(product);
            end
            end
            end
        S3: begin
            instate_2=0;
            in_data1=0;
            weight_adress = count;
            i=i+1;
            if(weight_adress == PREVLAYER_COUNT&&x==0 && i>=2)
            begin
                bias_from_RAM= weight_val_out;
                x=1;
            if(bias_from_RAM[0]) 
                bias={{(BEFORE_DEC-1){1'b1}},bias_from_RAM,{14{1'b0}}};  
            else if(!bias_from_RAM[0])
                bias={{(BEFORE_DEC-1){1'b0}},bias_from_RAM,{14{1'b0}}};
            sum = $signed(sum)+$signed(bias);
            bias_added=1;
            end
            end
        S4: begin
            instate_2=0;
            weight_adress=0;
            count=0;
            read_enable=0;
            x=0;
            if(sum <0)
            neuron_out =0;
            else
            neuron_out = sum[0:BEFORE_DEC+14];
            finish = 1;
            end
       endcase
     end
endmodule
