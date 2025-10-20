Project Overview:
The objective of Project 3 is to build a longitudinal dynamic vehicle model and integrate an Electric Vehicle (EV) powertrain with motor and single-speed transmission to simulate two EPA drive cycles — the Urban Dynamometer Driving Schedule (UDDS) and the Highway Fuel Economy Test (HWFET). The vehicle must follow the target velocity profiles within ±3 mph while estimating total energy consumption across both cycles.

Week 2 Progress Summary:

Integrated the EV powertrain model into the longitudinal dynamics framework.

Modeled the electric motor and single-speed transmission system, linking torque output to wheel dynamics.

Developed power equations to compute instantaneous motor power and total energy consumption over time.

Assumed an infinite power source and neglected regenerative braking for this phase.

Verified stable tracking of both UDDS and HWFET cycles, maintaining less than 3 mph error.

Calculated total energy usage for each cycle and compared consumption trends between city and highway driving.

How to Run:

Open the project folder in MATLAB.

Run the initialization script:
init_vehicle.m


Execute the main simulation file:
simulate_project3.m

After completion, open analyze_results.m to visualize:

Vehicle velocity tracking vs. EPA reference

Motor torque and power demand over time

Total energy consumption per cycle

Outputs:

Workspace variables: time, v_ref, v_vehicle, torque_cmd, motor_power, energy_used

Plots: Speed tracking (UDDS and HWFET), Motor torque and power curves, Cumulative energy usage

Performance metrics: Average tracking error, Peak motor power, Total energy consumed (kWh)
