`ifndef DUMP_INCLUDED
`define DUMP_INCLUDED

task dump;
  string dumpfile;
  if ($value$plusargs("dumpfile=%s", dumpfile)) begin
    $dumpfile(dumpfile);
    $dumpvars;
  end
endtask : dump

`endif
