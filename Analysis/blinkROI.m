function [tOff,tOn] = blinkROI

tOff = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',...
    'set(hEl(nROI),''Visible'',''Off'')');
tOn = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',...
    'set(hEl(nROI),''Visible'',''On'')');

start(tOff),
pause(0.5),
start(tOn),