module core_avg ( p0, p1, p2, p3, p4, p5, p6, p7, p8, out);

input  [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;
output [7:0] out;					
wire [10:0] sum;	

assign sum = (p0+p1+p2+p3+p4+p5+p6+p7+p8)/9;    // Find the average of the pixel
assign out = (|sum[10:8])?8'hff : sum[7:0];	// to limit the max value to 255 (sum[10]|sum[9]|sum[8]=1 then out=255 else: sum[7:0])

endmodule
