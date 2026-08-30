module apb_gpio (
input logic PCLK,
input logic PRESETn,

input logic PSEL,
input logic PENABLE,
input logic PWRITE,

input logic [7:0] PADDR,
input logic [31:0] PWDATA,

output logic [31:0] PRDATA,
output logic PREADY,
output logic PSLVERR,

input logic [7:0] GPIO_IN,
output logic [7:0] GPIO_OUT
);

logic ctrl_reg;
logic [7:0] gpio_out_reg;


always_ff @(posedge PCLK or negedge PRESETn) begin

if (!PRESETn) begin
ctrl_reg <= 1'b0;
gpio_out_reg <= 8'h00;
end
else begin

if (PSEL && PENABLE && PWRITE) begin

case (PADDR)

8'h00:
ctrl_reg <= PWDATA[0];

8'h04:
gpio_out_reg <= PWDATA[7:0];

default:
;

endcase

end

end

end


always_comb begin
GPIO_OUT = gpio_out_reg;
end

always_comb begin

PRDATA = 32'h00000000;

if (PSEL && !PWRITE) begin

case (PADDR)

8'h00:
PRDATA = {31'h00000000, ctrl_reg};

8'h04:
PRDATA = {24'h000000, gpio_out_reg};

8'h08:
PRDATA = {24'h000000, GPIO_IN};

8'h0C:
PRDATA = {
24'h000000,
GPIO_OUT
};

default:
PRDATA = 32'h00000000;

endcase

end

end

always_comb begin

PREADY = PSEL && PENABLE;
PSLVERR = 1'b0;

end
endmodule
