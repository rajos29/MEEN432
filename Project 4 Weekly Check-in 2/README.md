Project 4 – Week 2 README

Overview:
The goal of Week 2 was to attempt to evolve the combined electric-vehicle (EV) model from Week 1 into a fully closed-loop system that can complete multiple laps of the track automatically. Lateral and longitudinal dynamics were linked through a steering controller and a torque-control loop so the vehicle could follow the reference path without leaving the 15 m-wide track.

What Was Added:

A Pure Pursuit Controller inside the Driver subsystem computes steering angle (δ_f) from the vehicle’s current position (x,y,ψ) and the track centerline (path.xpath, path.ypath).

A PI-style longitudinal controller adjusts the requested motor torque (T_request) to maintain a target speed that decreases with curvature (κ_d).

A 3-speed gearbox model remains parameterized in car, with instantaneous shifts every ≥ 2 s.

All workspace variables (car, path, motor, bat, track) are pushed to Simulink using assignin to avoid “deleted variable” errors.

The simulation now runs discretely (0.01 s step) for 300 s, and the vehicle successfully completes more than five laps within the friction and SOC limits.

How to Run:

Open MATLAB and set the working directory to the project folder.

Run run_ev_sim.m to initialize parameters and execute the Simulink model p4_simulinkk.slx.

After simulation, the script automatically plots:

Longitudinal speed (vx)

Wheel torque and requested torque

Steering angle (δ_f)

Battery SOC vs time

Animated vehicle path vs track centerline

Key Parameters:
Look-ahead distance (L) = 10 m
Understeer coefficient = 0.001 rad·s²/m²
Max steering angle = 0.5 rad
Friction coefficient μ = 0.5
SOC limits = 10% – 95%

Results:
The closed-loop EV attempts to maintains stable tracking, stay within track boundaries, and regulate torque to preserve SOC above 10%. Performance attempts to meet the Week 2 requirement of completing at least five laps while respecting energy and traction constraints.
