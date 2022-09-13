
module	object_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // ball 
					input		logic	ballDR,
					input		logic	[7:0] ballRGB,  
			// ball2
					input		logic	ball2DR,
					input		logic	[7:0] ball2RGB, 				
		  //   left flipper  
			      input		logic	flipperL_DR, 
					input		logic	[7:0] flipperL_RGB, 
		  //   right flipper  
			      input		logic	flipperR_DR,
					input		logic	[7:0] flipperR_RGB, 		
		  //  obstacle - plus   
			      input		logic	plusDR,
					input		logic	[7:0] plusRGB, 
		  //  obstacle - mushroom   
			      input		logic	mushroomDR, 
					input		logic	[7:0] mushroomRGB, 
			//  obstacle - star 
					input    logic StarDR, 
					input		logic	[7:0] starRGB, 
			//  obstacle - Lefttriangle 
					input    logic LtriangleDR, 
					input		logic	[7:0] LtriangleRGB, 
			//  obstacle - Righttriangle 
					input    logic RtriangleDR, 
					input		logic	[7:0] RtriangleRGB, 
			//  obstacle - Uptriangle 
					input    logic UptriangleDR, 
					input		logic	[7:0] UptriangleRGB, 
			//  score digits display
					input    logic pointsDR,
					input		logic	[7:0] pointsRGB, 
			//  coil display
					input    logic CoilDR,
					input		logic	[7:0] CoilRGB,
			//  heart display
					input    logic HeartDR,
					input		logic	[7:0] HeartRGB,
			//  predatory plant display
					input    logic PredatoryPlantDR,
					input		logic	[7:0] PredatoryPlantRGB,		
			//  signs display
					input    logic signsDR,
					input		logic	[7:0] signsRGB,
			//  level display
					input    logic levelDR,
					input		logic	[7:0] levelRGB,
		  // background   
					input		logic	[7:0] backGroundRGB, 
			////////////////////////
			
			
			// decides what to draw
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (StarDR == 1'b1)
							RGBOut <= starRGB;//first priority 
 
		else begin 
			if (plusDR == 1'b1)
					RGBOut <= plusRGB;     
			else begin
					if(flipperL_DR == 1'b1 )
						RGBOut <= flipperL_RGB; 
					else begin 
						if(flipperR_DR == 1'b1 )
							RGBOut <= flipperR_RGB; 
						else begin
							if (ballDR == 1'b1 )   
									RGBOut <= ballRGB;
							else begin 
								if (ball2DR == 1'b1 )   
									RGBOut <= ball2RGB;
								else begin
										if (mushroomDR == 1'b1 )   
												RGBOut <= mushroomRGB;
										else begin
											if (CoilDR == 1'b1 )   
													RGBOut <= CoilRGB;
											else begin
												if (LtriangleDR == 1'b1 )   
														RGBOut <= LtriangleRGB;
												else begin
													if (RtriangleDR == 1'b1 )   
														RGBOut <= RtriangleRGB;
													else begin
														if (UptriangleDR == 1'b1 )   
															RGBOut <= UptriangleRGB;
														else begin
															if (pointsDR == 1'b1 )   
																RGBOut <= pointsRGB;
															else begin 
																if (signsDR == 1'b1 )   
																	RGBOut <= signsRGB;
																else begin 
																	if (HeartDR == 1'b1 )   
																		RGBOut <= HeartRGB;
																	else begin 
																	if (PredatoryPlantDR == 1'b1 )   
																		RGBOut <= PredatoryPlantRGB;
																	else begin
																		if (levelDR == 1'b1 )   
																			RGBOut <= levelRGB;
																		else RGBOut <= backGroundRGB;
																	end
																end
															end
														end			
													end 
												end
											end	
										end
									end
								end
							end
						end
					end
				end
			end
		end
end
endmodule


