// (c) Technion IIT, Department of Electrical Engineering 2018 
// Updated by Mor Dahan - January 2022
// 
// Implements the state machine of the bomb mini-project
// FSM, with present and next states

module state_machine_game
	(
	input logic clk, 
	input logic resetN, 
	input logic two_is_pressed,
	input logic enter_is_pressed,
	input logic start_of_frame,
	input logic ball_DR,
	input logic ball2_DR,
	input logic [10:0] ball_pixel_y,    //to know if we lost the ball
	input logic level_up,
	
	
	output logic game_over,             // is '1' while the state is s_game_over
	output logic game_over_pulse,       // pulse when the player loses (game over)
	output logic [1:0] coil_state,      // 0=not pressed, 1=half pressed, 2=all pressed
	output logic score_is_running,      //when 0 score is zero
	output logic new_game,              // return the ball to the beginning point
	output logic push_ball_pulse,       // we get pulse when leave two on s_arm_2- give the ball velocity
	output logic win_game,		         //1 while still in s_win_game
	output logic [1:0] num_of_hearts,   //for hearts_display
	output logic [3:0] level	         // 4 bits because number_bitmap should get 4 bits
	);
	
	
logic [1:0] hearts_in = 2'b11; //inner wire
logic [1:0] level_in = 2'b00;  //inner wire: 0 is the first stage and 11 is win game

//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [3:0] {s_idle, s_arm_1, s_arm_2, s_run_game, s_win_game, s_zero_score, s_game_over } ps_state, ns_state;
	logic lost_ball;
	logic [3:0] counter=4'b0;
	
	localparam logic [3:0] ZERO = 4'b0;
	localparam logic [3:0] MAX_COUNT = 4'b1111;
	localparam logic [8:0] END_OF_AREA = 9'd475;
	localparam logic [3:0] LEVEL_ONE = 2'b00;
 	
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
	   
   if ( !resetN ) begin // Asynchronic reset
		ps_state <= s_idle;
		hearts_in <= 2'b11;
		level_in <= 2'b00;
   end
	
	else begin 		// Synchronic logic FSM
		ps_state <= ns_state;
		if(ps_state==s_idle)
			counter<=ZERO;
		if(ps_state==s_arm_1) begin
			if(start_of_frame && counter< MAX_COUNT)
					counter<=counter+1;
		end
		
		if(ps_state==s_arm_2 && ns_state == s_run_game)//just left the two key so we want the ball to accelerate
			push_ball_pulse<=1'b1;//pulse
		else push_ball_pulse<=1'b0;
		
		
		if(ps_state==s_run_game && ns_state == s_game_over)
			game_over_pulse<=1'b1;//create game over pulse for the sound unit
		else game_over_pulse<=1'b0;
		
		if((ball_DR || ball2_DR) && (ball_pixel_y == END_OF_AREA))//one of the balls lost 
			lost_ball <= 1'b1;
		else lost_ball <= 1'b0;
		
		if(lost_ball) begin//one heart is gone
				hearts_in <= hearts_in - 1;
		end
		
		if(level_up)
			level_in <= level_in + 1; 
			
		if(ps_state == s_zero_score) begin
			hearts_in <= 2'b11;
			level_in <= LEVEL_ONE;
		end 
			
		
		
		if(ps_state == s_game_over)  
			hearts_in <= 2'b00;
		 
	end
end // always sync
	
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	
always_comb // Update next state and outputs
	begin
	// set all default values 
		ns_state = ps_state; 
		game_over=1'b0;
		coil_state=2'b0;
		score_is_running=1'b0;
		new_game=1'b0;
		win_game=1'b0;

		case (ps_state)
		
			//Note: the implementation of the idle state is already given you as an example
			s_idle: begin
				score_is_running=1'b1;
				new_game=1'b1;
				if (two_is_pressed) //kfiz mitkavez
					ns_state = s_arm_1; 
				
			end // idle
						
			s_arm_1: begin //in this state we see the kfiz mitkavez
				score_is_running=1'b1;
				coil_state=2'b01;//half pressed
				if (two_is_pressed && counter==4'b1111) //kfiz hitkavez maximum
					ns_state=s_arm_2;	
				if(!two_is_pressed)
					ns_state=s_idle;
			end // arm1
				
			s_arm_2: begin //in this state we see the kfiz mitkavez
				score_is_running=1'b1;
				coil_state=2'b10;//all pressed
				if (two_is_pressed==1'b0) //when release the button the coil makes the ball fly
					ns_state=s_run_game;	
			end // arm2
						
			s_run_game: begin
				score_is_running=1'b1;
				if(lost_ball) begin//if we lost the ball 1 herat is gone
					if(hearts_in == 2'b01)
						ns_state= s_game_over;
					else ns_state = s_idle;
				end
				
				if(level_up) begin
					if(level_in == 2'b10)
						ns_state=s_win_game;
				end
			
			end
				
			
			s_win_game: begin
				win_game=1'b1;
				score_is_running=1'b1;
				if(enter_is_pressed) //means the user wants to start a new game
					ns_state=s_zero_score;
				
			end
			
			
			s_game_over: begin
				game_over=1'b1;
				score_is_running=1'b1;
				if(enter_is_pressed)//means the user wants to start a new game
					ns_state=s_zero_score;
			end
				
			s_zero_score: begin
				game_over=1'b1;
				ns_state=s_idle;	
			end
				
				
						
		endcase
	end // always comb

	assign num_of_hearts = hearts_in;
	
	always_comb // define output - level
	begin
		case (level_in)
			2'b00: level=4'b0001;
			2'b01: level=4'b0010;
			2'b10: level=4'b0011;
			2'b11: level=4'b0011;
		endcase
	end //always comb
	
endmodule
