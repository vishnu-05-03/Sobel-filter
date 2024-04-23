module avgGrayscale (rgb_in, clk_i, reset, rgb_out, flag_grayscale_complete, flag_output_complete, taken_input, gray_output_done, sobel_output_done, avg_bus_in, sobel_bus_in);
    input wire [7:0] rgb_in;
    input wire clk_i;
    input wire reset;
    output wire [7:0] rgb_out;
    output reg flag_grayscale_complete;
    output reg flag_output_complete;

    parameter res_y = 32;
    parameter res_x = 32;

    integer i;

    reg [7:0] gray_mem [res_y-1:0][res_x-1:0];
    reg [7:0] avg_mem [res_y-1:0][res_x-1:0];
    reg [7:0] edge_mem [res_y-1:0][res_x-1:0];

    reg signed [7:0] r_channel [0:1023];
    reg signed [7:0] g_channel [0:1023];

    reg [12:0] counter;
    reg [7:0] debugger;
    output reg taken_input, gray_output_done, sobel_output_done;
    reg [10:0] row, col, a_row, a_col, b_row, b_col, c_row, c_col, d_row, d_col;

    reg [7:0] arow3 [2:0];
    reg [7:0] arow2 [2:0];
    reg [7:0] arow1 [2:0];

    reg [7:0] srow3 [2:0];
    reg [7:0] srow2 [2:0];
    reg [7:0] srow1 [2:0];

    output [7:0] avg_bus_in, sobel_bus_in;

    core_avg avg(arow1[0], arow1[1], arow1[2], arow2[0], arow2[1], arow2[2], arow3[0], arow3[1], arow3[2], avg_bus_in);
    core_sobel sobel(srow1[0], srow1[1], srow1[2], srow2[0], srow2[2], srow3[0], srow3[1], srow3[2], sobel_bus_in);
    assign rgb_out = sobel_bus_in;  // to be commented
    // assign rgb_out = avg_bus_in;

    always @(posedge clk_i) begin
        if(reset) begin
            counter <= 0;
            row <= 0;   col <= 0;
            a_row <= 0;     a_col <= 0;
            b_row <= 0;     b_col <= 0;
            c_row <= 0;     c_col <= 0;
            d_row <= 0;     d_col <= 0;
            flag_grayscale_complete <= 0;
            flag_output_complete <= 0;
            taken_input <= 0;
            gray_output_done <= 0;
            sobel_output_done <= 0;
        end
        else begin
            // if(!taken_input)
            // begin
                if(counter < (res_y*res_x)) begin                // take red inputs and store it in buffer
                    r_channel[counter] <= rgb_in;
                end
                if(counter >= (res_y*res_x-1) && counter < (2*res_y*res_x - 1)) begin           // take green inputs and store it in buffer
                    g_channel[counter - (res_y*res_x-1)] <= rgb_in;
                end
                if(counter >= (2*res_y*res_x - 1) && counter < (3*res_y*res_x - 1)) begin
                    gray_mem[row][col] <= (r_channel[counter - (2*res_y*res_x - 1)] * 30 + g_channel[counter - (2*res_y*res_x - 1)] * 59 + rgb_in * 11) / 100;;		// Converts into grayscale and writes to RAM
                    if (row <= res_y - 1) begin
                        col <= (col == res_x - 1)? 0 : col + 1;
                        row <= (col == res_x - 1)? row + 1 : row;
                    end
                    if(row == res_y - 1 && col == res_x - 1)begin
                        row <= 0;
                        col <= 0;
                    end
                end
                counter <= (counter==(3*res_y*res_x - 1))? 0 : counter + 1;
                if(counter==(3*res_y*res_x - 1))
                    taken_input <= 1;
            end
        // end
    end

    always@(posedge clk_i)          
    begin
        if(taken_input)             // Smoothen Function + Zero Padding
        begin
            avg_mem[a_row+1][a_col+1] <= avg_bus_in;		 // write the smoothen vaues to RAM
            for(i=0; i<res_y; i++)                                     
            begin        // Zero Padding 
                avg_mem[i][0] <= 0;
                avg_mem[i][res_x-1] <= 0;
            end
            for(i=0; i<res_x; i++)                                     
            begin        // Zero Padding 
                avg_mem[0][i] <= 0;
                avg_mem[res_y-1][i] <= 0;
            end
            // Writing indices for avg RAM
            if (a_row <= res_y - 3) begin
                a_col <= (a_col == res_x - 3)? 0 : a_col + 1;
                a_row <= (a_col == res_x - 3)? a_row + 1 : a_row;
            end
            if(a_row == res_y - 3 && a_col == res_x - 3)begin
                a_row <= 0;
                a_col <= 0;
            end
            // Reading indexes from gray RAM
            if (b_row <= res_y - 3) begin
			b_col <= (b_col == res_x - 3)? 0 : b_col + 1;
			b_row <= (b_col == res_x - 3)? b_row + 1 : b_row;
            end
            if(b_row == res_y - 3 && b_col == res_x - 3)begin
                b_row <= 0;
                b_col <= 0;
                gray_output_done <= 1;
            end
            {arow1[0], arow1[1], arow1[2], arow2[0], arow2[1], arow2[2], arow3[0], arow3[1], arow3[2]} <= {gray_mem[b_row][b_col],gray_mem[b_row][b_col+1],gray_mem[b_row][b_col+2],gray_mem[b_row+1][b_col],gray_mem[b_row+1][b_col+1],gray_mem[b_row+1][b_col+2],gray_mem[b_row+2][b_col],gray_mem[b_row+2][b_col+1],gray_mem[b_row+2][b_col+2]};
        end
        if(gray_output_done)                     // Edge Detect + Zero Padding
        begin
            edge_mem[c_row+1][c_col+1] <= sobel_bus_in;		 // write the smoothen vaues to RAM
            for(i=0; i<res_y; i++)                                     
            begin        // Zero Padding 
                edge_mem[i][0] <= 0;
                edge_mem[i][res_x-1] <= 0;
            end
            for(i=0; i<res_x; i++)                                     
            begin        // Zero Padding 
                edge_mem[0][i] <= 0;
                edge_mem[res_y-1][i] <= 0;
            end
            // Writing indices for sobel RAM
            if (c_row <= res_y - 3) begin
                c_col <= (c_col == res_x - 3)? 0 : c_col + 1;
                c_row <= (c_col == res_x - 3)? c_row + 1 : c_row;
            end
            if(c_row == res_y - 3 && c_col == res_x - 3)begin
                c_row <= 0;
                c_col <= 0;
            end
            // Reading indexes from avg RAM
            if (d_row <= res_y - 3) begin
			d_col <= (d_col == res_x - 3)? 0 : d_col + 1;
			d_row <= (d_col == res_x - 3)? d_row + 1 : d_row;
            end
            if(d_row == res_y - 3 && d_col == res_x - 3)begin
                d_row <= 0;
                d_col <= 0;
                sobel_output_done <= 1;
            end
            {srow1[0], srow1[1], srow1[2], srow2[0], srow2[2], srow3[0], srow3[1], srow3[2]} <= {avg_mem[d_row][d_col],avg_mem[d_row][d_col+1],avg_mem[d_row][d_col+2],avg_mem[d_row+1][d_col],avg_mem[d_row+1][d_col+2],avg_mem[d_row+2][d_col],avg_mem[d_row+2][d_col+1],avg_mem[d_row+2][d_col+2]};
        end
    end
endmodule