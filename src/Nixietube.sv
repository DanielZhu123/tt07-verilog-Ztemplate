module bit_10NT(
input wire [9:0] data,//number to be displayed
input wire clk,
input wire error,
output wire [13:0] display,//tube control signal 
output wire power13,//power contol of 1 and 3 NT
output wire power24);//power contol of 2 and 4 NT

reg[9:0] data_tep;
reg[3:0] sign;//display +/-
reg[3:0] num1;//display largest digit
reg[3:0] num2;//display second largest digit
reg[3:0] num3;//display least digit

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
