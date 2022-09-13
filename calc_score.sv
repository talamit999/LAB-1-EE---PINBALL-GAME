module calc_score (

					input	logic	clk, 
					input	logic	resetN, 
					input logic score_is_running, // while is 1, add score. when 0, zero score (for next game)
					input	logic	hit_mushroom,
					input logic hit_star, 
					input logic hit_plus,
 
					output	logic [3:0]	left_digit, 
					output	logic	[3:0] mid_digit, 
					output	logic	[3:0] right_digit, 
					output   logic level_up    
 ) ; 
 

//logic [3:0] ten = 4'd10 ; //decimal basis

int zero = 0;
int ten = 10;
int thousand = 1000;

int counter = 0; //count 1000 points until next level 
 

always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		counter <=	zero; 
		level_up <= 1'b0;
	end 
	else begin  
			level_up <= 1'b0; //default
			
			if(score_is_running) begin // add points only if the game is still running
				
				if(counter >= thousand) begin //if counter >= 1000 graduate to next level  
					counter <= zero;
					level_up <= 1'b1;
				end 
				else begin
					
					if(hit_mushroom)
						counter <= counter + 25 ; 
			
					if(hit_star)
						counter <= counter + 10 ; 
			
					if(hit_plus)
						counter <= counter + 15 ; 
				end
			end
			else counter = zero; // if score_is_running = 0 , zero score for next game
	end 
end   

assign right_digit = counter % ten ; 
assign mid_digit = (counter / ten) % ten ; 
assign left_digit =(counter / (ten*ten)) % ten ; 
 
endmodule
