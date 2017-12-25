for {set idx 0} {$idx < [ gtkwave::getNumFacs ]} {incr idx} {
  set sig [ gtkwave::getFacName $idx ]
  if {[regexp {^testbench\.[[:alnum:]_]+(\[[0-9]+:[0-9]+\])?$} $sig]} {
    gtkwave::addSignalsFromList $sig
  }
}

gtkwave::setMarker 0
gtkwave::/Edit/UnHighlight_All
gtkwave::/View/Show_Filled_High_Values
gtkwave::/Edit/Set_Trace_Max_Hier 1
gtkwave::/Time/Zoom/Zoom_Full
