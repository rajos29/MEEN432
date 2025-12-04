This week, I worked on my individual submission requirement of adding elevation and grade to the track profile and incorporating its effects into the simulation. Elevation was generated inside gentrack.m using a smooth logistic rise and fall along the two long straights of the track. After computing the height at every centerline point, I numerically differentiated this elevation profile to obtain slope (dz/ds). This slope was then converted to grade (%), where positive values correspond to uphill sections and negative values correspond to downhill sections.
During the simulation, the vehicle's real-time position (X,Y) is passed into the trackGrade function, which determines the local grade percentage and feeds it into the Longitudinal Dynamics Body Frame subsystem. This allows the motor, drivetrain, wheels, and longitudinal forces to experience realistic gravitational loading. Uphill portions require more torque and consume more battery power, while downhill sections reduce torque demand and can support higher coasting speeds.
In addition to the elevation changes, I implemented the required analysis outputs in p4_runsim.m, including:
Elevation and slope (grade) plots
Lateral deviation from track centerline
Yaw-rate tracking and yaw-rate error
Battery voltage, current, SOC, and power usage
Total battery energy consumed
Motor power output
Track loops completed and off-track events
All results are automatically generated at the end of each simulation run.
 oepn gentrack.m, racestat.m, rotate.m, p4_init.m, computedevoation.m amd p4_runsim
run 
p4_runsim
This script will:
Call p4_init()
Generate the track and elevation
Load all vehicle parameters
Run the Simulink model
Produce all analysis figures automatically
4. View Simulation Results
Once the simulation finishes, MATLAB will automatically create:
Elevation and slope plots
Speed tracking plots
Yaw rate tracking/error
Battery power and SOC curves
Lateral deviation histograms and statistics
Track trajectory plots
Race statistics (loops completed, off-track events)
All plots are displayed in separate figures for easy analysis.