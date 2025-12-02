Operational Scenario (Drone Rescue TEC Challenge)

Purpose: Deliver a confirmed human coordinate within 15 minutes in alpine terrain with poor visibility, keeping manual override and safe states available at any time.

Pre-conditions:
- Rescue team on standby; GCS online with maps and RTK corrections.
- Drones are armed, health-checked, and within endurance margins for the search cell.
- Weather permits canopy-clear VTOL altitude; ADS-B/TCAS monitored; geofences loaded.

Primary flow:
1) Distress intake: GCS receives UWB distress (preferred) or GNSS/LoRa/manual report. Operator draws/adjusts a search polygon around the coarse coordinate.
2) Relay establishment: VTOL launches first to canopy-clear altitude, establishes the mesh backhaul to GCS, and performs a wideband SDR sweep to obtain an initial AoA bearing to the distress signal.
3) Anchor deployment: Three multirotor anchors auto-fly to preplanned RTK anchor points around/within the polygon, geofence, hold hover, and time-synchronize (PTP/RTK) for valid TDoA.
4) Localization: System runs priority order:
   - If UWB pulses present, anchors compute TDoA for sub-meter fix.
   - Else, fuse VTOL AoA with anchor RSSI/AoA to reach ≤±10 m.
   Incremental coordinate updates stream to the GCS UI.
5) Confirmation: Nearest anchor descends slightly to improve thermal line-of-sight; runs edge thermal/RGB CNN to produce bounding box, confidence, and refined coordinates; snapshots and metadata return to GCS.
6) Operator decision: Operator reviews overlays and confirmation snapshots; dispatches coordinates to the rescue team. Optional actions: keep relay/overwatch hover, perform controlled payload drop, or command RTL.

Safety/alternate flows:
- Manual override possible for VTOL or any anchor at any time; loss-of-link triggers hover/RTL.
- If RTK degrades, anchors tighten geofence, reduce descent, and continue coarse localization with AoA/RSSI.
- If weather worsens or endurance drops below reserve, operator aborts and commands RTL while preserving last known coordinates.
