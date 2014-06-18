function updateFrameCount(src,event)
    global stimData
    stimData = cat(1,stimData,[event.TimeStamps, event.Data]);

end