clear; close all; clc;

%% Track Parameters
R = 200;    
L = 900;   
N = 400;     

% centers of the turning sections
leftCenter  = [-L/2, 0];   
rightCenter = [ L/2, 0];   

% Top straightaway
x_top = linspace(-L/2, +L/2, N);
y_top = R * ones(1, N)+200;

% Right side turning section
theta_R = linspace(pi/2, -pi/2, N);
x_Rarc = rightCenter(1) + R * cos(theta_R); 
y_Rarc = rightCenter(2) + R * sin(theta_R)+200;

% Bottom straightaway
x_bot = linspace(+L/2, -L/2, N);
y_bot = -R * ones(1, N)+200;

% Left side turning section
theta_L = linspace(-pi/2, pi/2, N);
x_Larc = leftCenter(1) - R * cos(theta_L);  
y_Larc = leftCenter(2) + R * sin(theta_L)+200;

% Make continuous line
x = [x_top(1:end-1), x_Rarc(1:end-1), x_bot(1:end-1), x_Larc];
y = [y_top(1:end-1), y_Rarc(1:end-1), y_bot(1:end-1), y_Larc];

%% Vehicle Parameters
veh_length = 40;   % length of vehicle (m)
veh_width  = 20;   % width of vehicle (m)

veh_shape = [ -veh_length/2,  veh_length/2,  veh_length/2, -veh_length/2;
              -veh_width/2,  -veh_width/2,   veh_width/2,  veh_width/2];

%% Velocity Settings
v = 120;      % vehicle speed (m/s)
dt = 0.1;    % simulation time step (s)

% Compute distances between waypoints
dx = diff(x);
dy = diff(y);
ds = hypot(dx, dy);         % segment lengths
s = [0, cumsum(ds)];        % cumulative arc length

% Total track length
track_length = s(end);

%% Simulation Loop
figure('Color','w'); hold on; axis equal;
plot(x, y, 'r-', 'LineWidth', 2); % track centerline
xlabel('X (m)'); ylabel('Y (m)');
title('Race Track with Vehicle');
xlim([-700, 700]); ylim([-50, 450]);
grid on;

veh_path_x = [];
veh_path_y = [];

t = 0; s_pos = 0;
while s_pos < track_length
    % Current arc length position
    s_pos = v * t;
    
    % Wrap around if needed (continuous laps)
    if s_pos > track_length
        break;
    end
    
    % Interpolate position on track
    xc = interp1(s, x, s_pos);
    yc = interp1(s, y, s_pos);
    
    % Heading angle based on derivative
    dx_interp = interp1(s, [dx dx(end)], s_pos);
    dy_interp = interp1(s, [dy dy(end)], s_pos);
    theta = atan2(dy_interp, dx_interp);
    
    % Rotate/translate vehicle
    Rmat = [cos(theta), -sin(theta);
            sin(theta),  cos(theta)];
    veh_rot = Rmat * veh_shape;
    veh_x = veh_rot(1,:) + xc;
    veh_y = veh_rot(2,:) + yc;

    % Plot vehicle
    hCar = fill(veh_x, veh_y, 'b');  
    plot(veh_path_x, veh_path_y, 'k--'); 

    drawnow;
    pause(dt);

    % Save path
    veh_path_x(end+1) = xc;
    veh_path_y(end+1) = yc;

    % Cleanup old car
    delete(hCar);

    % Update time
    t = t + dt;
end

% Final path
plot(veh_path_x, veh_path_y, 'k-', 'LineWidth', 1.5);
