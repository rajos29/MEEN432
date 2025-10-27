function [urbanCycle, highwayCycle] = load_epa_cycles()
    % Load Urban Cycle
    urbanData = readmatrix('urban_cycle.txt');
    urbanTime = urbanData(:,1);
    urbanSpeed = urbanData(:,2); 

    % Load Highway Cycle
    highwayData = readmatrix('highway_cycle.txt');
    highwayTime = highwayData(:,1);
    highwaySpeed = highwayData(:,2); 

    % Interpolate to uniform time step (e.g., 0.1s)
    dt = 0.1;
    tUrban = urbanTime(1):dt:urbanTime(end);
    tHighway = highwayTime(1):dt:highwayTime(end);
    urbanCycle = [tUrban', interp1(urbanTime, urbanSpeed, tUrban)'];
    highwayCycle = [tHighway', interp1(highwayTime, highwaySpeed, tHighway)'];
end
