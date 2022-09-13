module max4 (

					input	logic	clk, 
					input	logic	resetN, 
					input	logic	[7:0] RGB1,
					input logic [7:0] RGB2,
					input logic [7:0] RGB3,
					input logic [7:0] RGB4,
 
					output logic [7:0] max    
 ) ; 
 
 localparam logic [7:0] TRANSPARENT = 8'h00 ;

always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		max <=	TRANSPARENT; 
	end 
	else begin  
			
			//find maximum 
			if(RGB1 > TRANSPARENT)
				max <= RGB1;
			else begin
					if(RGB2 > TRANSPARENT)
						max <= RGB2;
					else begin
						if(RGB2 > TRANSPARENT)
							max <= RGB3;
						else max <= RGB4;
					end
			end
	end 
end   

 
endmodule
