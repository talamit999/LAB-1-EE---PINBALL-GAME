// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	BallBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic game_over, // is '1' when game_over. in this case do not draw ball
					input	logic	predatored,
					input logic [3:0] ball_num, // 4 bits to indicate if ball 1, 2, or 3
					input logic [3:0] level, // 4 bits to indicate which level it is
					input logic win_game, // if game is won do not draw ball

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
				
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

localparam logic [7:0] GRAY = 8'hB6 ;


localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel  

// generating a ball bitmap
logic[0:31][0:31] object_colors = {
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000111111111000000000000,
	32'b00000000001111111111110000000000,
	32'b00000000011111111111111000000000,
	32'b00000000111111111111111100000000,
	32'b00000001111111111111111110000000,
	32'b00000001111111111111111110000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000011111111111111111111000000,
	32'b00000001111111111111111110000000,
	32'b00000001111111111111111110000000,
	32'b00000000111111111111111100000000,
	32'b00000000011111111111111000000000,
	32'b00000000001111111111110000000000,
	32'b00000000000011111111000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000};


 

//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
		  {16'hC446,     
			16'h8C62,    
			16'h8932,
			16'h9113};

 

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 4'h0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  
			if(object_colors[offsetY][offsetX]==1'b1) begin 
				if(ball_num <= level) 
					RGBout <= GRAY; //paint gray
			end 
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING) && !game_over && !predatored & !win_game ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule