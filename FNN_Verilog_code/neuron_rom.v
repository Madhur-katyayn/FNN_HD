
module neuron_RAM
	#(
		parameter Depth             = 169,
		          RAM_WIDTH         = 16,
		          RAM_ADDR_BITS     = 10
	)
	(
	input							clock,
	input     signed [RAM_WIDTH-1:0]  weights_in,
	input                           write_enable,
    input 		[RAM_ADDR_BITS-1:0]	address,
    input                           weight_valid,
    input                           read_enable,
	output reg signed [RAM_WIDTH-1:0] 	weights_out,
	output reg                        loaded
	);
	
   
   
   (* RAM_STYLE="BLOCK" *)
   reg signed [RAM_WIDTH-1:0] weight_mem [0:Depth];

   integer counter=0;
   integer file,file1,i;
    
   always @(negedge clock)
    begin
     if (write_enable && weight_valid)
     begin
        if(counter==0)
        begin
            for(i=0;i<=Depth;i=i+1)
            begin
                weight_mem[i]=0;
            end
        end
        if((counter<=Depth)&&(weights_in!==16'bx))
        begin
            weight_mem[counter]=weights_in;
            counter=counter+1;
        end
        if(counter>Depth)
            loaded = 1;
    end
    else if(read_enable)
    begin
            weights_out=weight_mem[address];
    end
    end
endmodule