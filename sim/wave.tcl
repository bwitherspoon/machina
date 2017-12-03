set numfacs [ gtkwave::getNumFacs ]
set signals [list]
for {set i 0} {$i < $numfacs} {incr i} {
  set facname [ gtkwave::getFacName $i ]
  if {[regexp {^[[:alnum:]_]+\.(clk|rst|arg|res|err|fbk)} $facname]} {
    lappend signals "$facname"
  }
}
gtkwave::addSignalsFromList $signals
gtkwave::/Edit/Set_Trace_Max_Hier 1
gtkwave::/Time/Zoom/Zoom_Full
