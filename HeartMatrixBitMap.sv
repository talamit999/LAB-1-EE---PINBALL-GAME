// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen FWbruary  2021  
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	HeartMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic [1:0] num_of_hearts,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel 
localparam logic [7:0] RED = 8'hE0 ;

// array to display hearts left 
logic [0:7]  Arr_Hearts= {8'b	00111000};



// a heart bitmap
logic[0:31][0:31] object_colors = {
	32'b00000111111000000000011111100000,
	32'b00011111111100000000111111110000,
	32'b00111111111110000011111111111100,
	32'b00111111111111000011111111111100,
	32'b01111111111111100111111111111110,
	32'b01111111111111101111111111111110,
	32'b11111111111111111111111111111111,
	32'b11111111111111111111111111111111,
	32'b11111111111111111111111111111111,
	32'b11111111111111111111111111111111,
	32'b11111111111111111111111111111111,
	32'b11111111111111111111111111111111,
	32'b11111111111111111111111111111110,
	32'b01111111111111111111111111111110,
	32'b01111111111111111111111111111110,
	32'b01111111111111111111111111111100,
	32'b00111111111111111111111111111100,
	32'b00111111111111111111111111111100,
	32'b00011111111111111111111111111000,
	32'b00011111111111111111111111110000,
	32'b00001111111111111111111111110000,
	32'b00000111111111111111111111100000,
	32'b00000011111111111111111111000000,
	32'b00000001111111111111111110000000,
	32'b00000001111111111111111100000000,
	32'b00000000011111111111111000000000,
	32'b00000000011111111111110000000000,
	32'b00000000001111111111100000000000,
	32'b00000000000011111111000000000000,
	32'b00000000000001111110000000000000,
	32'b00000000000000111100000000000000,
	32'b00000000000000010000000000000000};

 

// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
		case(num_of_hearts)
		2'b11: Arr_Hearts <= {8'b 00111000};
		
		2'b10: Arr_Hearts <= {8'b 00011000};
		
		2'b01: Arr_Hearts <= {8'b 00001000};
			
		2'b00: Arr_Hearts <= {8'b 00000000};
		endcase
			
		if (InsideRectangle == 1'b1 && Arr_Hearts[offsetX[10:5]] ) begin
			if(object_colors[offsetY][offsetX[4:0]]) begin
				RGBout <= RED;
			end
		end
	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   



endmodule

