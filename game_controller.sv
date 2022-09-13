
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	ballDR,
			input	logic	ball2DR,
			input	logic	bordersDR,
			input logic starDR,
			input logic plusDR,
			input logic mushroomDR,
			input logic flipperL_DR,
			input logic flipperR_DR,
			input logic triangleL_DR,
			input logic triangleR_DR,
			input logic triangleUp_DR,
			input logic coil_DR,
			input logic predatoryplant_DR,
			
			//for first ball
			
			output logic collision, // active in case of collision between the ball and an obstcles
			output logic hit_plus_pulse, 
			output logic hit_mushroom_pulse,   // up when ball and mushroom collide
			output logic hit_star_pulse, // when hit a star the pluse go up for 1 cycle
			output logic hit_left_triangle_pulse,
			output logic hit_right_triangle_pulse,
			output logic hit_up_triangle_pulse,
			output logic hit_flipperR_pulse,
			output logic hit_flipperL_pulse,
			output logic hit_borders_pulse,
			output logic hit_coil_pulse,
			output logic hit_predatoryplant_pulse,
			
			
			//for second ball
			
			output logic collision2,
			output logic hit_left_triangle_pulse2,
			output logic hit_right_triangle_pulse2,
			output logic hit_up_triangle_pulse2,
			output logic hit_flipperR_pulse2,
			output logic hit_flipperL_pulse2,
			output logic hit_borders_pulse2,
			
			output logic collision_sound
);



logic hit_star, hit_mushroom, hit_plus, hit_left_triangle, hit_flipperR, hit_flipperL, hit_borders, hit_coil, hit_predatoryplant;

logic hit_left_triangle2, hit_right_triangle2, hit_up_triangle2, hit_flipperR2, hit_flipperL2, hit_borders2;

// any collision with objects

assign collision = ballDR &&  (starDR || plusDR || mushroomDR || flipperL_DR || flipperR_DR || coil_DR || predatoryplant_DR || ball2DR	);
														 
assign collision2 = ball2DR &&  (starDR || plusDR || mushroomDR || flipperL_DR || flipperR_DR || coil_DR || predatoryplant_DR || ballDR );

assign collision_sound = (ballDR &&  (starDR || plusDR || mushroomDR || flipperL_DR || flipperR_DR ))	||					 						
								 (ball2DR &&  (starDR || plusDR || mushroomDR || flipperL_DR || flipperR_DR ));


// spesipic collision for score

assign hit_star = (ballDR || ball2DR) && starDR;

assign hit_plus = (ballDR || ball2DR) && plusDR;

assign hit_mushroom = (ballDR || ball2DR) && mushroomDR;

// spesipic collision - ball 1

assign hit_left_triangle = ballDR && triangleL_DR;

assign hit_right_triangle = ballDR && triangleR_DR;

assign hit_up_triangle = ballDR && triangleUp_DR;

assign hit_flipperR = ballDR && flipperR_DR;

assign hit_flipperL = ballDR && flipperL_DR;

assign hit_borders = ballDR && bordersDR;

assign hit_coil = ballDR && coil_DR;

assign hit_predatoryplant = ballDR && predatoryplant_DR;

// spesipic collision - ball 2 

assign hit_left_triangle2 = ball2DR && triangleL_DR;

assign hit_right_triangle2 = ball2DR && triangleR_DR;

assign hit_up_triangle2 = ball2DR && triangleUp_DR;

assign hit_flipperR2 = ball2DR && flipperR_DR;

assign hit_flipperL2 = ball2DR && flipperL_DR;

assign hit_borders2 = ball2DR && bordersDR;



