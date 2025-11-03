%% Initialize vehicle, track, and environment
p4_init;        % Load car, motor, battery, track params
gentrack;       % Generate path geometry

% Push variables to base workspace for Simulink access
assignin('base', 'car', car);
assignin('base', 'motor', motor);
assignin('base', 'bat', bat);
assignin('base', 'track', track);
assignin('base', 'path', path);

% Ensure total_length is explicitly defined
total_length = path.total_length;
assignin('base', 'total_length', total_length);

%% Run Simulink model
modelName = 'p4_simulinkk';
load_system(modelName);
set_param(modelName, 'StopTime', '60');
set_param(modelName, 'Solver', 'ode45', 'MaxStep', '0.01');  % more stable
simout = sim(modelName);

%% Get simulation outputs
car_X = simout.X.Data;
car_Y = simout.Y.Data;
car_psi = simout.psi.Data;
car_time = simout.tout;
E_total_J = simout.E_total.Data;

figure;
subplot(3,1,1);
plot(car_time, vx); title('vx');

subplot(3,1,2);
plot(car_time, simout.T_request.Data); title('T\_request');

subplot(3,1,3);
plot(car_time, simout.T_wheel.Data); title('T\_wheel');


%% Battery tracking
nominal_voltage = 3.7;  % V per cell 
bat_capacity_Wh = bat.C * bat.numSeries * bat.numParallel * nominal_voltage / 1000;
initial_SOC = 0.80;
E_total_Wh = E_total_J / 3600;
SOC = initial_SOC - (E_total_Wh / bat_capacity_Wh);

% SOC limits
if any(SOC < 0.10)
    warning('Battery SOC dropped below 10%% — simulation may be invalid.');
end
if any(SOC > 0.95)
    warning('Battery SOC exceeded 95%% — check regen logic or initial conditions.');
end

% Plot SOC over time
figure;
plot(car_time, SOC, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('State of Charge (SOC)');
title('Battery SOC Over Time');
grid on;

%% Animate vehicle on track
fh = figure();
fh.WindowState = 'maximized';
hold on;
plot(path.xpath, path.ypath, '--r'); axis equal;
plot(path.xinpath, path.yinpath, 'b');
plot(path.xoutpath, path.youtpath, 'b');
axis([min(path.xoutpath), max(path.xoutpath), min(path.youtpath), max(path.youtpath)]);
xlabel('X Distance (m)');
ylabel('Y Distance (m)');
title('Project 4 Track');
grid on;

h = animatedline;
L = 15;
width = 5;

for i = 1:length(car_X)
    x = car_X(i);
    y = car_Y(i);
    psi = car_psi(i);

    if ~isfinite(x) || ~isfinite(y)
        continue;  % skip invalid points
    end

    addpoints(h, x, y);
    car_shape = [-L/2 -width/2; -L/2 width/2; L/2 width/2; L/2 -width/2];
    rcar = rotate(car_shape', psi)';
    verts = rcar + [x, y];
    verts = unique(verts, 'rows', 'stable');

    if size(verts, 1) >= 3
        a = polyshape(verts(:,1), verts(:,2));
    else
        a = polyshape();
    end

    ap = plot(a);
    ap.FaceColor = 'k';
    drawnow limitrate;
    pause(0.05);
    delete(ap);
end
disp("Max X: " + max(car_X));
disp("Max Y: " + max(car_Y));

%% === Debug Plots ===

% Extract additional simulation outputs (make sure these are logged in Simulink)
vx      = simout.vx.Data;
vy      = simout.vy.Data;
omega   = simout.omega.Data;
delta_f = simout.delta_f.Data;
T_wheel = simout.T_wheel.Data;

% Longitudinal Velocity
figure;
plot(car_time, vx, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Longitudinal Velocity vx (m/s)');
title('vx Over Time');
grid on;

% Yaw Rate
figure;
plot(car_time, omega, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Yaw Rate \omega (rad/s)');
title('Yaw Rate Over Time');
grid on;

% Steering Input
figure;
plot(car_time, delta_f, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Steering Angle \delta_f (rad)');
title('Steering Input Over Time');
grid on;

% Torque Request to Wheels
figure;
plot(car_time, T_wheel, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Wheel Torque (Nm)');
title('Wheel Torque Over Time');
grid on;

%% Lap counting
if isempty(car_X) || isempty(car_Y)
    error('Simulation did not return valid car X/Y positions.');
end

%% Compare Car Path to Track Centerline
figure;
plot(path.xpath, path.ypath, 'r--', 'LineWidth', 3); hold on;
plot(car_X, car_Y, 'b', 'LineWidth', 2);
legend('Track Centerline', 'Car Path');
xlabel('X (m)');
ylabel('Y (m)');
title('Track Path vs. Vehicle Trajectory');
axis equal;
grid on;

race = raceStat(car_X, car_Y, car_time, path);
disp(race);

hold off;
