% Initialize workspace
init_project3;
[urbanCycle, highwayCycle] = load_epa_cycles;

% --- Run Urban Cycle ---
disp('Running Urban Cycle...');
assignin('base', 'target_speed_profile', urbanCycle);
assignin('base', 'vehicle', vehicle);


set_param('simulink_project3', 'StopTime', num2str(urbanCycle(end,1)));

simOutUrban = sim('simulink_project3.slx');
vehicle_speed = simOutUrban.vehicle_speed;

% Extract and plot Urban results
timeUrban = vehicle_speed.time;
actualUrban = vehicle_speed.signals.values;
targetUrban = interp1(urbanCycle(:,1), urbanCycle(:,2), timeUrban);

figure;
plot(timeUrban, actualUrban, 'b', timeUrban, targetUrban, 'r--');
xlabel('Time (s)');
ylabel('Speed (mph)');
legend('Actual', 'Target');
title('Urban Cycle Tracking');

check_speed_error(actualUrban, targetUrban);

% --- Run Highway Cycle ---
disp('Running Highway Cycle...');
assignin('base', 'target_speed_profile', highwayCycle);

set_param('simulink_project3', 'StopTime', num2str(highwayCycle(end,1)));

simOutHighway = sim('simulink_project3.slx');
vehicle_speed = simOutHighway.vehicle_speed;

% Extract and plot Highway results
timeHighway = vehicle_speed.time;
actualHighway = vehicle_speed.signals.values;
targetHighway = interp1(highwayCycle(:,1), highwayCycle(:,2), timeHighway);

figure;
plot(timeHighway, actualHighway, 'g', timeHighway, targetHighway, 'r--');
xlabel('Time (s)');
ylabel('Speed (mph)');
legend('Actual', 'Target');
title('Highway Cycle Tracking');

check_speed_error(actualHighway, targetHighway);
