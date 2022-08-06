`timescale 1ns / 1ps

module control_FNN #(parameter INDATA_WIDTH = 16, NN_L1=40, NN_L2=10, NN_L3=10, NN_L4=10, NO_INPUTS=784,WEIGHT_WIDTH=16, PART_NO_WIDTH=7)(
    input start_FNN,
    input restart,
    input clk,
    input signed [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weight_bus,
    input load_weights,
    input weight_valid,
    input ready_in,
    input [INDATA_WIDTH-1:0]input_image,
    output reg [0:3]max,
    output reg finish_FNN,
    output reg FNN_ready,
    output reg FNN_ready_to_accept
);
 reg start1,rstn1,restart1,start2,rstn2,restart2;  
 reg start3,rstn3,restart3,start4,rstn4,restart4;
 reg shift1, shift2,shift3, shift4;
 reg [INDATA_WIDTH-1:0]layer1_input;
 reg [INDATA_WIDTH+2:0]layer2_input;
 reg [INDATA_WIDTH+3+2:0]layer3_input;
 reg [INDATA_WIDTH+3+3+2:0]layer4_input;
 reg [INDATA_WIDTH+3+3+3+2:0] max_finder_input;
 reg stop_iteration=0;
 reg signed [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weights_bus_buff;
 reg weight_valid_buff;
 reg load_weights_buff;
 reg in_state_0;
 reg stay_in_state2;
 reg start_maxfinder;
 reg  max_finder_reset_allowed;
 wire transferred1, transferred2,transferred3,transferred4;
 wire [INDATA_WIDTH+2:0]layer_1_out; 
 wire [INDATA_WIDTH+3+2:0]layer_2_out; 
 wire [INDATA_WIDTH+3+3+2:0]layer_3_out;
 wire [INDATA_WIDTH+3+3+3+2:0]layer_4_out;
 reg valid_input1, valid_input2, valid_input3,valid_input4, valid_input5;
 wire finished1;
 wire finished2;
 wire finished3;
 wire finished4;
 wire [0:3]maximum;
 reg find_max;
 reg control_reset;
 wire maxfound;
 wire layer_1_ready, layer_2_ready, layer_3_ready, layer_4_ready;
 wire [0:NN_L1-1]neurons_instate_L1;
 wire [0:NN_L2-1]neurons_instate_L2;
 wire [0:NN_L3-1]neurons_instate_L3;
 wire [0:NN_L4-1]neurons_instate_L4;
integer count=1; 
integer count2=1;
integer count3=1;
integer count4=1; 
Layer1  #(.INDATA_WIDTH(INDATA_WIDTH), .NN1(NN_L1),.WEIGHT_WIDTH(WEIGHT_WIDTH),.PREVLAYER_COUNT(NO_INPUTS),.BEFORE_DEC(4), .AFTER_DEC(28),.PART_NO_WIDTH(PART_NO_WIDTH)) L1(
        .clk(clk),
        .rst1(rstn1),
        .start1(start1),
        .restart1(restart1),
        .shift1(shift1),
        .input_data(layer1_input),
        .valid_input(valid_input1),
        .weight_bus(weights_bus_buff),
        .load_weights(load_weights),
        .weight_valid(weight_valid),
        .neurons_finished1(finished1),
        .layer_1_SOUT(layer_1_out),
        .transferred1(transferred1),
        .layer_1_ready(layer_1_ready),
        .neurons_instate_2(neurons_instate_L1)
        );
          

Layer2 #(.INDATA_WIDTH(INDATA_WIDTH+3), .NN2(NN_L2),.WEIGHT_WIDTH(WEIGHT_WIDTH),.PREVLAYER_COUNT(NN_L1),.BEFORE_DEC(7), .AFTER_DEC(28),.PART_NO_WIDTH(PART_NO_WIDTH))L2(
        .clk(clk),
        .rst2(rstn2),
        .start2(start2),
        .restart2(restart2),
        .shift2(shift2),
        .input_data(layer2_input),
        .valid_input(valid_input2),
        .weight_bus(weights_bus_buff),
        .load_weights(load_weights),
        .weight_valid(weight_valid),
        .neurons_finished2(finished2),
        .layer_2_SOUT(layer_2_out),
        .transferred2(transferred2),
        .layer_2_ready(layer_2_ready),
        .neurons_instate_2(neurons_instate_L2)
        );
     
     
Layer3 #(.INDATA_WIDTH(INDATA_WIDTH+3+3), .NN3(NN_L3),.WEIGHT_WIDTH(WEIGHT_WIDTH),.PREVLAYER_COUNT(NN_L2),.BEFORE_DEC(10), .AFTER_DEC(28),.PART_NO_WIDTH(PART_NO_WIDTH))L3(
        .clk(clk),
        .rst3(rstn3),
        .start3(start3),
        .restart3(restart3),
        .shift3(shift3),
        .input_data(layer3_input),
        .valid_input(valid_input3),
        .weight_bus(weights_bus_buff),
        .load_weights(load_weights),
        .weight_valid(weight_valid),
        .neurons_finished3(finished3),
        .layer_3_SOUT(layer_3_out),
        .transferred3(transferred3),
        .layer_3_ready(layer_3_ready),
        .neurons_instate_2(neurons_instate_L3)
        );
        
Layer4 #(.INDATA_WIDTH(INDATA_WIDTH+3+3+3), .NN4(NN_L4),.WEIGHT_WIDTH(WEIGHT_WIDTH),.PREVLAYER_COUNT(NN_L3),.BEFORE_DEC(13), .AFTER_DEC(28),.PART_NO_WIDTH(PART_NO_WIDTH))L4(
        .clk(clk),
        .rst4(rstn4),
        .start4(start4),
        .restart4(restart4),
        .shift4(shift4),
        .input_data(layer4_input),
        .valid_input(valid_input4),
        .weight_bus(weights_bus_buff),
        .load_weights(load_weights),
        .weight_valid(weight_valid),
        .neurons_finished4(finished4),
        .layer_4_SOUT(layer_4_out),
        .transferred4(transferred4),
        .layer_4_ready(layer_4_ready),
        .neurons_instate_2(neurons_instate_L4)
        );

max_finder #(.INDATA_WIDTH(INDATA_WIDTH+3+3+3+3),.NN4(NN_L4),.PREVLAYER_COUNT(NN_L4)) max_value(
.clk(clk),
.start_maxfinder(start_maxfinder),
.predicted_output(maximum),
.found_max(maxfound),
.input_data(max_finder_input),
.max_finder_reset_allowed(max_finder_reset_allowed)
);
   reg [3:0] state_FNN=0 ;
    reg loaded=0;
    parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b010, S3 = 4'b0011,S4=4'b0100,S5=4'b0101,S6=4'b0110, S7=4'b0111, S8=4'b1000;
    integer i=0,file;
    always @ (negedge clk)
    begin
       case(state_FNN)
        S0: begin
            if(load_weights && loaded==1 )
            state_FNN<=S1;
            else if(start_FNN == 1&& loaded==1 && (ready_in)&& in_state_0==0)
            state_FNN <= S2;
            end
        S1: begin
            if(start_FNN && FNN_ready)
            state_FNN<=S2;
            end
        S2: begin
            if(finished1 && i>= NO_INPUTS && !stay_in_state2) state_FNN<=S3;
            end
        S3: begin
            if(transferred1) state_FNN<=S4;
            end
        S4: begin
            if(transferred2 && finished1 && finished3 && i>= NO_INPUTS && !stay_in_state2) state_FNN<=S5;
            end      
        S5: begin
            if(transferred3 && transferred1 && finished2 && finished4) state_FNN<=S6;
            end
        S6: begin
            if(maxfound && transferred4 && finished1 && transferred2 && finished3 && i>= NO_INPUTS && !stay_in_state2) state_FNN<=S7;
            end
        S7: begin
            if(transferred3 && transferred1 && finished4 && finished2) state_FNN<=S8;
            end    
        S8: if(maxfound && restart &&  transferred4 && finished1 && transferred2 && finished3 && i>= NO_INPUTS && !stay_in_state2) state_FNN<=S7;
        default: 
            if(!stop_iteration)
                state_FNN <= S0;
      endcase
     end
    
    always @ (negedge clk)  
    begin
        case(state_FNN)
        S0: begin
             loaded=1;
             i=0;
             count=1;
             count2=1;
             count3=1;
             in_state_0=0;
             count4=1;
             finish_FNN=0;
             restart1=0;
             restart2 =0;
             restart3 =0;
             restart4 =0;
             valid_input1=1;
              valid_input2=1;
               valid_input3=1;
               valid_input4=1;
               layer1_input=0;
               layer2_input=0;
               layer3_input=0;
               layer4_input=0;
               FNN_ready_to_accept=0;
               stay_in_state2=1;
            end
        S1: begin
            in_state_0=1;
            if(weight_valid)
            begin
                weights_bus_buff=weight_bus;
            end
            if(layer_1_ready && layer_2_ready && layer_3_ready && layer_4_ready)
                FNN_ready=1;
            end
        S2: begin
            
            rstn1=0;
            in_state_0=1; 
            if(restart)
            restart1=1;
            else
            restart1=0;
            start1=1;
            if(neurons_instate_L1=={(NN_L1){1'b1}})
            begin
                valid_input1=0;
                if(count==2)
                FNN_ready_to_accept=1;
                if(count>2&&i< NO_INPUTS)
                begin
                layer1_input=input_image;
                i=i+1;
                end
                else
                layer1_input=0;
                count=count+1;
                
            end
            if(i==NO_INPUTS)
            begin
            FNN_ready_to_accept=0;
            stay_in_state2=0;
            end
            end
        S3: begin
            layer1_input=0;
            stay_in_state2=1;
            in_state_0=1;
            count=0;
            FNN_ready_to_accept=0;
            rstn2=0;
            i=0;
            start1=0; 
            restart1=0;
            valid_input1=1;
            layer2_input=layer_1_out;
            if(restart)
            restart2=1;
            else
            restart2=0;
            start2=1;
            if(neurons_instate_L2=={(NN_L2){1'b1}})
            begin
                
                valid_input2=0;
                shift1=1;
            end
            end
        S4: begin
            //Pipelining starts from here 
            // Layer1 will receive the input image data because it would have completed its work till now.
            rstn1=0;
            in_state_0=1; 
            if(restart)
            restart1=1;
            else
            restart1=0;
            start1=1;
            if(neurons_instate_L1=={(NN_L1){1'b1}})
            begin
                valid_input1=0;
                FNN_ready_to_accept=1;
                if(count>1&&i< NO_INPUTS)
                begin
                layer1_input=input_image;
                i=i+1;
                end
                else
                layer1_input=0;
                count=count+1;
                
            end
            if(i==NO_INPUTS)
            begin
            FNN_ready_to_accept=0;
            stay_in_state2=0;
            end
        
        
            // Layer 2 will continue to shift the data to Layer 3
            in_state_0=1;
            layer2_input=0;
            rstn3=0;
            if(restart)
            restart3=1;
            else
            restart3=0;
            valid_input2=1;
            start2=0;
            shift1=0;
            if(finished2)
            begin
                layer3_input=layer_2_out;
                start3=1;
                restart2=0;
                if(neurons_instate_L3=={(NN_L3){1'b1}})
                begin
                shift2=1;
                valid_input3=0;
                count3=count3+1;
                end
            end
            if(finished3)
            begin
            rstn3=0;
            start3=0;
            shift2=0;
            valid_input3=1;
            end
            end
            
        S5: begin
            // Since Layer1 is ready again with its data so it will start shifting its calculated data to Layer2
            layer1_input=0;
            in_state_0=1;
            stay_in_state2=1;
            FNN_ready_to_accept=0;
            count=0;
            rstn2=0;
            i=0;
            start1=0; 
            restart1=0;
            valid_input1=1;
            layer2_input=layer_1_out;
            if(restart)
            restart2=1;
            else
            restart2=0;
            start2=1;
            if(neurons_instate_L2=={(NN_L2){1'b1}})
            begin
                valid_input2=0;
                shift1=1;
            end
            // Since Layer3 has finished its work so it will shift its data to layer4.
            rstn4=0;
            in_state_0=1;
            layer3_input=0;
            valid_input3 =1;
            valid_input1=1;
            start3=0;
            shift2=0;
            if(restart)
            restart4=1;
            else
            restart4=0;
            if(finished3)
            begin
            layer4_input=layer_3_out;
            start4=1;
            restart3=0;
            if(neurons_instate_L4=={(NN_L4){1'b1}})
            begin
            shift3=1;            
            valid_input4=0;
            count4=count4+1;
            end
            end
            if(finished4)
            begin
            rstn4=1;
            start4=0;
            shift3=0;
            valid_input4=1;
            end
            max_finder_reset_allowed=1;
            end
        S6: begin
            // Since Layer2 has finished so it will transfer its data to layer3.
            in_state_0=1;
            layer2_input=0;
            rstn3=0;
            if(restart)
            restart3=1;
            else
            restart3=0;
            valid_input2=1;
            start2=0;
            shift1=0;
            if(finished2)
            begin
                layer3_input=layer_2_out;
                start3=1;
                restart2=0;
                if(neurons_instate_L3=={(NN_L3){1'b1}})
                begin
                
                shift2=1;
                valid_input3=0;
                count3=count3+1;
                end
              end
            if(finished3)
            begin
            rstn3=1;
            start3=0;
            shift2=0;
            valid_input3=1;
            end
        // Layer1 has finished its work again so it will accept the input data again
             rstn1=0;
            in_state_0=1; 
            if(restart)
            restart1=1;
            else
            restart1=0;
            start1=1;
            if(neurons_instate_L1=={(NN_L1){1'b1}})
            begin
                valid_input1=0;
                FNN_ready_to_accept=1;
                if(count>1&&i< NO_INPUTS)
                begin
                layer1_input=input_image;
                i=i+1;
                end
                else
                layer1_input=0;
                count=count+1;
                
            end
            if(i==NO_INPUTS)
            begin
            FNN_ready_to_accept=0;
            stay_in_state2=0;
            end
            // Layer4 will transfer its data to max_finder
            in_state_0=1;
            layer4_input=0;
            valid_input4=1;
            start4=0;
            shift3=0;
            if(finished4)
            begin
            restart4=0;
            max_finder_input=layer_4_out;
            shift4=1;
            start_maxfinder=1;
            stop_iteration=1;
            end
            max_finder_reset_allowed=0;
            control_reset=0;
            if(maxfound)
            begin
            start_maxfinder=0;
            shift4=0;
            end
            end
        S7: begin
            // Layer4 has completed its work so it is ready to accept from Layer3 which is ready.
            rstn4=0;
            in_state_0=1;
            layer3_input=0;
            valid_input3 =1;
            start3=0;
            shift2=0;
            if(restart)
            restart4=1;
            else
            restart4=0;
            if(finished3)
            begin
            layer4_input=layer_3_out;
            start4=1;
            restart3=0;
            if(neurons_instate_L4=={(NN_L4){1'b1}})
            begin
            shift3=1;            
            valid_input4=0;
            count4=count4+1;
            end
            end
            if(finished4)
            begin
            rstn4=1;
            start4=0;
            shift3=0;
            valid_input4=1;
            end
            ///////////////////////////////////////////////////////            
            // Since Layer1 is also ready with its data and Layer2 has completed its work so data will be transferred from 1 to 2.
            layer1_input=0;
            in_state_0=1;
            FNN_ready_to_accept=0;
            stay_in_state2=1;
            count=0;
            rstn2=0;
            i=0;
            start1=0; 
            restart1=0;
            valid_input1=1;
            layer2_input=layer_1_out;
            if(restart)
            restart2=1;
            else
            restart2=0;
            start2=1;
            if(neurons_instate_L2=={(NN_L2){1'b1}})
            begin
                valid_input2=0;
                shift1=1;
            end
            //////////////////////////////////////////////////////
            if(control_reset==0)
            begin
            max_finder_reset_allowed=1;
            control_reset=1;
            end
            in_state_0=1;
            shift4=0;
            max=maximum;
            finish_FNN=1;
            count2=1;
            end
        S8: begin
            max_finder_reset_allowed=0;
            finish_FNN=0;
            control_reset=0;
            // Layer1 has finished its work again so it will accept input data.
            rstn1=0;
            in_state_0=1; 
            if(restart)
            restart1=1;
            else
            restart1=0;
            if(finished1!=0)
            start1=1;
            else if(finished1==0)
            start1=0;
            if(neurons_instate_L1=={(NN_L1){1'b1}})
            begin
                valid_input1=0;
                FNN_ready_to_accept=1;
                if(count>1&&i< NO_INPUTS)
                begin
                layer1_input=input_image;
                i=i+1;
                end
                else
                layer1_input=0;
                count=count+1;
            end
            if(i==NO_INPUTS)
            begin
            FNN_ready_to_accept=0;
            stay_in_state2=0;
            end
            /////////////////////////////////////////////////////
            // Layer4 will be ready with its data so it will start transferring to maxfinder.
            in_state_0=1;
            layer4_input=0;
            valid_input4=1;
            start4=0;
            shift3=0;
            if(finished4)
            begin
            restart4=0;
            max_finder_input=layer_4_out;
            if(count2>=3)
            start_maxfinder=1;
            count2 =count2+1;
            shift4=1;
            stop_iteration=1;
            end
            if(maxfound)
            begin
            start_maxfinder=0;
            shift4=0;
            end
            //////////////////////////////////////////////////////
            // Layer2 is also ready with its data so it will start transferring to layer3.
             in_state_0=1;
            layer2_input=0;
            rstn3=0;
            if(restart)
            restart3=1;
            else
            restart3=0;
            valid_input2=1;
            start2=0;
            shift1=0;
            if(finished2)
            begin
                layer3_input=layer_2_out;
                start3=1;
                restart2=0;
                if(neurons_instate_L3=={(NN_L3){1'b1}})
                begin
                shift2=1;
                valid_input3=0;
                count3=count3+1;
                end  
            end
            if(finished3)
            begin
            rstn3=0;
            start3=0;
            shift2=0;
            valid_input3=1;
            end
            in_state_0=1;
            end
       endcase
     end

endmodule
