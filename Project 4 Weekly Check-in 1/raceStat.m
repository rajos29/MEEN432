function raceStats = raceStat(X, Y, t, path)
% raceStat: Calculates laps and off-track events for EV simulation
% Inputs:
%   X, Y - vehicle trajectory positions
%   t    - simulation time vector
%   path - structure with fields: radius, l_st, width
% Outputs:
%   raceStats.loops   - Number of full laps completed
%   raceStats.tloops  - Time instances when start line is crossed
%   raceStats.leftTrack - Struct of X, Y, t where car left the track

    prev_section = 6;
    loops = -1;
    j = 0;
    k = 0;
    tloops = [];
    Xerr = [];
    Yerr = [];
    terr = [];
    
    for i = 1:length(X)
        if ~isfinite(X(i)) || ~isfinite(Y(i))
            continue;  % Skip bad data points
        end
        
        % Track section identification
        if X(i) < path.l_st
            if X(i) >= 0
                if Y(i) < path.radius
                    section = 1; % 1st straight
                else
                    section = 4; % top straight
                end
            else
                if Y(i) < path.radius
                    section = 6; % curve after backstraight
                else
                    section = 5; % top-left curve
                end
            end
        else
            if Y(i) < path.radius
                section = 2; % bottom-right curve
            else
                section = 3; % top-right curve
            end
        end

        % Lap detection with timing gap to prevent noise
        if section == 1 && prev_section == 6
            if isempty(tloops) || (t(i) - tloops(end) > 5)
                loops = loops + 1;
                j = j + 1;
                tloops(j) = t(i);
            end
        end
        prev_section = section;

        % Track boundary check
        if ~insideTrack(X(i), Y(i), section, path)
            k = k + 1;
            Xerr(k) = X(i);
            Yerr(k) = Y(i);
            terr(k) = t(i);
        end
    end

    raceStats.loops = loops;
    raceStats.tloops = tloops;
    raceStats.leftTrack.X = Xerr;
    raceStats.leftTrack.Y = Yerr;
    raceStats.leftTrack.t = terr;
end

function yesorno = insideTrack(x, y, section, path)
    buffer = 0.5;  % Add small tolerance for precision errors
    switch section
        case 1
            yesorno = (y < (0 + path.width + buffer)) && (y > (0 - path.width - buffer));
        case {2, 3}
            rad = sqrt((x - path.l_st)^2 + (y - path.radius)^2);
            yesorno = (rad < (path.radius + path.width + buffer)) && ...
                      (rad > (path.radius - path.width - buffer));
        case 4
            yesorno = (y < (2 * path.radius + path.width + buffer)) && ...
                      (y > (2 * path.radius - path.width - buffer));
        case {5, 6}
            rad = sqrt((x - 0)^2 + (y - path.radius)^2);
            yesorno = (rad < (path.radius + path.width + buffer)) && ...
                      (rad > (path.radius - path.width - buffer));
        otherwise
            yesorno = 0;
    end
end
