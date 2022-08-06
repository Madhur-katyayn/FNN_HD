`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module testbench();
parameter WEIGHT_WIDTH=16, PART_NO_WIDTH=7, NN1=40, NN2=10, NN3=10, NN4=10, NO_OF_INPUTS=784, INDATA_WIDTH=16;
parameter Depth=NO_OF_INPUTS*NN1+NN1+NN1*NN2+NN2 +NN2*NN3+NN3+NN3* NN4+NN4;
parameter S0=0, S1=1,S2=2,S3=3;
reg start_FNN, restart, clk, load_weights, ready_in,weight_valid;
reg signed [0:WEIGHT_WIDTH+PART_NO_WIDTH-1]weight_bus;
wire [0:3]max;
wire finish_FNN,FNN_ready;
reg x,y;
reg t;
integer shift;
integer i=0;
integer no_of_images;
integer correctly_identified;
integer actual_value;
real no_of_images_buff;
real correctly_identified_buff;
real actual_value_buff;
real percentage_accuracy;
reg [0:64]count;
reg [0:64]count2;
reg [INDATA_WIDTH-1:0]input_image;
reg [0:WEIGHT_WIDTH+PART_NO_WIDTH-1] weight_bus_memory[0:Depth-1];
reg [INDATA_WIDTH-1:0]indata_mem[0:(140*NO_OF_INPUTS)-1];
reg [0:1]state;
reg loaded_in_memory;
wire FNN_ready_to_accept;
control_FNN DUT(start_FNN ,restart, clk,weight_bus, load_weights ,weight_valid, ready_in ,input_image,max, finish_FNN,FNN_ready,FNN_ready_to_accept );
initial
begin
clk=0;
count=0;
count2=0;
end


always 
#1 clk=~clk;

 initial
		begin
	        $readmemb("weights_and_biases.mif", weight_bus_memory);
	        $readmemb("input_test_data.mif", indata_mem);
	         loaded_in_memory=1;
	    end
always @(negedge clk)
begin
case(state)
S0: begin
    if(loaded_in_memory && x==0)
    state<=S1;
    end
S1: begin
    if(FNN_ready )
    state<=S2;
    end
S2: begin
    if(y==0 && i==(NO_OF_INPUTS))
    state<=S3;
    end
S3: begin
    if(FNN_ready_to_accept && y==1)
    state<=S2;
    end
default state<=S0;
endcase
end

always @(negedge clk)
begin
case(state)
S0: begin
    restart=0;
    shift=0;
    x=0;
    no_of_images=0;
    actual_value=0;
    correctly_identified=0;
    percentage_accuracy=0;
    end
S1: begin
    if(count==3)
    load_weights=1;
    if(x==0)
    begin
    if(count>3)
    begin
    weight_valid=1;
    weight_bus=weight_bus_memory[count2];
    count2=count2+1;
    end
    count=count+1;
    end
    end
    
S2: begin
    start_FNN=1;
    x=1;
    t=0;
    weight_valid=0;
    load_weights=0;
    y=0;
    ready_in=1;
    
    if(FNN_ready_to_accept)
    begin
    if(i<NO_OF_INPUTS)
    begin
    input_image=indata_mem[i+shift] ;
    i=i+1;
    end
    end
    end
S3: begin
    restart=1;
    y=1;
    if(t==0)
    begin
        shift=shift+NO_OF_INPUTS;
        if(max!==4'bx)
        begin
        no_of_images=no_of_images+1;
        no_of_images_buff=no_of_images;
        if(max==actual_value)
            begin
            correctly_identified=correctly_identified+1;
            correctly_identified_buff=correctly_identified;
            end
        if(((no_of_images)%20)==0)
            begin
            actual_value=actual_value+1;
            actual_value_buff=actual_value;
            end
        end
        percentage_accuracy=correctly_identified_buff/no_of_images_buff*100;
        t=1;
        if(no_of_images_buff==141)
        $stop;
    end
    i=0;
    end
endcase
end
endmodule
