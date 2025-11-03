%% Vehicle Parameters
car.I = 2000;           % kg·m^2 - Vehicle Inertia
car.m = 1600;           % kg - Vehicle Mass

%% Initial Conditions
car.init.X0 = 0;        % m - Initial X Position
car.init.Y0 = 0;        % m - Initial Y Position
car.init.vx0 = 5;   % m/s - Initial Longitudinal Velocity
car.init.vy0 = 0;       % m/s - Initial Lateral Velocity
car.init.omega0 = 0;    % rad/s - Initial Yaw Rate
car.init.psi0 = 0;      % rad - Initial Heading
car.init.omega0 = car.init.vx0 / 0.3; % Initial wheel speed

%% Tire Parameters
car.Calpha_f = 40000;   % N/rad - Front Tire Stiffness
car.Calpha_r = 40000;   % N/rad - Rear Tire Stiffness
car.Fyfmax = 40000 * 2 / 180 * pi; % N - Max Front Tire Force
car.Fyrmax = 40000 * 2 / 180 * pi; % N - Max Rear Tire Force
car.lr = 1.5;           % m - Distance from CG to Rear Axle
car.lf = 1.0;           % m - Distance from CG to Front Axle
car.radius = 0.3;       % m - Tire Radius
car.maxAlpha = 2 / 180 * pi; % rad - Max Slip Angle
car.Iw = 0.5 * 7 * car.radius^2; % kg·m^2 - Wheel Inertia
car.understeerCoeff = 0.001;  % rad·s²/m²
car.delta_max = 0.5;  % rad

%% Longitudinal Tire Model
car.C_lambda = 50;      % N/kg - Longitudinal Stiffness
car.lambda_max = 0.1;   % Max Slip Ratio
car.tire_mu = 1.0;      % Frication Coefficient

%% Drag and Resistance
car.C0 = 0.0041;        % N - Static Friction
car.C1 = 0.000066;      % N/(m/s) - Rolling Resistance
Rho = 1.225;            % kg/m^3 - Air Density
A = 2.6;                % m^2 - Projected Area
Cd = 0.36;              % Drag Coefficient
car.C2 = 0.5 * Rho * A * Cd; % N/(m/s)^2 - Aerodynamic Drag

%% Transmission
car.gearRatio1 = 10.0;
car.gearRatio2 = 3.0;
car.gearRatio3 = 1.0;
car.FDRatio = 7.5;
car.FDeta = 0.95;

%% Brake
car.maxBrakeTorque = 50000; % Nm

%% Track Parameters
track.radius = 200;     % m - Curve Radius
track.width = 15;       % m - Track Width
track.l_st = 900;       % m - Straightaway Length

%% Motor Parameters (HVH250-090)
scaleFactor = 0.75;
motor.rpm = [0, 1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,11000,12000];
motor.maxtorque = scaleFactor * [
    280, 280, 275, 260, 250, 230, 200, 175, 140, 120, 100, 75, 0
];
motor.vbus = scaleFactor * [250, 350, 500, 600, 700];
motor.eta_torque = (0:25:325) * 280/325 * scaleFactor;
motor.eta_speed = [10, 500:500:10000]; % Avoid zero speed
motor.eta_val = ... % Efficiency map (truncated for brevity)
    0.74 * ones(length(motor.eta_torque), length(motor.eta_speed)); % Placeholder

motor.inertia = 0.5; % kg·m^2

%% Battery Parameters
bat.SOC = [0, 0.01, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
bat.OCV = [0, 3.1, 3.55, 3.68, 3.74, 3.76, 3.78, 3.85, 3.9, 3.95, 4.08, 4.15];
bat.Rint = 0.1695;      % Ohms - Internal Resistance per Cell
bat.C = 150;            % Ah - Total Battery Capacity
bat.numSeries = 96;
bat.numParallel = 74;

%% Conversion
mph2mps = 1600 / 3600;


