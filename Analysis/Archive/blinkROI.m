function [tOff,tOn,tOff2,tOn2] = blinkROI

tOff = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',...
    'set(hEl(nROI),''Visible'',''Off'')');
tOn = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',...
    'set(hEl(nROI),''Visible'',''On'')');
tOff2 = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',...
    'set(hEl2(nROI),''Visible'',''Off'')');
tOn2 = timer('ExecutionMode','fixedRate','Period',1,'TimerFcn',...
    'set(hEl2(nROI),''Visible'',''On'')');

start(tOff),start(tOff2),
pause(0.25),
start(tOn),start(tOn2),