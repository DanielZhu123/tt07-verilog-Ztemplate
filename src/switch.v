module keyboard
/*This part is to get an output answer for further display
by turning on and off switches to do all kinds of calculation
*/
  (input wire reset,
input wire modesel,
input wire signsel_dispA,
input wire positionsel_dispB,
input wire numbersel_NOT,
input wire bit4_ADD,
input wire bit3_AND,
input wire bit2_OR,
input wire bit1_XOR,
output wire [9:0] ans,
output wire error);//more than one function activate(except NOT)
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
reg[8:0]     numA;
reg[9:0]     numAmid;//numA extend 1 bit
reg[8:0]     numB;
reg[9:0]     numBmid;//numB extend 1 bit




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
