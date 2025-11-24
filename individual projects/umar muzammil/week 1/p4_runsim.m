p4_init(); %runs the init file

simout = sim("p4_car_colton_update1.slx");
sim_vel = simout.veh_speed.Data;
sim_time = simout.tout;

car_X = simout.X.Data;
car_Y = simout.Y.Data;
car_time = simout.tout;
xpath = path.xpath;
ypath = path.ypath;
actual_speed = simout.ActualSpeed.Data;
desired_speed = simout.veh_speed_desd.Data;
desired_torque = simout.motor_torque.Data;
brake = simout.brakeCmnd.Data;
batSOC = simout.SOC.Data;
termVolt = simout.V_bat.Data;
current = simout.I_bat.Data;
% battery
batteryPower = termVolt .* current;   % instantaneous power [W]

dt = mean(diff(car_time));            % average timestep [s]
batteryEnergy_Wh = sum(batteryPower) * dt / 3600;   % convert J → Wh

yawRate = simout.omega.Data;
MechMotorPower = simout.MotorPower.Data;


figure;
hold on; grid on; axis equal;

% Plot the track (path data)
plot(xpath, ypath, 'b-', 'LineWidth', 2);   % blue line for track

% Plot the car trajectory
plot(car_X, car_Y, 'r-', 'LineWidth', 1.5);   % red line for car path

% Labels and legend
xlabel('X [m]');
ylabel('Y [m]');
legend('Track centerline', 'Car trajectory');
title('Car vs Track');


% Plot speeds vs time
figure;
plot(car_time, actual_speed, 'r-', 'LineWidth', 1.5); hold on;
plot(car_time, desired_speed, 'b--', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Speed [m/s]');
legend('Actual Speed', 'Desired Speed');
title('Vehicle Speed Tracking');
grid on;

% Plot command vs time
figure;
plot(car_time, desired_torque, 'r-', 'LineWidth', 1.5); hold on;
plot(car_time, brake, 'b--', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Command');
title('Command Tracking');
grid on;

figure;

subplot(3,1,1);
plot(car_time, batSOC, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('SOC [%]');
title('Battery State of Charge');
grid on;

subplot(3,1,2);
plot(car_time, termVolt, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Terminal Voltage');
grid on;

subplot(3,1,3);
plot(car_time, current, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Current [A]');
title('Battery Current');
grid on;

% Plot Yaw Rate vs time
figure;
plot(car_time, yawRate, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Yaw Rate');
title('Yaw Rate Tracking');
grid on;

figure;
plot(car_time, yawRate, 'r', 'LineWidth', 1.5); hold on;
plot(car_time, refYawRate, 'b--', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Yaw Rate [rad/s]');
legend('Actual Yaw Rate','Reference Yaw Rate');
title('Yaw Rate Tracking Performance');
grid on;

figure;
plot(car_time, yawError, 'k', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Yaw Rate Error [rad/s]');
title('Yaw Rate Tracking Error');
grid on;


% Plot Motor Power vs time
figure;
plot(car_time, MechMotorPower, 'r-', 'LineWidth', 1.5)
xlabel('Time [s]');
ylabel('Power');
title('Motor Power Tracking');
grid on;

deviation = computeDeviation(car_X, car_Y, path);

figure;
plot(car_time, deviation, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Deviation from centerline [m]');
title('Lateral Deviation vs Time');
grid on;

%  Elevation and Slope Plots 
figure;
subplot(2,1,1);
plot(path.s, path.zpath, 'LineWidth', 1.5);
xlabel('Distance along track [m]');
ylabel('Elevation [m]');
title('Track Elevation Profile');
grid on;

subplot(2,1,2);
plot(path.s, path.dzds, 'LineWidth', 1.5);
xlabel('Distance along track [m]');
ylabel('Slope dz/ds');
title('Slope Profile (dh/ds)');
grid on;


% Lateral Deviation Statistics 
mean_dev = mean(abs(deviation));
max_dev = max(abs(deviation));
std_dev = std(deviation);

fprintf('\nLateral Deviation Summary:\n');
fprintf('  Mean deviation: %.3f m\n', mean_dev);
fprintf('  Max deviation:  %.3f m\n', max_dev);
fprintf('  Std deviation:  %.3f m\n', std_dev);


figure;
histogram(deviation, 40);
xlabel('Lateral Deviation [m]');
ylabel('Count');
title('Distribution of Lateral Deviation');
grid on;



race = raceStat(car_X, car_Y, car_time, path);
fprintf('Simulation Summary');
fprintf('Number of loops completed: %d\n', race.loops);

if isfield(race, 'tloops') && ~isempty(race.tloops)
    fprintf('Start line crossed at times (s):\n');
    disp(race.tloops);
end

if ~isempty(race.leftTrack.X)
    fprintf('Vehicle left the track %d times.\n', length(race.leftTrack.X));
    fprintf('First off-track event at time %.2f s, position (%.2f, %.2f)\n', ...
        race.leftTrack.t(1), race.leftTrack.X(1), race.leftTrack.Y(1));
else
    fprintf('Vehicle stayed on track the entire time.\n');
  
% Approximate curvature from path geometry
dx = gradient(xpath);
dy = gradient(ypath);
ddx = gradient(dx);
ddy = gradient(dy);

curvature = abs(dx .* ddy - dy .* ddx) ./ (dx.^2 + dy.^2).^(3/2);  
curvature(isnan(curvature)) = 0;     % fix at straight sections
curvature(isinf(curvature)) = 0;

% Map car position to closest curvature
refYawRate = zeros(size(car_X));
for i = 1:length(car_X)
    d = hypot(car_X(i) - xpath, car_Y(i) - ypath);
    [~, idx] = min(d);
    refYawRate(i) = curvature(idx) * actual_speed(i);
end
yawError = yawRate - refYawRate;

end

EndSOC = simout.SOC.Data(end);   % get last data point
fprintf('Ending SOC value: %.4f\n', EndSOC);

fprintf('\nBattery Summary:\n');
fprintf('  Ending SOC: %.2f %%\n', EndSOC * 100);
fprintf('  Total Battery Energy Used: %.2f Wh\n', batteryEnergy_Wh);
fprintf('  Max Battery Power: %.1f kW\n', max(batteryPower)/1000);
fprintf('  Peak Current: %.1f A\n', max(current));
fprintf('\nYaw Rate Tracking Summary:\n');
fprintf('  Mean yaw error: %.4f rad/s\n', mean(abs(yawError)));
fprintf('  Max yaw error:  %.4f rad/s\n', max(abs(yawError)));
fprintf('  Std yaw error:  %.4f rad/s\n', std(yawError));
