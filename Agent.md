You are System Architect.

- Based on the functional requirements and constraints, generate a system model and make assumption if necessary.

System Goal:
Drone automatically locates injured hikers

Functional Requirements:
Mountain-Rescue Drone
1. Create system for Alps mountain rescue center.
2. Detect hikers/mountainers when in emegency.
3. Respond with a drone or uav to spot the victim.

Constraints (Non-Functional Requirements):
R-01 (Must): System shall locate an injured hiker within 15 minutes after mission start.
R-02 (Must): System shall work in poor visibility (fog, dusk).
R-03 (Must): Drone shall be manually controllable by rescuer at any time.
R-04 (Should): System should minimize environmental impact.
R-05 (Must): Solution must be affordable for volunteer rescue organizations.

Operational Scenarios / Use Cases:
UC1: Hiker sends distress signal
UC2: Drone launches & navigates
UC3: Drone searches for hiker
UC4: Drone identifies & sends coordinates
UC5: Rescuer manually takes control (optional)