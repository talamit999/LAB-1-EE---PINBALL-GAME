// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	ball_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input logic signed	[10:0] pixelX,// current VGA pixel 
					input logic signed	[10:0] pixelY,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz   
					input logic collision,  //collision if ball hits an object
					input	logic	[3:0] HitEdgeCode, //one bit per edge 
					input logic mushroom_speed_up, //if hit the mushroom increase speed (pulse)
					input logic hit_left_triangle, //if hit left triangle (pulse)
					input logic hit_right_triangle,//if hit right triangle (pulse)
					input logic hit_up_triangle,//if hit up triangle (pulse)
					input logic hit_flipperR,
					input logic hit_flipperL,
					input logic hit_borders,
					input logic four_is_pressed,
					input logic six_is_pressed,
					input logic one_is_pressed,
					input logic three_is_pressed,
					input logic new_game, // while high, the ball is in the beginning position
					input logic push_ball_pulse, // gives head start speed 
					input logic [3:0] HitEdgeCodePredatorPlant,
					input logic flowerIsOpen, // the plant is not occupied
					input logic [3:0] ballNum, // 4 bits because needs to be compared with level
					input logic [3:0] level, // 4bits because we want to reuse the numbers_bitMap

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside 
					output    logic predatored // if eaten by the plant
);


// a module used to generate the  ball trajectory.  

const int INITIAL_X = 100; 
const int INITIAL_Y = 50; 
const int INITIAL_X_SPEED = 0; 
const int INITIAL_Y_SPEED = 0; 
const int MAX_Y_SPEED = 400;
const int MAX_X_SPEED = 400; 
const int  Y_ACCEL = -6; 

const int	FIXED_POINT_MULTIPLIER	=	64;

// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions



//consts
//////////--------------------------------------------------------------------------------------------------------------=
 

const int SPEED_POS =  32; // friction lost speed - positive value
const int SPEED_NEG = -32; // friction lost speed - negative value

const int LOSE_SPEED = 200; // while hit up triangle, lose speed 

const int MUSH_SPEED = 50; 
const int FLIPPER_SPEED = 60; 

const int IN_FRICTION_SPEED = 80; // in friction mode, roll with this speed 

int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;

int offset = 3; // offset in pixels to make sure we dont miss a collision in borders

// counting logic
logic [7:0] counter= 8'b0;
localparam logic [3:0] DONT_COUNT = 8'b0;
localparam logic [3:0] MIN_COUNT = 8'b000001;
localparam logic [3:0] MAX_COUNT = 8'b111111;

// flag on friction mode
logic in_friction_Left = 1'b0;
logic in_friction_Right = 1'b0;

//wall const 
const int	UP_WALL = 30;
const int 	LEFT_WALL = 10;
const int 	RIGHT_WALL = 446;
const int 	BOTTOM_WALL = 430;
const int 	MID_WALL_LEFT = 408;

//new game positions 
const int 	NEW_GAME_X = 413;
const int 	NEW_GAME_Y = 340;

//predator plant - ball positions 
const int 	PLANT_X = 352;
const int 	PLANT_Y = 176;
const int 	PLANT_X_SPEED = -175;
const int 	PLANT_Y_SPEED = -10;

//second ball consts 
const int 	SECOND_BALL_INITIAL_X = 329;
const int 	SECOND_BALL_INITIAL_Y = 31;

