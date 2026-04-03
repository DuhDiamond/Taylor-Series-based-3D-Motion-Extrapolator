## About

A proof-of-concept for a Taylor Series-based 3D Motion Extrapolator. I originally came up with the idea for this a few weeks ago. I implemented in Matlab around mid-March, and I decided to upload it af er some polishing and bug-fixing. It uses a Taylor-series approach on displacement matrices.

## Goals

The goal of this project was to develop a system that, given sampled displacement or translation and rotation matrices as input at a given point in time alongside estimated derivatives (such as from a rolling average), you can estimate the future position of an object from a given time point over some time interval.

10 timesteps over a 10-second interval (estimating over 1 second), 5 terms in the taylor series
<video width="630" height="300" src="https://github.com/DuhDiamond/Taylor-Series-based-3D-Motion-Extrapolator/blob/main/time10_timesteps_10.mp4"></video>

20 timesteps over a 10-second interval (estimating over 2 seconds), 5 terms in the taylor series
<video src="https://github.com/DuhDiamond/Taylor-Series-based-3D-Motion-Extrapolator/blob/main/time10_timesteps_20.mp4 controls></video>

### Applications

This system could be used for:
1. Virtual Reality:
   - Headset motion extrapolation
      - Poor connection environments on a client, for the server to estimate a player's position (to be later validated).
      - Headset pose prediction for minimizing percieved lag and motion sickness for the user, as display rendering has inherent latency.
2. Multiplayer Games:
   - Constrained Network:
      - Client-sided estimation of other players' movement between packets recieved to minimize bandwidth passing through the server.
3. Robotics:
   - Future object prediction, given 3D camera vision input
      - A robot arm that moves in time to catch a ball flying towards it.
   - Could be used by autonomous vehicles as an additional check to predict trajectories of surrounding vehicles and pedestriations for collision avoidance planning.
4. Simulation:
   - Can be used to approximate various physics phenomena which requires integration of motion provided data input (such as through differential equations)
   - Could also be used to additionally blend noisy data from various sensors, such as wind or other motion information.

...Or anywhere else where motion data cannot be continously and reliably updated, or bandwidth/network bottlenecks are a bigger issue than compute cost and exact precision.

### Rundown

Some advantages of this system:
1. Efficient:
   - Most of the operations required can be represented as matrix computations on simple bounding boxes.
   - Minimal space is required for storing this information.
   - For sufficiently accurate data, the system converges very quickly.
2. Dynamically scales:
   - The number of terms used can be reliably limited at the cost of lower accuracy, thus is adaptable to dynamic workloads with varying compute power.
   - It can be used to predict different time intervals.
   - More terms can be used when the network is a larger bottleneck or time delays grow significantly, leaving more time for computation on the waiting side.
3. Generalizable:
   - As long as a rolling average of displacement data can be provided, it generalizes to any local 3D changes, as long as motion data provided is sufficiently smooth.

Implementation details are available through comments in the Matlab script in the repository. As this is a proof-of-concept, I don't have a dataset to test it on, so currently position and rotation data is directly provided in the Matlab script via parametrized model matrices for showcase.

## How to run:

Here are some steps if you'd like to run it yourself. I use Windows + WSL (Windows Subsystem for Linux, based on Debian Linux) in a Visual Studio Code environment.

1. Git clone the repository: In Linux/WSL, this can be done by running the following command in your terminal, from the folder you'd like to copy it into:
git@github.com:DuhDiamond/Taylor-Series-based-3D-Motion-Extrapolator.git
2. Run the Matlab script from the cloned folder in your file explorer (or command line) of choice.
3. An additional Matlab window should open and display each frame.

If you're having issues running the project, message me directly and I'll help you as best as I can!
