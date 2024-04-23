`timescale 1ns/1ps

module jsr_sobel (mem_bus_in, out1, input_done, clk, reset);
parameter res_x = 30;
parameter res_y = 30;
input [7:0] mem_bus_in;
input reset;		
input input_done;
integer ram_counter;
input clk;			
output wire [7:0] out1;		

reg [7:0] mem [29:0][29:0];	// 307200 byte RAM
	
reg write_en,read_en;	// internal registers for correct read/write operations.
// reg [71:0] mem_bus_out;
reg [8:0] index;
reg [9:0] index2;

reg [7:0] row3 [2:0];	//3x3 RAM to store data and transfer them to sobel core
reg [7:0] row2 [2:0];
reg [7:0] row1 [2:0];

reg [8:0] r_row;
reg [9:0] r_col;	
reg [8:0] w_row;
reg [9:0] w_col;


core_sobel s1(row1[0], row1[1], row1[2], row2[0], row2[2], row3[0], row3[1], row3[2], out1);

always @(posedge clk, posedge reset)
begin
	if(reset)						
	begin
        {row1[0],row2[0],row3[0],row1[1],row2[1],row3[1],row1[2],row2[2],row3[2]} <= 72'd0;
        r_row <= 0;
        r_col <= 0;
		w_row <= 0;
        w_col <= 0;
		read_en <= 1'b0;				//  Enable reading from FPGA	
		write_en <= 1'b0;				//  Enables writing to FPGA 			
		for(index=0;index<31;index=index+1)		// fill entire memory with zero
			for(index2=0;index2<31;index2=index2+1)
				mem [index][index2] <= 8'b00000000;
		index2 <= 10'b0;
		ram_counter <= 0;
		index <= 0;
	end
	
	else if(!input_done)	// condition for writing data to RAM
	begin
		mem[r_row][r_col] <= mem_bus_in;		// writes the data at bus_in to RAM
		ram_counter <= ram_counter + 1;
		// if (r_row <= 29)
		// 	begin
		// 		if (r_col <= 29)
		// 			r_col <= r_col + 1;
		// 		else
		// 			begin
		// 				r_row <= r_row + 1;
		// 				r_col <= 0;
		// 			end
		// 	end
		// else
		// 	begin
		// 		r_row <= 0;
		// 		r_col <= 0;
		// 	end

		if (r_row <= res_y - 1) begin
			r_col <= (r_col == res_x - 1)? 0 : r_col + 1;
			r_row <= (r_col == res_x - 1)? r_row + 1 : r_row;
		end
		if(r_row == res_y - 1 && r_col == res_x - 1)begin
			r_row <= 0;
			r_col <= 0;
		end

        write_en <= 1; 
	end

	else //if(ram_counter >= 899)   // condition for reading from RAM
	begin	// Make 3x3 valid blocks of data and sweep the memory
    write_en <= 0;
	ram_counter <= ram_counter - 1;
		if(w_row <= res_y - 3 )	
			begin	
				if(w_col < res_x - 3 )	
					begin
						{row1[0], row1[1], row1[2], row2[0], row2[2], row3[0], row3[1], row3[2]} <= {mem[w_row][w_col],mem[w_row][w_col+1],mem[w_row][w_col+2],mem[w_row+1][w_col],mem[w_row+1][w_col+2],mem[w_row+2][w_col],mem[w_row+2][w_col+1],mem[w_row+2][w_col+2]};
						read_en <= 1'b1;
						w_col <= w_col + 1;
					end
				else
					begin
						{row1[0], row1[1], row1[2], row2[0], row2[2], row3[0], row3[1], row3[2]} <= {mem[w_row][w_col],mem[w_row][w_col+1],mem[w_row][w_col+2],mem[w_row+1][w_col],mem[w_row+1][w_col+2],mem[w_row+2][w_col],mem[w_row+2][w_col+1],mem[w_row+2][w_col+2]};
						w_col <= 0;
						read_en <= 1'b1;
						w_row <= w_row + 1;
					end	
			end
	end		
end
endmodule
	
	
	
	
	
	
	
	
	
