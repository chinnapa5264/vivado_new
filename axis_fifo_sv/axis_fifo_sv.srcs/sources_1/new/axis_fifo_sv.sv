`timescale 1ns / 1ps
module fifo_top #(
  parameter  DataWidth = 32,
  parameter  Depth     = 4096,
  localparam PtrWidth  = $clog2(Depth)
) (
  input  logic                 clk,
  input  logic                 reset,
  
  //input  logic                 writeReq,
  
  input  logic [DataWidth-1:0] writeData,
  input  logic                 writeDataValid,
  output logic                 writeDataReady,
  input  logic                 writeDataLast,
   
  //input  logic                 readReq,
  
  output logic [DataWidth-1:0] readData,
  output logic                 readDataValid,
  input  logic                 readDataReady,
  output logic                 readDataLast,
  
  output logic                 full,
  output logic                 empty
);

//logic write_to_fifo_2;
//logic read_from_fifo_2;
//logic write_to_fifo_1;
//logic read_from_fifo_1;

logic [DataWidth-1:0] readData_1;
logic readDataValid_1;
logic readDataReady_1;
logic readDataLast_1;


 fifo_2048 fifo1(
  .clk(clk),
  .reset(reset),
  
  //.writeReq(writeReq_1),
  
  .writeData(writeData),
  .writeDataValid(writeDataValid),
  .writeDataReady(writeDataReady),
  .writeDataLast(writeDataLast),
   
  //.readReq(readReq_1),
  
  .readData(readData_1),
  .readDataValid(readDataValid_1),
  .readDataReady(readDataReady_1),
  .readDataLast(readDataLast_1),
  
  .full(full_1),
  .empty(empty_1)
  //.abt_full(abt_full_1),
  //.abt_empty(abt_empty_1)
);

fifo_2048 fifo2(
 
  .clk(clk),
  .reset(reset),
  
  //.writeReq(writeReq_2),
  
  .writeData(readData_1),
  .writeDataValid(readDataValid_1),
  .writeDataReady(readDataReady_1),
  .writeDataLast(readDataLast_1),
   
  //.readReq(readReq_2),
  
  .readData(readData),
  .readDataValid(readDataValid),
  .readDataReady(readDataReady),
  .readDataLast(readDataLast),
  
  .full(full_2),
  .empty(empty_2)
  
 // .abt_full(abt_full_2),
  //.abt_empty(abt_empty_2)
);
endmodule

module fifo_2048 #(
  parameter  DataWidth = 32,
  parameter  Depth     = 2048,
  localparam PtrWidth  = $clog2(Depth)
) (
  input  logic                 clk,
  input  logic                 reset,
  
  //input  logic                 writeReq,
  
  input  logic [DataWidth-1:0] writeData,
  input  logic                 writeDataValid,
  output logic                 writeDataReady,
  input  logic                 writeDataLast,
  
 //input  logic                 readReq,
  
  output logic [DataWidth-1:0] readData,
  output logic                 readDataValid,
  input  logic                 readDataReady,
  output logic                 readDataLast,
  
  
  output logic                 full,
  output logic                 empty
  
 /* output logic                 abt_full,
  output logic                 abt_empty*/
);

  logic [DataWidth-1:0] mem[Depth];
  logic [PtrWidth:0] wrPtr, wrPtrNext;
  logic [PtrWidth:0] rdPtr, rdPtrNext;
 
  logic valid_out;
  logic ready;
  logic enable;
  logic out_tlast;
  
  logic full_w;
  logic full_r;
  logic empty_r;
  logic empty_w;

  logic [PtrWidth:0] t_last_reg [Depth/2-1:0];
  
  logic [PtrWidth-1:0] tlast_count_write;
  logic [PtrWidth-1:0] tlast_count_next_write;
  
  logic [PtrWidth-1:0] tlast_count_read;
  logic [PtrWidth-1:0] tlast_count_next_read;
  

  always_ff @(posedge clk or posedge reset) begin
    if (reset == 1) begin
      wrPtr <= '0;
      rdPtr <= '0;
    end 
    /*else if(!full & (rdPtr == {{PtrWidth-1{1'b0}},1'b1,1'b0})) begin
     wrPtr <= '0;
     rdPtr <= rdPtrNext;
     end
     
     else if(!empty &(rdPtr == {1'b1,{PtrWidth{1'b0}}})) begin
      rdPtr <= '0;
       wrPtr <= wrPtrNext;
       end
    */
     else begin
      wrPtr <= wrPtrNext;
      rdPtr <= rdPtrNext;
    end
  end
  
    always_comb begin
    wrPtrNext = wrPtr;
    rdPtrNext = rdPtr;
    if (enable) begin //& wrPtr <= {1'b0,{PtrWidth{1'b1}}}
      wrPtrNext = wrPtr + 1;
    end
    if (enable2) begin //& rdPtr <= {1'b0,{PtrWidth{1'b1}}}
      rdPtrNext = rdPtr + 1;
    end
  end
  
    
    always_ff @(posedge clk) begin
        if (enable)
        mem[wrPtr[PtrWidth-1:0]] <= writeData; //mem[wrPtr][PtrWidth-1:0]
    end  
    
     always_ff @(posedge clk) begin
        if (enable2) 
        readData <= mem[rdPtr[PtrWidth-1:0]];
    end 
    
   always_ff @ (posedge clk or posedge reset)
    begin
    if (reset == 1)
    begin
      valid_out <= 0;
    end
      else if ( enable2 )
      begin
        valid_out <= enable2;
      end
   end
   

  always_ff @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      full_r <= 0;
    end
      else if (full_w == 1)
        full_r <= 1'b1;
      else
        full_r <= 1'b0;
   end
   
   always_ff @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      empty_r <= 1'b1;
    end
    else if( empty_w )
       empty_r <= 1'b1;
       else
       empty_r <= 1'b0;
   end

  
 always_ff @ (posedge clk)
  begin
     if (t_last == 1)
      begin
        t_last_reg[tlast_count_write] <= wrPtr;
      end
   end
   
   //counter
  always_ff @ (posedge clk or posedge reset) begin
  if (reset == 1)
    tlast_count_write <= 0;
    else if (t_last == 1)
      begin
        tlast_count_write <= tlast_count_next_write;
      end
   end
   
    always@(*)
    tlast_count_next_write = tlast_count_write + 1;
    
    
  always_ff @ (posedge clk or posedge reset)
  begin
  if(reset)
   out_tlast <= 1'b0;
    else if (enable2 == 1) 
      begin
       if(rdPtr == t_last_reg[tlast_count_read])
          begin
         out_tlast <= 1'b1;
          end
       else
         out_tlast <= 1'b0;
      end
  end
  
   //counter
  always_ff @ (posedge clk or posedge reset) begin
  if (reset)
    tlast_count_read <= 0;
     else if (rdPtr == t_last_reg[tlast_count_read])
      begin
        tlast_count_read <= tlast_count_next_read;
      end
   end
   
  always@(*)
   tlast_count_next_read = tlast_count_read + 1;
  

   
  assign ready =  (!full_w);
  assign enable = ((ready == 1) & (writeDataValid == 1)); 
  
  assign enable2 = readDataReady & !empty_w;
  
  assign writeDataReady =  (ready == 1);
  
  assign readDataValid = valid_out;
  
  assign  t_last =  writeDataValid & writeDataLast;
  assign  readDataLast = out_tlast;
  
  assign full = full_r;
  assign empty = empty_r;

  assign empty_w = (wrPtr[PtrWidth] == rdPtr[PtrWidth]) && (wrPtr[PtrWidth-1:0] == rdPtr[PtrWidth-1:0]);
  assign full_w  = (wrPtr[PtrWidth] != rdPtr[PtrWidth]) && (wrPtr[PtrWidth-1:0] == rdPtr[PtrWidth-1:0]);

  //assign abt_full = full_w;
  //assign abt_empty = empty_w;
  
endmodule