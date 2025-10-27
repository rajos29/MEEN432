% WEEK 2 EV Powertrain Simulation
clear; close all; clc;
p3_init;
[urbanCycle, highwayCycle] = load_epa_cycles;
dt = 0.1;

urban = run_cycle('Urban', urbanCycle, datMotor, datCar,datBat, dt);
highway = run_cycle('Highway', highwayCycle, datMotor, datCar, datBat, dt);

disp('Simulation complete.');

function results = run_cycle(cycleName, cycleData, datMotor, datCar, datBat, dt)
disp(['Running ', cycleName, ' Cycle...']);

time = cycleData(:,1);
target_speed = cycleData(:,2) * 0.44704;
v_vehicle = 0;
E_total = 0;
v_hist = zeros(size(time));
E_hist = zeros(size(time));

for i = 1:length(time)
    if i == 1
        v_error = target_speed(i) - v_vehicle;
    else
        v_error = target_speed(i) - v_hist(i-1);
    end
    T_request = 500 * v_error;
    T_request = max(min(T_request, 5000), -5000);

    [T_wheel, P_elec, E_total] = ev_powertrain(v_vehicle, T_request, datMotor, datCar, dt);
    [V_batt, I_batt, SOC] = battery_model(P_elec, datBat, dt);
    SOC_hist(i) = SOC;
    V_hist(i)   = V_batt;

    F_drive = T_wheel / datCar.radius;
    F_drag = datCar.C0 + datCar.C1*v_vehicle + datCar.C2*v_vehicle.^2;
    F_rr = datCar.m * 9.81 * 0.015;
    a = (F_drive - F_drag - F_rr) / datCar.m;

    v_vehicle = v_vehicle + a * dt;
    v_hist(i) = v_vehicle;
    E_hist(i) = E_total;
end

results.time = time;
results.v_hist = v_hist / 0.44704;
results.target = cycleData(:,2);
results.energy_kWh = E_total;

figure; plot(time, SOC_hist);
xlabel('Time (s)'); ylabel('State of Charge');
title([cycleName, ' SOC vs Time']);

figure; plot(time, V_hist);
xlabel('Time (s)'); ylabel('Battery Voltage (V)');
title([cycleName, ' Battery Voltage vs Time']);

fprintf('%s: Final SOC = %.1f%%, Net Energy = %.3f kWh\n',...
        cycleName, SOC_hist(end)*100, results.energy_kWh);

figure; plot(time, results.v_hist, 'b', time, results.target, 'r--');
xlabel('Time (s)'); ylabel('Speed (mph)');
title([cycleName, ' Cycle Tracking']); legend('Actual','Target');

figure; plot(time, E_hist, 'k');
xlabel('Time (s)'); ylabel('Energy (kWh)');
title([cycleName, ' Cycle Energy Consumption']);

fprintf('%s Cycle Total Energy = %.3f kWh\n', cycleName, results.energy_kWh);
end
