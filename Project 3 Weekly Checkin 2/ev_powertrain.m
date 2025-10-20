function [T_wheel, P_elec, E_total] = ev_powertrain(v_vehicle, T_request, datMotor, datCar, dt)


persistent E_int
if isempty(E_int)
    E_int = 0;
end

% Motor & transmission parameters 
GR = datCar.gearRatio3;   
FD = datCar.FDRatio;
eta_fd = datCar.FDeta;

%  Motor speed
w_motor = (v_vehicle / datCar.radius) * (1/FD) * (1/GR);  
rpm_motor = w_motor * 60 / (2*pi);

% Motor torque limit interpolation 
rpm_vec  = datMotor.rpm;
torque_max = interp1(rpm_vec, datMotor.maxtorque(3,:), rpm_motor, 'linear', 'extrap');

% Requested torque at motor shaft 
T_motor_req = T_request / (GR * FD * eta_fd);

% Limit torque by capability map 
T_motor = min(max(T_motor_req, -torque_max), torque_max);

% Interpolate efficiency 
eta = interp2(datMotor.eta_speed, datMotor.eta_torque, ...
              datMotor.eta_val, rpm_motor, abs(T_motor), 'linear', 0.9);

% Electrical power draw 
P_elec = abs(T_motor .* w_motor ./ eta);
if T_motor < 0
    P_elec = 0;  
end

% Update energy integral 
E_int = E_int + P_elec * dt;  
E_total = E_int / 3.6e6;      

% Wheel torque to vehicle 
T_wheel = T_motor * GR * FD * eta_fd;
end
