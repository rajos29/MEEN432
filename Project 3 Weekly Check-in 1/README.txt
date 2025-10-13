Project Overview:
The objective of Project 3 is to build a longitudinal dynamic vehicle model and progressively integrate an Electric Vehicle (EV) powertrain and battery system capable of following two EPA drive cycles — the Urban Dynamometer Driving Schedule (UDDS) and the Highway Fuel Economy Test (HWFET). The vehicle must track the reference velocity profiles within ±3 mph throughout the cycles while estimating energy consumption and regeneration.

Week 1 Progress Summary:

Constructed the longitudinal vehicle model consisting of chassis mass, aerodynamic drag, and rolling resistance.

Implemented wheel torque control under the assumption of no tire slip.

Created a basic driver controller that regulates wheel torque to match the EPA speed commands.

Imported both Urban (UDDS) and Highway (HWFET) cycle data and synchronized them for simulation.

Verified tracking error < 3 mph for both cycles using closed-loop control.

How to Run:

Open the project folder in MATLAB.

Run the initialization script:
init_vehicle.m
(This sets constants such as mass, Cd, A, rho, Crr, gear ratio, etc.)

Execute the main simulation file:
simulate_project3.m
(This loads the EPA cycle data, runs the Simulink model ‘project3_model.slx’, and outputs time-series data of velocity, acceleration, and torque.)

After completion, open analyze_results.m to visualize:

Velocity tracking vs. EPA reference

Control torque over time

Energy usage trends

Outputs:

Workspace variables: time, v_ref, v_vehicle, torque_cmd, error

Plots: Actual vs Target Speed (UDDS and HWFET), Torque command vs time

Performance metrics: Average tracking error, Peak acceleration and braking torque