logic flag_star, flag_plus, flag_mushroom, flag_left_triangle, flag_right_triangle, flag_up_triangle, flag_flipperR, flag_flipperL, flag_borders, flag_coil, flag_predatoryplant;
 // a semaphore to set the output only once per frame / regardless of the number of collisions 


 
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin // reset everything
		flag_star <= 1'b0;
		flag_plus <= 1'b0;
		flag_mushroom <= 1'b0;
		flag_left_triangle <= 1'b0;
		flag_right_triangle <= 1'b0;
		flag_up_triangle <= 1'b0;
		flag_flipperR <= 1'b0;
		flag_flipperL <= 1'b0;
		flag_borders <= 1'b0;
		flag_coil <= 1'b0;
		flag_coil <= 1'b0;
		flag_predatoryplant <= 1'b0;

		hit_plus_pulse <= 1'b0 ; 
		hit_mushroom_pulse <= 1'b0; 
		hit_star_pulse <= 1'b0; 
		hit_left_triangle_pulse <= 1'b0; 
		hit_right_triangle_pulse <= 1'b0;
		hit_up_triangle_pulse <= 1'b0;
		hit_flipperR_pulse <= 1'b0;
		hit_flipperL_pulse <= 1'b0;
		hit_borders_pulse <= 1'b0;
		hit_coil_pulse <= 1'b0;
		hit_predatoryplant_pulse <= 1'b0;
	end 
	else begin 
	
		// default
		hit_plus_pulse <= 1'b0 ; 
		hit_mushroom_pulse <= 1'b0; 
		hit_star_pulse <= 1'b0; 
		hit_left_triangle_pulse <= 1'b0;
		hit_right_triangle_pulse <= 1'b0;
		hit_flipperR_pulse <= 1'b0;
		hit_flipperL_pulse <= 1'b0;
		hit_up_triangle_pulse <= 1'b0;
		hit_borders_pulse <= 1'b0;
		hit_coil_pulse <= 1'b0;
		hit_predatoryplant_pulse <= 1'b0;
		 
		if(startOfFrame) begin
				// reset for next time 
				flag_star <= 1'b0;
				flag_plus <= 1'b0;
				flag_mushroom <= 1'b0;
				flag_left_triangle <= 1'b0;
				flag_right_triangle <= 1'b0;
				flag_up_triangle <= 1'b0;
				flag_flipperR <= 1'b0;
				flag_flipperL <= 1'b0;
				flag_borders <= 1'b0;
				flag_coil <= 1'b0;
				flag_predatoryplant <= 1'b0;
				
		end 
		
		//raising the pulse if first time since start of frame
		if ( hit_star  && (flag_star == 1'b0)) begin 
			flag_star	<= 1'b1;
			hit_star_pulse <= 1'b1 ; 
		end
		if ( hit_plus  && (flag_plus == 1'b0)) begin 
			flag_plus	<= 1'b1;
			hit_plus_pulse <= 1'b1 ; 
		end 
		if ( hit_mushroom  && (flag_mushroom == 1'b0)) begin 
			flag_mushroom	<= 1'b1;  
			hit_mushroom_pulse <= 1'b1 ; 
		end 
		if ( hit_left_triangle  && (flag_left_triangle == 1'b0)) begin 
			flag_left_triangle	<= 1'b1;  
			hit_left_triangle_pulse <= 1'b1 ; 
		end 
		if ( hit_right_triangle  && (flag_right_triangle == 1'b0)) begin 
			flag_right_triangle	<= 1'b1;  
			hit_right_triangle_pulse <= 1'b1 ; 
		end
		if ( hit_up_triangle  && (flag_up_triangle == 1'b0)) begin 
			flag_up_triangle	<= 1'b1;  
			hit_up_triangle_pulse <= 1'b1 ; 
		end
		if ( hit_flipperR  && (flag_flipperR == 1'b0)) begin 
			flag_flipperR	<= 1'b1;  
			hit_flipperR_pulse <= 1'b1 ; 
		end 
		if ( hit_flipperL  && (flag_flipperL == 1'b0)) begin 
			flag_flipperL	<= 1'b1;  
			hit_flipperL_pulse <= 1'b1 ; 
		end 
		if ( hit_borders  && (flag_borders == 1'b0)) begin 
			flag_borders	<= 1'b1;  
			hit_borders_pulse <= 1'b1 ; 
		end 
		if ( hit_coil  && (flag_coil == 1'b0)) begin 
			flag_coil	<= 1'b1;  
			hit_coil_pulse <= 1'b1 ; 
		end 
		if ( hit_predatoryplant  && (flag_predatoryplant == 1'b0)) begin 
			flag_predatoryplant	<= 1'b1;  
			hit_predatoryplant_pulse <= 1'b1 ; 
		end 
		
	end 
end

// ball2 pulses

logic flag_left_triangle2, flag_right_triangle2, flag_up_triangle2, flag_flipperR2, flag_flipperL2, flag_borders2; 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin // reset everything
		flag_left_triangle2 <= 1'b0;
		flag_right_triangle2 <= 1'b0;
		flag_up_triangle2 <= 1'b0;
		flag_flipperR2 <= 1'b0;
		flag_flipperL2 <= 1'b0;
		flag_borders2 <= 1'b0;

		hit_left_triangle_pulse2 <= 1'b0; 
		hit_right_triangle_pulse2 <= 1'b0;
		hit_up_triangle_pulse2 <= 1'b0;
		hit_flipperR_pulse2 <= 1'b0;
		hit_flipperL_pulse2 <= 1'b0;
		hit_borders_pulse2 <= 1'b0;
	end 
	else begin 
	
		// default
		hit_left_triangle_pulse2 <= 1'b0;
		hit_right_triangle_pulse2 <= 1'b0;
		hit_flipperR_pulse2 <= 1'b0;
		hit_flipperL_pulse2 <= 1'b0;
		hit_up_triangle_pulse2 <= 1'b0;
		hit_borders_pulse2 <= 1'b0;
		 
		if(startOfFrame) begin
				// reset for next time 
				flag_left_triangle2 <= 1'b0;
				flag_right_triangle2 <= 1'b0;
				flag_up_triangle2 <= 1'b0;
				flag_flipperR2 <= 1'b0;
				flag_flipperL2 <= 1'b0;
				flag_borders2 <= 1'b0;
				
		end 
		
		//raising the pulse if first time since start of frame
		if ( hit_left_triangle2  && (flag_left_triangle2 == 1'b0)) begin 
			flag_left_triangle2	<= 1'b1;  
			hit_left_triangle_pulse2 <= 1'b1 ; 
		end 
		if ( hit_right_triangle2  && (flag_right_triangle2 == 1'b0)) begin 
			flag_right_triangle2	<= 1'b1;  
			hit_right_triangle_pulse2 <= 1'b1 ; 
		end
		if ( hit_up_triangle2  && (flag_up_triangle2 == 1'b0)) begin 
			flag_up_triangle2	<= 1'b1;  
			hit_up_triangle_pulse2 <= 1'b1 ; 
		end
		if ( hit_flipperR2  && (flag_flipperR2 == 1'b0)) begin 
			flag_flipperR2	<= 1'b1;  
			hit_flipperR_pulse2 <= 1'b1 ; 
		end 
		if ( hit_flipperL2  && (flag_flipperL2 == 1'b0)) begin 
			flag_flipperL2	<= 1'b1;  
			hit_flipperL_pulse2 <= 1'b1 ; 
		end 
		if ( hit_borders2  && (flag_borders2 == 1'b0)) begin 
			flag_borders2	<= 1'b1;  
			hit_borders_pulse2 <= 1'b1 ; 
		end 
		
	end 
end

endmodule

