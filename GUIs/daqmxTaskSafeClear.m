function daqmxTaskSafeClear(task)
% Clears task only if it is present, avoids error otherwise
    try
        clkRate = task.sampClkRate; % if this call fails, the task does not exist anymore
        task.clear();
    catch ME
    end
end