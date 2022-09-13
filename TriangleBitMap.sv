module TriangleBitMap (

					input	logic	clk, 
					input	logic	resetN, 
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY, 
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic is_left,
					input logic is_up, // if up triangle, be '1' (has priority over is_left)
					input logic [7:0] levelRGB, // the requested color to draw (according to level)
 
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ; 
 
 localparam logic [7:0] TRANSPARENT = 8'h00 ;// RGB value in the bitmap representing a transparent pixel
 			
  
 // pipeline (ff) to get the pixel color from the array 	 
//////////--------------------------------------------------------------------------------------------------------------= 
always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		RGBout <=	TRANSPARENT; 

	end 
	else begin 
		RGBout <= TRANSPARENT; // default  

		if (InsideRectangle == 1'b1 ) begin // inside an external bracket
			
			if(is_up) begin // first priority - is_up
				if(offsetX >= offsetY) begin 
					RGBout <= levelRGB;
				end
			end
			
			else begin //second priority - is_left
				if(is_left) begin
					if(offsetX < offsetY) begin 
						RGBout <= levelRGB;
					end	
				end
				else begin // right triangle 
					if( offsetX + offsetY > 8'd128) begin
						RGBout <= levelRGB; 
					end
				end
			end
			
		end
		 
	end 
end 
 
//////////--------------------------------------------------------------------------------------------------------------= 
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap  
 
endmodule
