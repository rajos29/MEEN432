clear; clc;

% Parameters
J = 100;        % inertia
b = 10;         % damping
w0 = 10;        % initial speed
th0 = 0;        % initial angle
Tf = 25;        % simulation time
dt = 0.01;     % time step

% Input choice - set to true to use sine input rather than const input
useSine = true;

if useSine
    A = 1; 
    freq = 0.1;            
    tau_fun = @(t) tau_sine(t, A, freq); % @(t) allows in-line func. def.
else
    A = 100;                       % constant torque
    tau_fun = @(t) tau_const(t, A); % @(t) allows in-line func. def.
end

% ODE: dw/dt = (tau - b*w)/J
rhs = @(t,w) (tau_fun(t) - fDamper(b,w)) / J;

% Time vector
t = 0:dt:Tf;
N = length(t);

% Integration Array
w_euler = zeros(1,N);   
th_euler = zeros(1,N);
w_rk4   = zeros(1,N);   
th_rk4   = zeros(1,N);

% Integration IC's
w_euler(1) = w0; 
th_euler(1) = th0;
w_rk4(1)   = w0; 
th_rk4(1)   = th0;

% Euler loop
for k = 1:N-1
    w_euler(k+1) = euler_step(rhs, t(k), w_euler(k), dt);
    th_euler(k+1) = th_euler(k) + dt * w_euler(k);
end

% RK4 loop
for k = 1:N-1
    w_rk4(k+1) = rk4_step(rhs, t(k), w_rk4(k), dt);
    th_rk4(k+1) = th_rk4(k) + dt * w_rk4(k);
end

% Plot results
figure;
plot(t, w_euler, 'r-', t, w_rk4, 'b--');
xlabel('Time [s]'); ylabel('Angular speed \omega [rad/s]');
legend('Euler','RK4'); grid on;
title('Comparison of solvers');