
module sound_machine
	(
	input logic clk, 
	input logic resetN, 
	input logic startOfFrame,
	input logic game_over,
	input logic hit_object,
	input logic levelUp,
	
	output logic enable,
	output logic [4:0] tone
	);
//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [3:0] { idle, levelUp1, levelUp2, levelUp3, levelUp4, hitObject1, hitObject2, hitObject3,
							gameOver1, gameOver2, gameOver3, gameOver4 } ps_state, ns_state;
	
	logic [3:0] counter= 4'b0;
	
 	localparam logic [3:0] ZERO = 4'b0;
	localparam logic [3:0] MAX_COUNT = 4'b1111;
	localparam logic [3:0] HALF_COUNT = 4'b0111;
	localparam logic [3:0] QTR_COUNT = 4'b0011;
 	
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
	   
   if ( !resetN ) begin  // Asynchronic reset
		ps_state <= idle;
		counter <= ZERO; 
   end 
	
	else begin 		// Synchronic logic FSM
		ps_state <= ns_state;
		
		// level up sound 
		if(ns_state==levelUp1 && ps_state == idle)
			counter<= MAX_COUNT;
		if(ns_state==levelUp2 && ps_state == levelUp1)
			counter<= MAX_COUNT;
		if(ns_state==levelUp3 && ps_state == levelUp2)
			counter<= MAX_COUNT;
		if(ns_state==levelUp4 && ps_state == levelUp3)
			counter<= MAX_COUNT;
		
		// hit object sound 
		if(ns_state==hitObject1 && ps_state == idle)
			counter<= QTR_COUNT;
		if(ns_state==hitObject2 && ps_state == hitObject1)
			counter<= QTR_COUNT;
		if(ns_state==hitObject3 && ps_state == hitObject2)
			counter<= QTR_COUNT;
		
		// game over sound
		if(ns_state==gameOver1 && ps_state == idle)
			counter<= MAX_COUNT;
		if(ns_state==gameOver2 && ps_state == gameOver1)
			counter<= MAX_COUNT;
		if(ns_state==gameOver3 && ps_state == gameOver2)
			counter<= MAX_COUNT;
		if(ns_state==gameOver4 && ps_state == gameOver3)
			counter<= MAX_COUNT;
		
		// decreasing the counter
		if(startOfFrame && counter > ZERO)
					counter<= counter - 1;
		
	end
end // always sync
	
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	
always_comb // Update next state and outputs
	begin
	// set all default values
		ns_state = ps_state;
		enable = 1'b1;
		tone = 5'b0;
		if (levelUp)
			ns_state = levelUp1;
		if (game_over)
			ns_state = gameOver1;
		
		
		case (ps_state)
		
			//Note: the implementation of the idle state is already given you as an example
			idle: begin
				enable = 1'b0; // no sound
				if (hit_object)
					ns_state = hitObject1;
				end // idle
						
			levelUp1: begin 
				tone = 5'd4; //mi 
				if(counter == ZERO) 
					ns_state = levelUp2;
				end 
				
			levelUp2: begin 
				tone = 5'd3; //reD
				if(counter == ZERO) 
					ns_state = levelUp3;
				end 
						
			levelUp3: begin 
				tone = 5'd2; //re
				if(counter == ZERO) 
					ns_state = levelUp4;
				end
			
			levelUp4: begin 
				tone = 5'd1; 
				if(counter == ZERO) 
					ns_state = idle;
				end
			
			hitObject1: begin 
				tone = 5'd12; 
				if(counter == ZERO) 
					ns_state = hitObject2;
				end 
			
			hitObject2: begin 
				tone = 5'd13; 
				if(counter == ZERO) 
					ns_state = hitObject3;
				end 
			
			hitObject3: begin 
				tone = 5'd14; 
				if(counter == ZERO) 
					ns_state = idle;
				end 
			
			gameOver1: begin 
				tone = 5'd15; 
				if(counter == ZERO) 
					ns_state = gameOver2;
				end
			
			gameOver2: begin 
				tone = 5'd16; 
				if(counter == ZERO) 
					ns_state = gameOver3;
				end
			
			gameOver3: begin 
				tone = 5'd17; 
				if(counter == ZERO) 
					ns_state = gameOver4;
				end
			
			gameOver4: begin 
				tone = 5'd18; 
				if(counter == ZERO) 
					ns_state = idle;
				end
		
			
					
		endcase
	end // always comb
	
endmodule
