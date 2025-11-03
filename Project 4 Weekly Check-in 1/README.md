Week 1 Progress Summary:
• Developed an EV model including lateral and longitudinal dynamics.
• Built track generator using gentrack.m to simulate a race circuit with two straightaways and two curves.
• Modeled tire forces using linear approximations with stiffness and slip ratio as constraints.
• Created a basic Pure Pursuit controller for path following with steering commands.
• Added a longitudinal torque controller to track based speeds.
• Integrated EV powertrain including motor torque scaling and gear ratio logic.
• Fixed key issues in the powertrain model (gear ratio was previously hardcoded to 0.01, limiting motion).
• Snsured proper logging and output of vehicle velocity (vx) and position (X, Y) for simulation analysis.
• Simulated the EV through the track loop and debugged movement issues related to torque scaling and signal logging.

How to Run:
1 Open the project folder in MATLAB.
2 Run the initialization script: run_ev_sim.m
This sets all vehicle parameters (p4_init.m), generates the track (gentrack.m), and runs the Simulink model p4_simulinkk.slx.
3 After simulation:
Use raceStat.m to check laps completed and off-track behavior.
Use plot(simout.vx_out.Data) and plot(simout.X.Data, simout.Y.Data) to visualize vehicle performance.

Outputs:
• Workspace variables: vx_out, X, Y, T_request, SOC, raceStats
• Plots:
◦ Vehicle trajectory vs. track layout
◦ SOC over time
◦ Velocity and torque plots
• Performance Metrics:
◦ Number of laps completed
◦ Time to complete each lap
◦ SOC consumption rate
◦ Path tracking accuracy (compared to centerline)
