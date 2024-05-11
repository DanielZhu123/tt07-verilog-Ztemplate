/*
 * Copyright (c) 2024 ZHU QUANHAO
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_DanielZhu123 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
  logic [9:0] con_ans;
  logic con_error;
  // All output pins must be assigned. If not used, assign to 0.
  assign uio_oe  = 1;
    
keyboard keyboardreal(.reset(rst_n),
                      .modesel(ui_in[7]),
                      .signsel_dispA(ui_in[6]),
                      .positionsel_dispB(ui_in[5]),
                      .numbersel_NOT(ui_in[4]),
                      .bit4_ADD(ui_in[3]),
                      .bit3_AND(ui_in[2]),
                      .bit2_OR(ui_in[1]),
                      .bit1_XOR(ui_in[0]),
                      .ans(con_ans),
                      .error(con_error));

bit_10NT bit_10NTreal(.data(con_ans),
                      .clk(clk),
                      .display({uo_out,uio_out[5:0]}),
                      .power13(uio_out[6]),
                      .power24(uio_out[7]),
                      .error(con_error));

endmodule
