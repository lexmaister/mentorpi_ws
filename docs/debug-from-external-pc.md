# Debug MentorPi From Another PC

This guide explains how to use a second Linux PC for ROS visualization/debugging while the robot runs core processes.

## 1. Goal

Run compute-heavy or GUI-heavy debug tools (for example RViz) on an external PC while data is produced on the robot.

## 2. Preconditions

- Robot and external PC are on the same network.
- Same ROS 2 domain configuration on both sides:
  - `ROS_DOMAIN_ID` must match
  - `ROS_LOCALHOST_ONLY=0`
- External PC has ROS 2 installed (same distro preferred).

## 3. On MentorPi robot

Inside robot ROS environment/container:

1. stop any conflicting launch stacks
2. start the stack you want to inspect (for example SLAM)

Example:

```bash
ros2 launch slam slam.launch.py
```

Verify topics exist:

```bash
ros2 topic list
```

## 4. On external PC

Set ROS network env:

```bash
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=0
export ROS_LOCALHOST_ONLY=0
```

Check topic visibility:

```bash
ros2 topic list
```

If topics are visible, run your debugging tools there.

Example SLAM visualization:

```bash
ros2 launch slam rviz_slam.launch.py
```

If launch package is unavailable locally, use local RViz and subscribe to robot topics manually.

## 5. Optional: mirror workspace for package-specific launch files

If you need package launch files/configs on the debug PC, copy the workspace source from robot and build a subset.

Generic approach:

1. copy `src/` (or selected packages) from robot to external PC
2. build selected packages
3. source local install and run launch files against remote topics

Keep this lightweight: most remote debugging only requires matching interfaces and RViz configs.

## 6. Useful checks

On both machines:

```bash
echo $ROS_DOMAIN_ID
echo $ROS_LOCALHOST_ONLY
```

On external PC:

```bash
ros2 topic hz /scan_raw
ros2 node list
```

## 7. Common failure modes

- `ROS_DOMAIN_ID` mismatch
- firewall/multicast restrictions on network
- different ROS distributions with incompatible message definitions
- robot stack not actually publishing expected topics

## 8. Recommended workflow

1. Run robot-side stack on MentorPi.
2. Validate robot-side topics locally on robot.
3. Validate topic visibility on external PC.
4. Run RViz/tools on external PC.
5. Iterate by changing launch params on robot while observing results remotely.