debImport "-f" "filelist.f"
debLoadSimResult /home/ICer/EDA_exercise_bupt/exercise1_temp/tb.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 106140256.827746
wvRestoreSignal -win $_nWave2 \
           "/home/ICer/EDA_exercise_bupt/exercise1_temp/signal.rc" \
           -overWriteAutoAlias on -appendSignals on
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 26482405.002253 -snap {("G2" 1)}
wvSelectSignal -win $_nWave2 {( "G2" 5 )} 
wvSelectSignal -win $_nWave2 {( "G2" 4 5 )} 
wvZoom -win $_nWave2 0.000000 35452251.857854
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 309398697.225573 -snap {("G3" 0)}
debExit
