`ifndef DUMP_INCLUDED
`define DUMP_INCLUDED

task dump;
  begin
    string dumpfile;
    if ($value$plusargs("dumpfile=%s", dumpfile)) begin
      $dumpfile(dumpfile);
      $dumpvars;
    end
  end
endtask : dump

`endif
