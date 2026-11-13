// Propriedades do config_pkg, verificadas na netlist Verilog que o GHDL sintetiza do config_pkg_tb com o
// config_pkg da lista de fontes (o padrão ou uma variante que o substitui). Os defines dizem a variante provada:
// IS64 (1 para RV64), BASEE (1 para a base E) e ADDR (ADDR_BITS). As relações entre XLEN, NUM_REGS, REG_BITS e
// ADDR_BITS, o comprimento dos subtipos e o mapa de memória valem para a variante, e o check_isa aceitou a
// configuração (o_isa_ok em '1').
`ifndef IS64
`define IS64 0
`endif
`ifndef BASEE
`define BASEE 0
`endif
`ifndef ADDR
`define ADDR 32
`endif
module props (input clk);
  localparam XL  = `IS64 ? 64 : 32;
  localparam RB  = `BASEE ? 4 : 5;
  localparam AB  = `ADDR;

  wire [7:0] xlen, reg_bits, num_regs, addr_bits, word_len, reg_len, addr_len, map_len;
  wire is_64, is_e, has_multiplication, has_any_counter, has_sscof, isa_ok;
  wire has_icache, flash_on_bus, ram_on_bus, has_dcache;
  wire [AB:0] boot_end, flash_base, flash_end, ram_base, ram_end;
  wire [127:0] isa;

  config_pkg_tb dut (.o_xlen(xlen), .o_reg_bits(reg_bits), .o_num_regs(num_regs), .o_addr_bits(addr_bits),
    .o_word_len(word_len), .o_reg_len(reg_len), .o_addr_len(addr_len), .o_map_len(map_len),
    .o_is_64(is_64), .o_is_e(is_e), .o_has_multiplication(has_multiplication), .o_has_any_counter(has_any_counter),
    .o_has_sscof(has_sscof), .o_isa_ok(isa_ok), .o_has_icache(has_icache), .o_flash_on_bus(flash_on_bus),
    .o_ram_on_bus(ram_on_bus), .o_has_dcache(has_dcache), .o_boot_end(boot_end), .o_flash_base(flash_base), .o_flash_end(flash_end),
    .o_ram_base(ram_base), .o_ram_end(ram_end),
    .o_isa(isa));

  always @(posedge clk) begin
    // 1. A base escolhe a largura da palavra e a do índice de registrador.
    assert (is_64 == `IS64);
    assert (is_e == `BASEE);
    assert (xlen == XL);
    assert (reg_bits == RB);
    assert (num_regs == (8'd1 << RB));
    // 2. Os subtipos têm a largura das constantes.
    assert (word_len == xlen);
    assert (reg_len == reg_bits);
    assert (addr_len == AB);
    assert (map_len == AB + 1);
    assert (addr_bits == AB);
    // 3. O endereço físico não passa de XLEN bits.
    assert (AB <= xlen);
    // 4. O mapa é crescente e cabe em 2**ADDR_BITS: BOOT_MEMORY, FLASH e RAM, nessa ordem e sem vazio.
    assert (boot_end <= flash_base && flash_base < flash_end);
    assert (flash_end <= ram_base && ram_base < ram_end);
    assert (ram_end <= {1'b1, {AB{1'b0}}});
    // 5. O check_isa aceitou, e o nome da ISA começa com a base.
    assert (isa_ok);
    assert (isa[127:96] == (`IS64 ? "rv64" : "rv32"));
    // 6. No padrão não há multiplicação, caches nem barramento, e a regra estrita de cache vale.
    assert (!has_multiplication);
    assert (!has_any_counter && !has_sscof);
    assert (!has_icache || flash_on_bus);
    assert (!has_dcache || ram_on_bus);
  end
endmodule
