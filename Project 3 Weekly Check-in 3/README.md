Project 3 – Electric Vehicle Longitudinal Model
MEEN 432 – Automotive Engineering

Overview
This project models the longitudinal dynamics of an electric vehicle following two EPA drive cycles: Urban (UDDS) and Highway (HWFET). The model includes aerodynamic drag, rolling resistance, tire forces, driver control, an electric motor with transmission, and a lithium-ion battery with regenerative braking. The objective is to track each EPA cycle within ±3 mph while predicting total energy use and battery state of charge (SOC).

Week 3 Additions
For Week 3, the system was extended with a battery subsystem and regenerative braking.

Implemented a lithium-ion pack model using the OCV–SOC curve, internal resistance, and amp-hour capacity.

Integrated battery current and voltage calculation into the powertrain to update SOC over time.

Added bidirectional power flow so negative torque (braking) returns energy to the battery.

Produced SOC vs time and battery-voltage vs time plots for both EPA cycles.

How to Run

Place all .m files and cycle .txt files in the same folder.

Open MATLAB and set that folder as the working directory.

Run: run_sim

The program will simulate both Urban and Highway cycles and generate plots for:

Speed tracking (actual vs target)

Energy consumption (kWh vs time)

Battery SOC vs time

Battery voltage vs time
It will also print final SOC and net energy in the MATLAB Command Window.

Results Summary
The vehicle maintained tracking within ±3 mph for both cycles. The Urban cycle consumed less net energy due to frequent regenerative braking opportunities. The Highway cycle required higher continuous power and showed greater total energy usage. SOC decreased gradually with small rises during braking events, confirming regeneration behavior. Battery voltage followed SOC trends and stayed within expected limits.

Files Included
p3_init.m – defines vehicle, motor, and battery parameters
load_epa_cycles.m – loads and interpolates EPA drive cycles
ev_powertrain.m – computes motor torque and power flow with regen
battery_model.m – updates battery voltage and SOC
run_sim.m – main driver script executing both cycles
urban_cycle.txt, highway_cycle.txt – EPA drive cycle data
