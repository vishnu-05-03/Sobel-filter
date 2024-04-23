`timescale 1ns / 1ps
module tb();

reg [7:0] rgb_in;
reg clk_i;
reg rst_i;

wire flag_grayscale_complete;
reg tmp;
reg tmp2;
wire [7:0]rgb_out;
wire flag_output_complete;

// Flags form module
wire taken_input, gray_output_done, sobel_output_done;

// Bus from avgGrayscale module
wire [7:0] avg_bus_in, sobel_bus_in;

// File I/O declarations

integer infile, outfile;
integer outfile1, outfile2;
integer i,j,k, m;
reg [7:0] in_data [0:3071];
//reg [900*8-1:0]out_data[7:0];

avgGrayscale UUT(
    .rgb_in(rgb_in),
    .clk_i(clk_i),
    .reset(rst_i),
    .rgb_out(rgb_out),
    .flag_grayscale_complete(flag_grayscale_complete),
    .flag_output_complete(flag_output_complete),
    .taken_input(taken_input),
    .gray_output_done(gray_output_done),
    .sobel_output_done(sobel_output_done),
    .avg_bus_in(avg_bus_in),
    .sobel_bus_in(sobel_bus_in)
    );

// clk
initial begin
    clk_i <= 0;
    rgb_in <= 0;
    tmp <= 0;
    tmp2 <= 0;
    i <= 0;
    j <= 0;
    m <= 0;
    forever #5 clk_i <= ~clk_i;
end

initial begin
    #10;
    forever begin
        if(j < 3072) begin
            rgb_in <= in_data[j];
            j <= j + 1;
        end
        else begin
            j <= 1;
            rgb_in <= in_data[0];
        end
        #10;
    end
end

initial begin
    #2;
    rst_i <= 1;
    #5;
    rst_i <= 0;
    infile <= $fopen("input.hex", "r");
    outfile <= $fopen("avg.hex", "w");
    outfile1 <= $fopen("avg_output.hex", "w");
    outfile2 <= $fopen("sobel_output.hex", "w");

    if (infile == 0 || outfile == 0) begin
        $display("Error: Unable to open input or output file.");
        $finish;
    end
    $readmemh("input.hex", in_data);
end

always @(posedge clk_i) begin
    if (taken_input == 1 && gray_output_done == 0) begin
        $display("writing data avg_out_data[%d] = %h", m, avg_bus_in);
        $fwrite(outfile1, "%h\n", avg_bus_in);
    end
    else if (gray_output_done == 1 && sobel_output_done == 0 ) begin
        $display("writing data sobel_out_data[%d] = %h", m, sobel_bus_in);
        $fwrite(outfile2, "%h\n", sobel_bus_in);
    end
end

always @(negedge clk_i) begin
    if(flag_grayscale_complete) begin 
        tmp2 <= 1;
    end 
    if(tmp2) begin
        $fwrite(outfile, "%h\n", rgb_out);
        $display("writing data out_data[%d] = %h", m, rgb_out);
        m <= m + 1;
    end
    if(flag_output_complete) begin
        tmp2 <= 0;
        m<=0;
    end
end
initial begin
    #80650;
    $finish;
end
initial begin
    $dumpfile("avgFilter.vcd");
    $dumpvars(0, tb);
end
endmodule