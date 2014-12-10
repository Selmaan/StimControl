function saveExpt

global stimExpt

% Save expt
stimFile = [evalin('base','hSI.loggingFullFileName(1:end-3)') 'mat'];
stimExpt.StimControl = [];
save(stimFile,'stimExpt')