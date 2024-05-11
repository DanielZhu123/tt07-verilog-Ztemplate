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





module keyboard
/*This part is to get an output answer for further display
by turning on and off switches to do all kinds of calculation
*/
(input logic reset,
input logic modesel,
input logic signsel_dispA,
input logic positionsel_dispB,
input logic numbersel_NOT,
input logic bit4_ADD,
input logic bit3_AND,
input logic bit2_OR,
input logic bit1_XOR,
output logic[9:0] ans,
output logic error);//more than one function activate(except NOT)
/*inputmode(0)    diaplaymode(1)
A=x|xxxx|xxxx
B=x|xxxx|xxxx

under inputmode(0) the function of each switch is
signsel      +(0)/-(1)        (x)|xxxx|xxxx
positionsel  L1(0)/L2(1)      x|(xxxx)L1|(xxxx)L2
numbersel     A(0)/B(1)
bit4-bit1       0/1           (xxxx)

under diaplaymode(1) the function of each switch is 
dispA     ans=A
dispB     ans=B
NOT       ans=~ans
ADD       ans=A+B
AND       ans=A&B
OR        ans=A|B     
XOR       ans=A^B
*/
//reset A B into 0
logic[8:0]     numA;
logic[9:0]     numAmid;//numA extend 1 bit
logic[8:0]     numB;
logic[9:0]     numBmid;//numB extend 1 bit




always@(*)begin
if(reset==0)begin
  if(modesel==0)begin
  //number input state
    error=0;
    if(numbersel_NOT==0)begin
      numA[8]=signsel_dispA;// A +/-
      if(positionsel_dispB==0)begin
        //A L1 
        numA[7]=bit4_ADD;
        numA[6]=bit3_AND;
        numA[5]=bit2_OR;
        numA[4]=bit1_XOR;
      end
      else begin
        //A L2
        numA[3]=bit4_ADD;
        numA[2]=bit3_AND;
        numA[1]=bit2_OR;
        numA[0]=bit1_XOR;
      end
      numAmid={numA[8],numA};//prevent overflow in calculation
      ans=numAmid;//can see display of A when inputing A
    end
    else begin
      numB[8]=signsel_dispA;// B +/-
      if(positionsel_dispB==0)begin
        //B L1 
        numB[7]=bit4_ADD;
        numB[6]=bit3_AND;
        numB[5]=bit2_OR;
        numB[4]=bit1_XOR;
      end
      else begin
        //B L2
        numB[3]=bit4_ADD;
        numB[2]=bit3_AND;
        numB[1]=bit2_OR;
        numB[0]=bit1_XOR;
      end
      numBmid={numB[8],numB};//prevent overflow in calculation
      ans=numBmid;//can see display of B when inputing B
    end
  end
  else begin
  //calculate state
    if((signsel_dispA&&~positionsel_dispB&&~bit4_ADD&&~bit3_AND&&~bit2_OR&&~bit1_XOR)||
       (~signsel_dispA&&positionsel_dispB&&~bit4_ADD&&~bit3_AND&&~bit2_OR&&~bit1_XOR)||
       (~signsel_dispA&&~positionsel_dispB&&bit4_ADD&&~bit3_AND&&~bit2_OR&&~bit1_XOR)||
       (~signsel_dispA&&~positionsel_dispB&&~bit4_ADD&&bit3_AND&&~bit2_OR&&~bit1_XOR)||
       (~signsel_dispA&&~positionsel_dispB&&~bit4_ADD&&~bit3_AND&&bit2_OR&&~bit1_XOR)||
       (~signsel_dispA&&~positionsel_dispB&&~bit4_ADD&&~bit3_AND&&~bit2_OR&&bit1_XOR))begin
       //only one function switch is on can calculate(except numbersel_NOT)
      error=0;
      if(signsel_dispA==1)begin
        //A
        ans=numAmid;
      end
      if(positionsel_dispB==1)begin
        //B
        ans=numBmid;
      end
      if(bit4_ADD==1)begin
        //A+B
        ans=numAmid+numBmid;
      end
      if(bit3_AND==1)begin
        //A&B
        ans=numAmid&numBmid;
      end
      if(bit2_OR==1)begin
        //A|B
        ans=numAmid|numBmid;
      end
      if(bit1_XOR==1)begin
        //A^B
        ans=numAmid^numBmid;
      end
      if(numbersel_NOT==1)begin
        //ans=~ans
        ans=~ans;
      end
    end
    else begin
      error=1;//function can not work at same time
    end
  end
