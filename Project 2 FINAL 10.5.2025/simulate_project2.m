%  Project 2: Final Deliverable 


clear; clc; close all;

disp('Initializing Vehicle and Track Data');
init;             
gentrack;         

disp('Running Simulink Model');
simOut = sim('simulink_w1', ...
    'SrcWorkspace', 'current', ...
    'SaveOutput', 'on', ...
    'ReturnWorkspaceOutputs', 'on');

% Extract simulation outputs
X   = simOut.X.Data;
Y   = simOut.Y.Data;
psi = simOut.psi.Data;
t   = simOut.tout;

disp('Calculating Race Statistics');
race = raceStat(X, Y, t, path);

% Display Results
fprintf('\nRace Summary\n');
fprintf('Laps Completed: %d\n', race.loops);
if ~isempty(race.tloops)
    fprintf('Lap Completion Time: %.2f seconds\n', race.tloops(end));
    for i = 2:length(race.tloops)
        fprintf('  Lap %d: %.2f seconds\n', i-1, race.tloops(i));
    end

else
    fprintf('Lap Completion Time: Not completed\n');
end
if isempty(race.leftTrack.X)
    fprintf('Vehicle stayed within track limits\n');
else
    fprintf('Vehicle left the track at t = %.2f s\n', race.leftTrack.t(1));
end

disp('Generating Animation');
animate;
