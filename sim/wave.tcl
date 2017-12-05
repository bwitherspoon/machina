for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set clk [ gtkwave::getFacName $idx ]
  if {[regexp {^[[:alnum:]_]+\.uut\.clk} $clk]} {
    gtkwave::addSignalsFromList $clk
    break
  }
}

for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set rst [ gtkwave::getFacName $idx ]
  if {[regexp {^[[:alnum:]_]+\.uut\.rst} $rst]} {
    gtkwave::addSignalsFromList $rst
    break
  }
}

set arg [list]
for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set sig [ gtkwave::getFacName $idx ]
  if {[regexp {^[[:alnum:]_]+\.uut\.arg_.+[^.]} $sig]} {
    lappend arg $sig
  }
}
gtkwave::addSignalsFromList $arg
gtkwave::/Edit/Create_Group arg
gtkwave::/Edit/Toggle_Group_Open|Close

set res [list]
for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set sig [ gtkwave::getFacName $idx ]
  if {[ regexp {^[[:alnum:]_]+\.uut\.res_.+[^.]} $sig ]} {
    lappend res $sig
  }
}
gtkwave::addSignalsFromList $res
gtkwave::/Edit/Create_Group res
gtkwave::/Edit/Toggle_Group_Open|Close

set err [list]
for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set sig [ gtkwave::getFacName $idx ]
  if {[ regexp {^[[:alnum:]_]+\.uut\.err_.+[^.]} $sig ]} {
    lappend err $sig
  }
}
gtkwave::addSignalsFromList $err
gtkwave::/Edit/Create_Group err
gtkwave::/Edit/Toggle_Group_Open|Close

set fbk [list]
for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set sig [ gtkwave::getFacName $idx ]
  if {[ regexp {^[[:alnum:]_]+\.uut\.fbk_.+[^.]} $sig ]} {
    lappend fbk $sig
  }
}
gtkwave::addSignalsFromList $fbk
gtkwave::/Edit/Create_Group fbk
gtkwave::/Edit/Toggle_Group_Open|Close

gtkwave::setMarker 0
gtkwave::/Edit/UnHighlight_All
gtkwave::/View/Show_Filled_High_Values
gtkwave::/Edit/Set_Trace_Max_Hier 2
gtkwave::/Time/Zoom/Zoom_Full