//end friction X values 
const int 	LEFT_END_FRICTION_X = 119;  //123
const int 	RIGHT_END_FRICTION_X = 259; //263

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		Yspeed	<= INITIAL_Y_SPEED;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
	end 
	else begin
	// colision Calcultaion 
			
		//if hit flipper while flipper is up, increase speed	 
		if((hit_flipperL && (four_is_pressed || one_is_pressed)) || (hit_flipperR && (six_is_pressed || three_is_pressed))) begin
			
			if(((Yspeed + FLIPPER_SPEED) < MAX_Y_SPEED) && ((Yspeed - FLIPPER_SPEED) > -MAX_Y_SPEED)) begin
				if(Yspeed > 0)
					Yspeed <= Yspeed + FLIPPER_SPEED;
				else Yspeed <= Yspeed - FLIPPER_SPEED; 
			end
			else begin 
				if(Yspeed > 0)
					Yspeed <= MAX_Y_SPEED;
				else Yspeed <= -MAX_Y_SPEED;
			end
			
		end
		
		//if hit mushroom, increase y speed
		if (mushroom_speed_up) begin
			if((Yspeed + MUSH_SPEED) < MAX_Y_SPEED && (Yspeed - MUSH_SPEED) > -MAX_Y_SPEED) begin
				if(Yspeed > 0)
					Yspeed <= Yspeed + MUSH_SPEED ;
				else Yspeed <= Yspeed - MUSH_SPEED; 
			end
			else begin 
				if(Yspeed > 0)
					Yspeed <= MAX_Y_SPEED;
				else Yspeed <= -MAX_Y_SPEED;
			end	
		end
		
		// if hit left triangle, Vx=Vy and Vy=Vx and lose energy (SPEED_LOSS) (Yspeed <= Xspeed;)
		if(hit_left_triangle && (Xspeed > SPEED_POS || Xspeed < SPEED_NEG || Yspeed < SPEED_NEG || Yspeed > SPEED_POS) 
			&& (!in_friction_Left)) begin
			
			if(Yspeed > Xspeed) begin
				if(Xspeed > SPEED_POS)
					Yspeed <= Xspeed + SPEED_NEG;
				else begin 
					if(Xspeed < SPEED_NEG)
						Yspeed <= Xspeed + SPEED_POS;
					else Yspeed <= Xspeed; 
				end
			end
			
		end
		
		
		// if hit right triangle, Vx=-Vy and Vy=-Vx and lose energy (15) (Yspeed <= -Xspeed;)
		if(hit_right_triangle && (Xspeed > SPEED_POS|| Xspeed < SPEED_NEG || Yspeed < SPEED_NEG || Yspeed > SPEED_POS) 
			 && (!in_friction_Right)) begin
			
			if(Xspeed > -Yspeed) begin
				if((-Xspeed) > SPEED_POS)
					Yspeed <= (-Xspeed) + SPEED_NEG;
				else begin
					if((-Xspeed) < SPEED_NEG)
						Yspeed <= (-Xspeed) + SPEED_POS;
					else Yspeed <= (-Xspeed);
				end
			end 
			
		end
		
		// hit the top border
		if(hit_borders && (pixelY <= (UP_WALL + offset))) begin 
			if(Yspeed < 0)
				Yspeed <= -Yspeed;
			else Yspeed <= Yspeed; 
		end
		
		
		
		
		// hit top side of ball  
		if (collision && HitEdgeCode[2] ) begin  
			if (Yspeed < 0) // while moving up
				Yspeed <= -Yspeed ; 
		end
		
		//  hit bottom side of ball 	
		if (collision && HitEdgeCode[0] ) begin  
			if (Yspeed > 0 )//  while moving down
				Yspeed <= -Yspeed ;
		end 
		
		// if in_friction, make a movement "down the hill" 
		if(in_friction_Left) 
			 Yspeed <= IN_FRICTION_SPEED; 	
		if(in_friction_Right)
			 Yspeed <= IN_FRICTION_SPEED;
			 
		// hit the up triangle (at start of the game)
		if(hit_up_triangle) begin 
			Yspeed <= 5 ; 
		end 
		
		// hited the predator plant
		if(counter == MIN_COUNT) begin
			topLeftY_FixedPoint <= PLANT_Y * FIXED_POINT_MULTIPLIER;
			Yspeed <= 0; 
		end 
		
		// on start position, give start speed 
		if (push_ball_pulse) begin
			if(ballNum == 4'b0001)
				Yspeed <= 450;
			if(ballNum == 4'b0010)
				Yspeed <= 500;  
		end
		
		// if s_idle, put ball in start position
		if (new_game) begin
				topLeftY_FixedPoint <= NEW_GAME_Y * FIXED_POINT_MULTIPLIER;
				Yspeed <= 0; 
		end
		
		// ball doesnt exist on level 1
		if (ballNum > level) begin
				Yspeed <= 0;
				topLeftY_FixedPoint <= SECOND_BALL_INITIAL_Y * FIXED_POINT_MULTIPLIER;
		end
		
		// update ball position
		else begin
			if (startOfFrame) begin 
		
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position update 
				
				if (Yspeed < MAX_Y_SPEED && Yspeed > -MAX_Y_SPEED) //  limit the spped while going down 
						Yspeed <= Yspeed  - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick 

			end
		end
		
		
	end
end 

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation of X Axis speed using and position calculate regarding X_direction key or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		Xspeed	<= INITIAL_X_SPEED; 
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		in_friction_Left <= 1'b0;
		in_friction_Right <= 1'b0;
	end
	else begin
		
		
	
		//if hit flipper while flipper is up, increase speed
		if((hit_flipperL && (four_is_pressed || one_is_pressed)) || (hit_flipperR && (six_is_pressed || three_is_pressed))) begin

			if((Xspeed + FLIPPER_SPEED) < MAX_X_SPEED && (Xspeed - FLIPPER_SPEED) > -MAX_X_SPEED) begin
				if(Xspeed > 0)
					Xspeed <= Xspeed + FLIPPER_SPEED ;
				else Xspeed <= Xspeed - FLIPPER_SPEED; 
			end
			else begin 
				if(Xspeed > 0)
					Xspeed <= MAX_X_SPEED;
				else Xspeed <= -MAX_X_SPEED;
			end
	
		end 
		
		//if hit mushroom, increase X speed
		if (mushroom_speed_up) begin
			
			if((Xspeed + MUSH_SPEED) < MAX_X_SPEED && (Xspeed - MUSH_SPEED) > -MAX_X_SPEED) begin
				if(Xspeed > 0)
					Xspeed <= Xspeed + MUSH_SPEED ;
				else Xspeed <= Xspeed - MUSH_SPEED; 
			end
			else begin 
				if(Xspeed > 0)
					Xspeed <= MAX_X_SPEED;
				else Xspeed <= -MAX_X_SPEED;
			end
			
		end
		
		
		// if hit left triangle, Vx=Vy and Vy=Vx and lose energy (SPEED_LOSS) (Xspeed <= Yspeed;)
		if(hit_left_triangle && (Xspeed > SPEED_POS|| Xspeed < SPEED_NEG || Yspeed < SPEED_NEG || Yspeed > SPEED_POS)
			&& (!in_friction_Left)) begin
			
			if(Yspeed > Xspeed) begin 
				if(Yspeed > SPEED_POS)
					Xspeed <= Yspeed + SPEED_NEG;
				else begin
					if(Yspeed < SPEED_NEG)
						Xspeed <= Yspeed + SPEED_POS;
					else Xspeed <= Yspeed; 
				end
			end
			
		end
		
		// if hit right triangle, Vx=-Vy and Vy=-Vx and lose energy (15) (Xspeed <= -Yspeed;)
		if(hit_right_triangle && (Xspeed > SPEED_POS|| Xspeed < SPEED_NEG || Yspeed < SPEED_NEG || Yspeed > SPEED_POS) 
			 && (!in_friction_Right)) begin
			
			if(Xspeed > -Yspeed) begin 
				if((-Yspeed) > SPEED_POS)
					Xspeed <= (-Yspeed) + SPEED_NEG;
				else begin
					if((-Yspeed) < SPEED_NEG)
						Xspeed <= (-Yspeed) + SPEED_POS;
					else Xspeed <= -Yspeed;
				end
			end
			
		end
		
		
		// hit the left border
		if(hit_borders  && pixelX <= (LEFT_WALL + offset)) begin
			if (Xspeed < 0 )
				Xspeed <= -Xspeed;
		end
		
		// hit the right border
		if(hit_borders && pixelX >= (MID_WALL_LEFT - offset)) begin
			if (Xspeed > 0 ) 
				Xspeed <= -Xspeed;
		end
		
		// got hit from left		 
		if (collision && HitEdgeCode[3] ) begin  
			if (Xspeed < 0 ) // while moving left
				Xspeed <= -Xspeed ; // positive move right 
		end
		
		// got hit from right
		if (collision && HitEdgeCode[1] ) begin  
			if (Xspeed > 0 ) //  while moving right
				Xspeed <= -Xspeed  ;  // negative move left    
		end
		
		// hit the up triangle (at start of the game)
		if(hit_up_triangle) begin 
			if(Yspeed + LOSE_SPEED < 0)
				Xspeed <= Yspeed + LOSE_SPEED;
			else Xspeed <= -LOSE_SPEED ; 
		end 
		
		//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&   FRICTION   &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
		// ball hit the triangles very slow, in_friction mode is up
		if((Xspeed <= SPEED_POS && Xspeed >= SPEED_NEG && Yspeed >= SPEED_NEG && Yspeed <= SPEED_POS) &&
			(!in_friction_Left) && (!in_friction_Right)) begin
			
			if(hit_left_triangle)
				in_friction_Left <= 1'b1; 
			if(hit_right_triangle)
				in_friction_Right <= 1'b1;	
		
		end
		
		// end in_friction mode
		if(topLeftX > LEFT_END_FRICTION_X) 
			in_friction_Left <= 1'b0;
		if(topLeftX < RIGHT_END_FRICTION_X) 
			in_friction_Right <= 1'b0;
		 
		
		// if in_friction, make a movement "down the hill" 
		if(in_friction_Left) 
				Xspeed <= IN_FRICTION_SPEED;
		if(in_friction_Right)
				Xspeed <= -IN_FRICTION_SPEED;

		//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  END FRICTION   &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
		
		
		
		// hited the predator plant from left side
		if (HitEdgeCodePredatorPlant[3] && collision && counter == DONT_COUNT && flowerIsOpen)
			counter <= MAX_COUNT;
		if(startOfFrame && counter > DONT_COUNT) 
			counter <= counter - 1;
		if(counter == MIN_COUNT) begin
			topLeftX_FixedPoint <= PLANT_X * FIXED_POINT_MULTIPLIER;
			Xspeed <= PLANT_X_SPEED; 
		end 
		if(counter > DONT_COUNT) 
			predatored <= 1'b1;
		else predatored <= 1'b0;
		
		// ZERO the game parameters
		if (new_game) begin
				Xspeed <= 0; 
				topLeftX_FixedPoint <= NEW_GAME_X * FIXED_POINT_MULTIPLIER;
		end
			
		
		// ball doesnt exist on level 1
		if (ballNum > level ) begin
				Xspeed <= 0;
				topLeftX_FixedPoint <= SECOND_BALL_INITIAL_X * FIXED_POINT_MULTIPLIER;
		end
		
		// update ball position
		else begin
			if (startOfFrame) begin
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; //position update
			end
		end
		
		
	end
end


//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    



endmodule
