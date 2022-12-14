// ACCUMULATOR BASED CPU DESIGN - 0.01

module CPUACC #(parameter W = 4)(
  // Global Signals
  input cpuClk,
  input cpuRst,
  input wm,
  // Output 
  output [W-1 : 0] cpuOut
); 
  
// CPU Register instantiation 
  // 32 locations deep 16 bits wide
  reg [15:0] mem [0:31]; 
  reg [3:0] ACC; // Accumulator register 
  reg [31:0] IR; // Instruction Register 
  reg [3:0] A; // Value 1
  
  reg OF;  // To handle Overflow (Simple Flag)
  reg [4:0] PC; // Program Counter
 
  
  // Instruction Deocode Stage
  reg [2:0] opcode; // Opcode
  reg [4:0] SA0; // Source Address
  reg [4:0] DA0; // Destination Address
  reg [2:0] Sa; // Shift amount
  
  // Decode Signals
  reg add, sub, mul, srl, sra, sll, nul, ld; 
  
  always @ (*)
    begin
      if (~cpuRst) 
        begin
          opcode = 3'b111; // Defaults to load A 
          // Clears the remaining values
          SA0 = 0; 
          DA0 = 0;
          Sa  = 0; 
          PC  = 0;  
          add = 0;
          sub = 0; 
          mul = 0; 
          srl = 0; 
          sra = 0; 
          sll = 0; 
          nul = 0; 
          ld  = 0; 
          A = 0; 
          ACC = 0; 
        end
      else 
        begin

          // Decode
          IR     = mem[PC]; 
          opcode = IR[5:3]; 
          Sa     = IR[2:0]; 
          SA0    = IR[15:11]; 
          DA0   = IR[10:6];      
          
          // Fetch 
          A = mem[SA0]; 
          
          case (opcode) 
               3'b000 : begin
                  add = 1;
                  sub = 0; 
                  mul = 0; 
                  srl = 0; 
                  sra = 0; 
                  sll = 0; 
                  nul = 0; 
                  ld  = 0; 
        
               end
              3'b001 : begin
                  add = 0;
                  sub = 1; 
                  mul = 0; 
                  srl = 0; 
                  sra = 0; 
                  sll = 0; 
                  nul = 0; 
                  ld  = 0; 
         
              end
              3'b010 : begin
                  add = 0;
                  sub = 0; 
                  mul = 1; 
                  srl = 0; 
                  sra = 0; 
                  sll = 0; 
                  nul = 0; 
                  ld  = 0; 
        
              end
              3'b011 : begin
                  add = 0;
                  sub = 0; 
                  mul = 0; 
                  srl = 1; 
                  sra = 0; 
                  sll = 0; 
                  nul = 0; 
                  ld  = 0; 
           
              end
              3'b100 : begin
                  add = 0;
                  sub = 0; 
                  mul = 0; 
                  srl = 0; 
                  sra = 1; 
                  sll = 0; 
                  nul = 0; 
                  ld  = 0; 
           
              end
              3'b101 : begin
                  add = 0;
                  sub = 0; 
                  mul = 0; 
                  srl = 0; 
                  sra = 0; 
                  sll = 1; 
                  nul = 0; 
                  ld  = 0; 
           
              end
              3'b110 : begin
                  add = 0;
                  sub = 0; 
                  mul = 0; 
                  srl = 0; 
                  sra = 0; 
                  sll = 0; 
                  nul = 1; 
                  ld  = 0; 
              
              end
              3'b111 : begin
                  add = 0;
                  sub = 0; 
                  mul = 0; 
                  srl = 0; 
                  sra = 0; 
                  sll = 0; 
                  nul = 0; 
                  ld  = 1; 
                  
              end
          endcase
        end
    end
  
  // Output Logic - Execute
  
  always @ (posedge cpuClk or negedge cpuRst)
    begin
      if (~cpuRst)
        begin
          ACC <= 0;
          IR  <= 0; 
        end 
      else 
        begin
          PC = PC + 1; 
          case({add, sub, mul, srl, sra, sll, nul, ld})
            8'b1000_0000 : {OF, ACC} <= ACC + A[3:0]; 
            8'b0100_0000 : {OF, ACC} <= ACC - A[3:0]; 
              8'b0010_0000 : ACC <= ACC * A[3:0]; 
              8'b0001_0000 : ACC <= A[3:0] >> Sa;
              8'b0000_1000 : ACC <= A[3:0] >>> Sa; 
              8'b0000_0100 : ACC <= A[3:0] << Sa; 
              8'b0000_0010 : ACC <= 0; 
              8'b0000_0001 : ACC <= A[3:0]; 
              default : ACC <= 0; 
          endcase
        end
    end
  
  // Drive
  
  assign cpuOut = ACC; // CPU output logic
  //assign mem[DA0] = wm  ? ACC : 0; // Writing data to memory 
            
endmodule
