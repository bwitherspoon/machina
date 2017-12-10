`ifndef RESET_INCLUDED
`define RESET_INCLUDED

logic rst = 0;

task reset;
  begin
    rst = 1;
    repeat (2) @ (posedge clk);
    #1 rst = 0;
  end
endtask : reset

`endif // RESET_INCLUDED
