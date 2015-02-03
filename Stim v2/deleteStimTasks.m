function deleteStimTasks
    
    tasks = {'dummyTask1','Frame Clock divider','X Y Stim','Stim Pockels',...
        'Stim Mirror Pre-positioning','Stim Shutter Toggle','Stim Piezo Position','dummyTask2'};

    m = dabs.ni.daqmx.Task.getTaskMap;
    for taskNum = 1:length(tasks)
        try
            daqmxTaskSafeClear(m(tasks{taskNum})),
        catch ME
        end
    end

end