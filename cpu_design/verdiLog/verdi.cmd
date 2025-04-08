debImport "-f" "filelist.f"
debLoadSimResult /home/ICer/EDA_exercise_bupt/cpu_design/tb.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 4731.744792
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {3 17 1 1 4 1}
srcHBSelect "tb_top.uut" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_top.uut" -delim "."
srcHBSelect "tb_top.uut" -win $_nTrace1
srcHBSelect "tb_top.uut" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_top.uut" -delim "."
srcHBSelect "tb_top.uut" -win $_nTrace1
srcHBSelect "tb_top.uut" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {3 31 1 15 1 1} -backward
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvSetCursor -win $_nWave2 4786.979167 -snap {("G1" 16)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 44555.729167 -snap {("G1" 20)}
wvSetCursor -win $_nWave2 40965.494792 -snap {("G1" 13)}
wvSetCursor -win $_nWave2 13532.421875 -snap {("G1" 11)}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSetCursor -win $_nWave2 29734.505208 -snap {("G1" 9)}
wvSetCursor -win $_nWave2 67477.994792 -snap {("G1" 8)}
debExit
