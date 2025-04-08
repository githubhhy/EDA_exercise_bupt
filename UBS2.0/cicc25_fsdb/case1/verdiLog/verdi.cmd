debImport "case1.fsdb"
wvCreateWindow
wvSetPosition -win $_nWave2 {("G1" 0)}
wvOpenFile -win $_nWave2 \
           {/home/ICer/EDA_exercise_bupt/UBS2.0/cicc25_fsdb/case1/case1.fsdb}
wvSetCursor -win $_nWave2 1699901.496261
wvRestoreSignal -win $_nWave2 \
           "/home/ICer/EDA_exercise_bupt/UBS2.0/cicc25_fsdb/case1/signal.rc" \
           -overWriteAutoAlias on -appendSignals on
verdiDockWidgetMaximize -dock windowDock_nWave_2
wvScrollUp -win $_nWave2 24
wvSelectSignal -win $_nWave2 {( "crc5_ru" 21 )} 
wvSelectSignal -win $_nWave2 {( "crc5_ru" 22 )} 
wvSelectSignal -win $_nWave2 {( "crc5_ru" 22 24 )} 
wvSetCursor -win $_nWave2 1390224.602710 -snap {("crc5_ru" 22)}
wvSetCursor -win $_nWave2 753129.548555 -snap {("crc5_ru" 22)}
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 3691210.519952 -snap {("crc5_ru" 24)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 744955.333749 -snap {("crc5_ru" 24)}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
debExit
