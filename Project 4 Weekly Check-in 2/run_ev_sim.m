%% Initialize simulation
p4_init();  % sets up car, motor, bat, track
gentrack(); 
%% Run Simulink model
% Make sure the model is loaded but not running
load_system('p4_simulinkk');
set_param('p4_simulinkk', 'StopTime', '150');

% Now simulate
simout = sim('p4_simulinkk');



%% Get simulation outputs
car_X = simout.X.Data;
car_Y = simout.Y.Data;
car_psi = simout.psi.Data;
car_time = simout.tout;
E_total_J = simout.E_total.Data;

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
hold on
plot(path.xpath, path.ypath, '--r'); axis equal;
plot(path.xinpath, path.yinpath, 'b');
plot(path.xoutpath, path.youtpath, 'b');
axis([min(path.xoutpath), max(path.xoutpath), min(path.youtpath), max(path.youtpath)]);
xlabel('X Distance (m)');
ylabel('Y Distance (m)');
title('Project 4 Track');
grid on

h = animatedline;
L = 15;
width = 5;

for i = 1:length(car_X)
    x = car_X(i);
    y = car_Y(i);
    psi = car_psi(i);
    addpoints(h, x, y);

    car_shape = [-L/2 -width/2; -L/2 width/2; L/2 width/2; L/2 -width/2];
    rcar = rotate(car_shape', psi)';
    a = polyshape(rcar + [x, y]);
    ap = plot(a);
    ap.FaceColor = 'k';
    drawnow limitrate
    pause(0.05);
    delete(ap)
end

%% Lap counting
race = raceStat(car_X, car_Y, car_time, path);
disp(race);

hold off

