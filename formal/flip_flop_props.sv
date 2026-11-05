// Propriedades do flip_flop, verificadas na netlist Verilog que o GHDL sintetiza do VHDL.
// Reset assíncrono ativo em '1' com prioridade sobre tudo; enable carrega i_d na borda; sem enable o
// valor se mantém. O modelo guarda o valor esperado.
module props (input clk);
  (* anyseq *) wire reset, enable, d;
  wire q;

  flip_flop dut (.i_clk(clk), .i_rst(reset), .i_enable(enable), .i_d(d), .o_d(q));

  // O registrador não tem valor inicial: o primeiro clock é um reset.
  initial assume (reset);

  reg f_past = 0;
  reg model = 0;
  reg p_reset = 0, p_enable = 0, p_d = 0, p_q = 0;

  always @(posedge clk) begin
    f_past <= 1;
    model <= reset ? 1'b0 : (enable ? d : model);
    p_reset <= reset; p_enable <= enable; p_d <= d; p_q <= q;
  end

  // 1. O reset zera a saída no mesmo ciclo (assíncrono), seja qual for o enable.
  always @(*) if (f_past && reset) assert (q == 1'b0);

  always @(posedge clk) if (f_past && !reset) begin
    // 2. Fora do reset, a saída é sempre o valor do modelo.
    assert (q == model);
    // 3. Com enable na borda anterior, o valor carregado é o de i_d.
    if (!p_reset && p_enable) assert (q == p_d);
    // 4. Sem enable na borda anterior, o valor se mantém.
    if (!p_reset && !p_enable) assert (q == p_q);
  end

`ifdef COVER
  always @(posedge clk) if (f_past && !reset) begin
    cover (!p_reset && p_enable && p_d && q);
    cover (!p_reset && !p_enable && q);
  end
`endif
endmodule
