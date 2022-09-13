module MushroomBitMap (

					input	logic	clk, 
					input	logic	resetN, 
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY, 
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic hit, 
					input logic startOfFrame,
					input logic isLeft, // '1' - left mushroom, '0' - right mushroom
 
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output   logic speed_up        // if legel hit in mushroom increase ball x_speed
 ) ; 
 
 

//counter logic

logic [3:0] counter = 4'b0000;
localparam logic [3:0] ZERO = 4'b0;
localparam logic [3:0] MAX_COUNT = 4'b1111;


// generating the bitmap 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel  
logic[0:31][0:31][7:0] object_colors = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hdb,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hda,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdb,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc9,8'hd1,8'h80,8'h80,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd2,8'hc8,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd2,8'hd2,8'hc8,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc9,8'hd1,8'hd1,8'hd2,8'hd2,8'hda,8'hdb,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd2,8'hd2,8'hda,8'hc8,8'h00},
	{8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hc8,8'h00},
	{8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hdb,8'hd1},
	{8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hc8},
	{8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h88,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hc8},
	{8'h92,8'h92,8'hd2,8'hd2,8'h92,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hc8},
	{8'hd2,8'hd2,8'hd2,8'hd2,8'hd2,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hc8},
	{8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hc8},
	{8'hda,8'hda,8'hda,8'hda,8'hda,8'h91,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hc8},
	{8'hda,8'hda,8'hda,8'hda,8'hda,8'hd1,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hda,8'hda},
	{8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hd1,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hc9,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h88,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hda,8'hc8,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h88,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hd1,8'hd1,8'hd1,8'hd2,8'hd2,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc8,8'hc9,8'hd1,8'hd1,8'hd2,8'hc8,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc8,8'hc8,8'hc8,8'hc9,8'hd1,8'hd1,8'hc8,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdb,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hc8,8'hc9,8'hd1,8'hc8,8'hc8,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hdb,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h89,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hdb,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};


 // pipeline (ff) to get the pixel color from the array 	 
//////////--------------------------------------------------------------------------------------------------------------= 
always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		RGBout <=	TRANSPARENT_ENCODING;
		counter <= ZERO;
		speed_up <= 1'b0;
	end 
	else begin 
		// default 
		RGBout <= TRANSPARENT_ENCODING ;  
		speed_up <= 1'b0;  
		
		//legal hit in mushroom, turn into pused mode until counter is done
		if(hit && (counter == ZERO)) begin 	
			counter <= MAX_COUNT;
			speed_up <= 1'b1; //increase speed
		end
		
		//decrease counter on new frame
		if(startOfFrame) begin 
			if(counter > ZERO) 
				counter <= counter - 1; 
		end
		
		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			
			if(isLeft) begin //left mushroom
				
				if((counter > ZERO) && (offsetX <= 11'd26)) // if pushed , do not ask to draw on 5 most-right colums 
					RGBout <= object_colors[offsetY][offsetX+5]; // the bitmap is shift 5 bits left (pushed mode) 
				if(counter == ZERO)
					RGBout <= object_colors[offsetY][offsetX];
			end
			
			else begin //right mushroom
				
				if((counter > ZERO) && (offsetX >= 11'd5)) // if pushed , do not ask to draw on 5 most-left colums 
					RGBout <= object_colors[offsetY][31-(offsetX-5)]; // the bitmap is shift 5 bits left (pushed mode) 
				if(counter == ZERO)
					RGBout <= object_colors[offsetY][31-offsetX];
			end
			
		end  	 
		 
	end 
end 
 
//////////--------------------------------------------------------------------------------------------------------------= 
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap  
 
endmodule
