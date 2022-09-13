
module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0]	pixelX,
					input logic	[10:0]	pixelY,
					input logic hit_up_triangle,//when leave the coil hits the small triangle
					input logic startOfFrame, 
					input logic new_game,       // if new game , dont show the wall 
					input logic [7:0] levelRGB, // the color of the background walls in this pixel 

					output	logic	[7:0]	BG_RGB,
					output	logic		boardersDR
);

const int	xFrameSize	=	635;
const int	yFrameSize	=	475;
const int	UP_WALL = 30;
const int 	LEFT_WALL = 10;
const int 	RIGHT_WALL = 445;
const int 	BOTTOM_WALL = 430;
const int 	MID_WALL_LEFT = 408;
const int 	MID_WALL_RIGHT = 413;
const int   COLOR_MARTIX_SIZE  = 16*8 ; // 128 
const int startWall = 64; //wall of start point

localparam logic [7:0] BLACK = 8'h00 ;

logic flag_new_game; // if new game, the wall can be off. while the game is running (flag=0) do not open hole
logic [3:0] counter= 4'b0;
	
localparam logic [3:0] DONT_COUNT = 4'b0;
localparam logic [3:0] MIN_COUNT = 4'b0001;
localparam logic [3:0] MAX_COUNT = 4'b1111;
 

// this is a block to generate the background 
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		BG_RGB <= BLACK; 	
		counter <= DONT_COUNT;
		flag_new_game <= 1'b1;
	end 
	else begin

	// defaults 
		BG_RGB <= BLACK; 
		boardersDR <= 	1'b0 ;  
		
		// draw walls
		if (pixelX < LEFT_WALL ||
		    pixelY < UP_WALL ||
			 pixelX > RIGHT_WALL ||
			(pixelX >= MID_WALL_LEFT && pixelX <= MID_WALL_RIGHT && pixelY < BOTTOM_WALL && pixelY > 100 ) || // THE MID WALL IS BETWEEN 30<Y<100
			((pixelY == BOTTOM_WALL) && (pixelX < LEFT_WALL || pixelX > MID_WALL_LEFT))    )                  // BOTTOM WALL (dont draw wall where is flippers)	
			begin 
				boardersDR <= 1'b1 ; // 1 if drawing the boarders
				BG_RGB <= levelRGB;	
			end
		
		// if hit up triangle, close the "gate" in 1 second
		if(hit_up_triangle && flag_new_game) begin
			counter<= MIN_COUNT;
			flag_new_game <= 1'b0; // dont open again till new_game
			
		end 
		
		// increase the counter
		if(startOfFrame && counter != DONT_COUNT && counter < MAX_COUNT)
				counter <= counter + 1;
		
		// if time is up (game started) , block the wall of coil hole
		if(pixelX >= MID_WALL_LEFT && pixelX <= MID_WALL_RIGHT && pixelY>=UP_WALL && pixelY<= 100 && counter== MAX_COUNT) begin
				
				boardersDR <= 1'b1 ; // pulse if drawing the boarders
				BG_RGB <= levelRGB;
		end
		
		//if new game, dont draw the wall of coil hole
		if(new_game) begin
			counter <= DONT_COUNT;
			flag_new_game <= 1'b1;
		end 
 	
		
			
	end
end 
endmodule

