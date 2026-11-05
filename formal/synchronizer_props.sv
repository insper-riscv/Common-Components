// Propriedades do synchronizer, verificadas na netlist Verilog que o GHDL sintetiza do VHDL.
// A entrada é livre (o reset também). Um contador "since" conta as bordas desde o último reset, e a
// história crua da entrada (hist) é o modelo: a saída só pode mostrar uma amostra de i_d depois de
// STAGES bordas, e antes disso mostra o valor de reset.
`ifndef STAGES
`define STAGES 2
`endif
`ifndef WIDTH
`define WIDTH 2
`endif
module props (input clk);
  localparam STAGES = `STAGES;
  localparam WIDTH  = `WIDTH;
  localparam [7:0] LAST = `STAGES;

  (* anyseq *) wire reset;
  (* anyseq *) wire [WIDTH-1:0] d;
  wire [WIDTH-1:0] q;

  synchronizer dut (.i_clk(clk), .i_rst(reset), .i_d(d), .o_d(q));

  // Os registradores não têm valor inicial: o primeiro clock é um reset, como na placa.
  initial assume (reset);

  reg f_past = 0;
  // hist[j] é a amostra de i_d tomada j+1 bordas atrás.
  reg [WIDTH*STAGES-1:0] hist = 0;
  // Bordas desde o último reset, saturando em STAGES.
  reg [7:0] since = 0;
  wire [WIDTH-1:0] hist_last  = hist[WIDTH*STAGES-1 -: WIDTH];
  wire [WIDTH-1:0] hist_first = hist[WIDTH-1:0];

  always @(posedge clk) begin
    f_past <= 1;
    hist <= {hist, d};
    since <= reset ? 8'd0 : (since >= LAST ? LAST : since + 8'd1);
  end

  always @(posedge clk) if (f_past) begin
    // 1. Latência: com STAGES bordas sem reset, a saída é a entrada de STAGES bordas atrás, nem mais cedo.
    if (since >= STAGES) assert (q == hist_last);
    // 2. Depois de um reset, a saída fica em zero até a primeira amostra chegar ao último estágio.
    if (since < STAGES) assert (q == 0);
  end

`ifdef COVER
  // Uma mudança chega na saída depois de STAGES bordas; um reset no meio da cadeia a limpa.
  always @(posedge clk) if (f_past) begin
    cover (since >= STAGES && q != 0);
    cover (since == 1 && hist_first != 0 && q == 0);
  end
`endif
endmodule
