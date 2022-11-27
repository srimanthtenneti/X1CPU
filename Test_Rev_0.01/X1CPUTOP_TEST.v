module CPU_TB (); 
  
  // Test ports 
  
  reg cpuClk;
  reg cpuRst;
  reg wm; 
  
  // Variable for itration 
  integer i; 
  
  wire [3:0] cpuOut; 
  
  // Clocking and System Initialization 
  
  initial 
    begin
       cpuClk = 0; 
       cpuRst = 0; 
       wm = 0; 
       forever #4 cpuClk = ~cpuClk; 
    end
  
  // Test instance
  
  CPUACC cpu0 (
    .cpuClk(cpuClk),
    .cpuRst(cpuRst),
    .wm(wm),
    .cpuOut(cpuOut)
  ); 
  
  // Memory write task
  
  task memwrite (input [15:0] data, input [4:0] addr); 
    begin
      cpu0.mem[addr] = data;
    end
  endtask
  
  // Memory Read Task 
  
  task memread (input [4:0] raddr); 
    begin
      $display("The Addr : %d has Value : %b", raddr, cpu0.mem[raddr]); 
    end
  endtask
  
  // Write all zero to locations of the Cpu memory 
  
  initial 
    begin
      for (i = 0 ; i < 32 ; i = i + 1)
        begin
          memwrite(0, i); 
        end
      #8; 
      for (i = 0 ; i < 32 ; i = i + 1)
        begin
          memread(i);
        end
      // $finish; 
    end  
  
  // Read Instructions from a binary file 
  
  initial 
    begin 
      $readmemb("X1CPUTOP_Memory.bin", cpu0.mem); 
    end
  
  // Bin file read test loop 
  
  initial 
    begin
      for (i = 0 ; i < 32 ; i = i + 1)
        begin
          memread(i);
        end
      $display ("Execution Loop ... \n"); 
      // $finish; 
    end
  
  initial 
    begin
      $dumpfile("cpu.vcd"); 
      $dumpvars(); 
      #20;
      cpuRst = 1; 
      #100; 
      $monitor ("CPU output : %b", cpu0.cpuOut); 
      
      $finish; 
    end
endmodule