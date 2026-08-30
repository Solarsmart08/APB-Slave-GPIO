module apb_gpio_tb;

logic PCLK;
logic PRESETn;

logic PSEL;
logic PENABLE;
logic PWRITE;

logic [7:0] PADDR;
logic [31:0] PWDATA;

logic [31:0] PRDATA;
logic PREADY;
logic PSLVERR;

logic [7:0] GPIO_IN;
logic [7:0] GPIO_OUT;
apb_gpio dut (
.PCLK (PCLK),
.PRESETn (PRESETn),

.PSEL (PSEL),
.PENABLE (PENABLE),
.PWRITE (PWRITE),

.PADDR (PADDR),
.PWDATA (PWDATA),

.PRDATA (PRDATA),
.PREADY (PREADY),
.PSLVERR (PSLVERR),

.GPIO_IN (GPIO_IN),
.GPIO_OUT (GPIO_OUT)
);

initial begin
PCLK = 1'b0;

forever #5 PCLK = ~PCLK;
end

task automatic apb_write(
input logic [7:0] address,
input logic [31:0] data
);

begin


@(posedge PCLK);

PSEL <= 1'b1;
PENABLE <= 1'b0;
PWRITE <= 1'b1;
PADDR <= address;
PWDATA <= data;


@(posedge PCLK);

PENABLE <= 1'b1;


@(posedge PCLK);

while (!PREADY)
@(posedge PCLK);


PSEL <= 1'b0;
PENABLE <= 1'b0;
PWRITE <= 1'b0;

end

endtask


task automatic apb_read(
input logic [7:0] address,
output logic [31:0] data
);

begin


@(posedge PCLK);

PSEL <= 1'b1;
PENABLE <= 1'b0;
PWRITE <= 1'b0;
PADDR <= address;
PWDATA <= 32'h00000000;


@(posedge PCLK);

PENABLE <= 1'b1;


@(posedge PCLK);

while (!PREADY)
@(posedge PCLK);

data = PRDATA;

PSEL <= 1'b0;
PENABLE <= 1'b0;

end

endtask


logic [31:0] read_data;

initial begin


PRESETn = 1'b0;
PSEL = 1'b0;
PENABLE = 1'b0;
PWRITE = 1'b0;
PADDR = 8'h00;
PWDATA = 32'h00000000;

GPIO_IN = 8'h3C;

#20;

PRESETn = 1'b1;

#20;
$display("TEST 1: Writing CTRL = 1");

apb_write(8'h00, 32'h00000001);


$display("TEST 2: Writing GPIO_OUT = A5");

apb_write(8'h04, 32'h000000A5);

$display("TEST 3: Reading GPIO_OUT");

apb_read(8'h04, read_data);

$display("READ DATA = %h", read_data);


if (read_data == 32'h000000A5)
$display("PASS: GPIO_OUT read correctly");
else
$display("FAIL: GPIO_OUT read incorrect");


$display("TEST 4: Reading GPIO_IN");

apb_read(8'h08, read_data);

$display("READ GPIO_IN = %h", read_data);


if (read_data == 32'h0000003C)
$display("PASS: GPIO_IN read correctly");
else
$display("FAIL: GPIO_IN read incorrect");


$display("TEST 5: Reading invalid address");

apb_read(8'h20, read_data);

$display("INVALID ADDRESS DATA = %h", read_data);

if (read_data == 32'h00000000)
$display("PASS: Invalid address handled");
else
$display("FAIL: Invalid address");
#20;
$display("APB GPIO TEST COMPLETED");

end
endmodule