end
else begin
  numA=9'b0;
  numB=9'b0;
  error=1;
end
end

endmodule






module bit_10NT(
input logic[9:0] data,//number to be displayed
input logic clk,
input logic error,
output logic[13:0] display,//tube control signal 
output logic power13,//power contol of 1 and 3 NT
output logic power24);//power contol of 2 and 4 NT

logic[9:0] data_tep;
logic[3:0] sign;//display +/-
logic[3:0] num1;//display largest digit
logic[3:0] num2;//display second largest digit
logic[3:0] num3;//display least digit

always@(*)begin
  if(error==0)begin//alternately display
    if(data[9]==0)begin
    //positive number
      data_tep=data;
      sign=0;
    end
    else begin
    //negative number
      data_tep=~data+1;
      sign=1;
    end
    //turn data in to three digits
    num1=data_tep/9'd100;
    num2=data_tep/9'd10-9'd10*num1;
    num3=data_tep%9'd10;
    if(clk==0)begin
    //disply the first and third Nixie tube
      power13=1;
      power24=0;
      case(sign)
        4'd0:display[13:7]=7'b1111111;//+ 
        4'd1:display[13:7]=7'b1111110;//-
        default:display[13:7]=7'b0000000;
      endcase
      case(num2)
        4'd0:display[6:0]=7'b0000001;//0
        4'd1:display[6:0]=7'b1001111;//1
        4'd2:display[6:0]=7'b0010010;//2
        4'd3:display[6:0]=7'b0000011;//3
        4'd4:display[6:0]=7'b1001100;//4
        4'd5:display[6:0]=7'b0100100;//5
        4'd6:display[6:0]=7'b0100000;//6
        4'd7:display[6:0]=7'b0001111;//7  
        4'd8:display[6:0]=7'b0000000;//8
        4'd9:display[6:0]=7'b0000100;//9
        default:display[6:0]=7'b1111111;
      endcase
    end
    else begin
    //disply the second and fourth Nixie tube
      power13=0;
      power24=1;
      case(num1)
        4'd0:display[13:7]=7'b0000001;
        4'd1:display[13:7]=7'b1001111; 
        4'd2:display[13:7]=7'b0010010; 
        4'd3:display[13:7]=7'b0000011;
        4'd4:display[13:7]=7'b1001100;
        4'd5:display[13:7]=7'b0100100;
        4'd6:display[13:7]=7'b0100000;
        4'd7:display[13:7]=7'b0001111;
        4'd8:display[13:7]=7'b0000000;
        4'd9:display[13:7]=7'b0000100;
        default:display[13:7]=7'b1111111;
      endcase
      case(num3)
        4'd0:display[6:0]=7'b0000001;
        4'd1:display[6:0]=7'b1001111; 
        4'd2:display[6:0]=7'b0010010; 
        4'd3:display[6:0]=7'b0000011;
        4'd4:display[6:0]=7'b1001100;
        4'd5:display[6:0]=7'b0100100;
        4'd6:display[6:0]=7'b0100000;
        4'd7:display[6:0]=7'b0001111;
        4'd8:display[6:0]=7'b0000000;
        4'd9:display[6:0]=7'b0000100;
        default:display[6:0]=7'b1111111;
      endcase
     end
  end
  else begin//no display
     power13=0;
     power24=0;
  end
end
endmodule
