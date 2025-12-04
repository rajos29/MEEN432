p4_init(); %runs the init file

simout = sim("p4_car_Luke_ind1.slx");
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
yawRate = simout.omega.Data;
MotorPower = simout.MotorPower.Data;


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

% Plot Motor Power vs time
figure;
plot(car_time, MotorPower, 'r-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Motor Power');
title('Motor Power Tracking');
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
end

EndSOC = simout.SOC.Data(end);   % get last data point
fprintf('Ending SOC value: %.4f\n', EndSOC);
