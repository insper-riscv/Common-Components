// Propriedades do clearable_register, verificadas na netlist Verilog que o GHDL sintetiza do VHDL.
// Prioridade na borda: clear, depois enable, depois manter. Não há reset: o valor só é conhecido a
// partir da primeira carga ou clear, e a prova começa aí (known).
`ifndef WIDTH
`define WIDTH 4
`endif
`ifndef CLEAR
`define CLEAR 1'b0
`endif
module props (input clk);
  localparam WIDTH = `WIDTH;
  localparam CLEAR = `CLEAR;

  (* anyseq *) wire clear, enable;
  (* anyseq *) wire [WIDTH-1:0] d;
  wire [WIDTH-1:0] q;

  clearable_register dut
    (.i_clk(clk), .i_clear(clear), .i_enable(enable), .i_d(d), .o_d(q));

  // Os registradores não têm valor inicial: o primeiro clock é um clear, como na placa.
  initial assume (clear);

  reg f_past = 0;
  reg [WIDTH-1:0] model = 0, p_d = 0, p_q = 0;
  reg p_clear = 0, p_enable = 0;

  always @(posedge clk) begin
    f_past <= 1;
    model <= clear ? {WIDTH{CLEAR}} : (enable ? d : model);
    p_clear <= clear; p_enable <= enable; p_d <= d; p_q <= q;
  end

  always @(posedge clk) if (f_past) begin
    // 1. A saída é sempre o valor do modelo.
    assert (q == model);
    // 2. Clear tem prioridade sobre enable: todos os bits vão ao valor de limpeza, mesmo com enable.
    if (p_clear) assert (q == {WIDTH{CLEAR}});
    // 3. Só com enable, a saída é i_d.
    if (!p_clear && p_enable) assert (q == p_d);
    // 4. Sem clear nem enable, o valor se mantém.
    if (!p_clear && !p_enable) assert (q == p_q);
  end

`ifdef COVER
  always @(posedge clk) if (f_past) begin
    cover (p_clear && p_enable && p_d != {WIDTH{CLEAR}} && q == {WIDTH{CLEAR}});
    cover (!p_clear && p_enable && q == p_d && q != {WIDTH{CLEAR}});
  end
`endif
endmodule
