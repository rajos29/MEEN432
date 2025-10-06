**Project 2 – Week 2 Check-In (README)**

**Team Progress Summary:**

* Completed full setup of the main simulation workflow.
* `simulate_project2.m` now acts as the master script controlling the entire process.
* Integrated all subfunctions (`init.m`, `gen_track.m`, and the Simulink model `simulink_w1`) into one automated workflow.
* Simulation computes lateral dynamics including steering angle and heading.
* Outputs include vehicle global X–Y coordinates and yaw angle.
* Added visualization of vehicle trajectory on the generated track from `gen_track.m`.
* Implemented `raceStat.m` to evaluate vehicle performance (lap completion time, multi-lap timing, and on-track validation).
* System now runs as a cohesive automated simulation for easier testing and visualization.

**How to Run the Simulation:**

1. Open MATLAB and load all project files in the same directory.
2. Open the Simulink model `simulink_w1`.
3. Set the simulation **Stop Time** to `450` seconds.
4. In MATLAB, sequentially run the following scripts:

   * `init.m`
   * `gen_track.m`
   * `animate.m`
   * `simulate_project2.m`
5. After execution, observe:

   * Vehicle animation around the generated track.
   * Output performance results printed in the Command Window.

**Result:**
All project components now operate under one unified process, significantly improving workflow efficiency and enabling real-time analysis of vehicle motion and performance.
