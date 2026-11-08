// Propriedades do counter64, verificadas na netlist Verilog que o GHDL sintetiza do VHDL.
// XLEN (define, 32 por padrão) é a largura da palavra do config_pkg da lista de fontes, e WIDTH (define, 64 por
// padrão) é a largura do contador: a metade baixa guarda min(WIDTH, XLEN) bits e a alta os WIDTH - XLEN restantes,
// uma escrita guarda só os bits que cabem e os bits acima da largura leem zero. Um modelo guarda o valor ideal do
// contador. Quaisquer que sejam as entradas, o valor mostrado (a metade alta com o vai-um pendente somado) é o do
// modelo: conta um por incremento, uma escrita vence o incremento do próprio ciclo e o vai-um entre as metades
// nunca se perde.
`ifndef XLEN
`define XLEN 32
`endif
`ifndef WIDTH
`define WIDTH 64
`endif
module props (input clk);
  localparam XL = `XLEN;
  localparam W  = `WIDTH;
  localparam LW = W < XL ? W : XL;
  localparam HW = W - LW;
  localparam [63:0] LO_MASK = LW >= 64 ? ~64'h0 : ((64'h1 << LW) - 64'h1);
  localparam [63:0] HI_MASK = HW == 0 ? 64'h0 : (HW >= 64 ? ~64'h0 : ((64'h1 << HW) - 64'h1));

  (* anyseq *) wire reset, inc, we_lo, we_hi;
  (* anyseq *) wire [XL-1:0] wdata;
  wire [XL-1:0] lo, hi;
  wire wrap;

  counter64 dut (.i_clk(clk), .i_rst(reset), .i_inc(inc), .i_we_lo(we_lo), .i_we_hi(we_hi),
    .i_wdata(wdata), .o_lo(lo), .o_hi(hi), .o_wrap(wrap));

  // Os registradores não têm valor inicial: o primeiro clock é um reset, como na placa.
  initial assume (reset);

  // Valores de 64 bits das portas e dos dados, para as contas do modelo.
  wire [63:0] wdata64 = wdata;
  wire [63:0] lo64    = lo;
  wire [63:0] hi64    = hi;
  // Valor mostrado, de até 128 bits.
  wire [127:0] shown  = ({64'h0, hi64} << XL) | {64'h0, lo64};

  reg f_past = 0;
  reg [63:0] m_lo = 64'h0;
  reg [63:0] m_hi = 64'h0;
  reg [127:0] p_shown = 128'h0;
  reg [63:0] p_lo = 64'h0, p_hi = 64'h0;
  reg p_reset = 0, p_inc = 0, p_we_lo = 0, p_we_hi = 0;
  reg p_ovf = 0;

  // O contador ideal: a metade baixa toma a escrita ou o incremento, e a alta toma a escrita (ou mantém o valor)
  // e depois o vai-um que a baixa produziu neste ciclo.
  wire        carry_out = inc && !we_lo && m_lo == LO_MASK;
  wire [63:0] lo_next   = we_lo ? (wdata64 & LO_MASK) : (inc ? ((m_lo + 64'd1) & LO_MASK) : m_lo);
  wire [63:0] hi_base   = we_hi ? (wdata64 & HI_MASK) : m_hi;
  wire [63:0] hi_next   = (hi_base + {63'b0, carry_out}) & HI_MASK;
  // O estouro ideal do ciclo: o incremento leva o contador inteiro de todos os bits em '1' a zero.
  wire [64:0] hi_sum    = {1'b0, hi_base & HI_MASK} + {64'b0, carry_out};
  wire        ideal_ovf = HW == 0 ? carry_out : (hi_sum > {1'b0, HI_MASK});

  always @(posedge clk) begin
    f_past <= 1;
    p_shown <= shown;
    p_lo <= lo64; p_hi <= hi64;
    p_reset <= reset; p_inc <= inc; p_we_lo <= we_lo; p_we_hi <= we_hi;
    m_lo <= reset ? 64'h0 : lo_next;
    m_hi <= reset ? 64'h0 : hi_next;
    p_ovf <= reset ? 1'b0 : ideal_ovf;
  end

  // Os registradores zeram de forma assíncrona: com o reset em '1' a leitura dá o valor de reset.
  always @(posedge clk) if (f_past && !reset) begin
    // 1. O valor mostrado é o valor ideal, em todo ciclo.
    assert (lo64 == m_lo && hi64 == m_hi);
    // 1b. O pulso de estouro é o estouro ideal do ciclo anterior: um pulso de um ciclo quando um incremento leva
    // o contador de todos os bits em '1' a zero, nunca por uma escrita, e não se perde se uma escrita o segue.
    assert (wrap == p_ovf);
  end

`ifdef MONOTONIC
  // 2. Sem escrita no ciclo anterior o valor nunca decresce (só pode dar a volta em 2^WIDTH).
  always @(posedge clk) if (f_past && !p_reset && !reset && !p_we_lo && !p_we_hi
                            && p_shown != ((128'h1 << W) - 128'h1))
    assert (shown >= p_shown);
`endif

`ifdef COVER
  // O estouro é alcançável. Com metade alta, o vai-um entre as metades e uma escrita junto com o estouro também
  // são; sem metade alta (a palavra comporta o contador inteiro), o vai-um é o próprio estouro da metade baixa.
  always @(posedge clk) if (f_past && !reset) begin
    cover (wrap);
    cover (p_inc && p_lo == LO_MASK && lo64 == 64'h0);
  end
  generate if (HW != 0) begin : gen_cover_hi
    always @(posedge clk) if (f_past && !reset) begin
      cover (p_inc && p_lo == LO_MASK && lo64 == 64'h0 && hi64 == ((p_hi + 64'd1) & HI_MASK));
      cover (p_we_hi && p_lo == LO_MASK && p_inc);
      cover (wrap && p_we_hi);
    end
  end endgenerate
`endif
endmodule
