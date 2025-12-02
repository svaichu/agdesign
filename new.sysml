package AlpsRescueDroneSystem {

    /////////////////////////////////
    // 1. REQUIREMENTS
    /////////////////////////////////

    package requirements {

        // Base requirement definitions
        requirement def FunctionalRequirement {
            attribute id      : String;
            attribute text    : String;
            attribute source  : String;
            attribute status  : String;
        }

        requirement def ConstraintRequirement {
            attribute id      : String;
            attribute text    : String;
            attribute source  : String;
            attribute type    : String;   // MUST / SHOULD / MAY
            attribute status  : String;
        }

        // Functional Requirements
        requirement F_01 : FunctionalRequirement {
            id     = "F-01";
            text   = "Create system for Alps mountain rescue center to support locating injured hikers.";
            source = "Mountain Rescue Tyrol";
            status = "proposed";
        }

        requirement F_02 : FunctionalRequirement {
            id     = "F-02";
            text   = "Detect hikers / mountaineers when in emergency.";
            source = "Mountain Rescue Tyrol";
            status = "proposed";
        }

        requirement F_03 : FunctionalRequirement {
            id     = "F-03";
            text   = "Respond with a drone or UAV to spot the victim.";
            source = "Mountain Rescue Tyrol";
            status = "proposed";
        }

        // Non-Functional / Constraints
        requirement R_01 : ConstraintRequirement {
            id     = "R-01";
            text   = "System shall locate an injured hiker within 15 minutes after mission start.";
            source = "Mountain Rescue Tyrol";
            type   = "MUST";
            status = "proposed";
        }

        requirement R_02 : ConstraintRequirement {
            id     = "R-02";
            text   = "System shall work in poor visibility (fog, dusk).";
            source = "Mountain Rescue Tyrol";
            type   = "MUST";
            status = "proposed";
        }

        requirement R_03 : ConstraintRequirement {
            id     = "R-03";
            text   = "Drone shall be manually controllable by rescuer at any time.";
            source = "Mountain Rescue Tyrol";
            type   = "MUST";
            status = "proposed";
        }

        requirement R_04 : ConstraintRequirement {
            id     = "R-04";
            text   = "System should minimize environmental impact (noise, emissions, wildlife disturbance).";
            source = "Mountain Rescue Tyrol";
            type   = "SHOULD";
            status = "proposed";
        }

        requirement R_05 : ConstraintRequirement {
            id     = "R-05";
            text   = "Solution must be affordable for volunteer rescue organizations.";
            source = "Mountain Rescue Tyrol";
            type   = "MUST";
            status = "proposed";
        }
    }


    /////////////////////////////////
    // 2. USE CASES
    /////////////////////////////////

    package use_cases {

        // Actors
        actor def Hiker;
        actor def MountainRescuer;
        actor def RescueCenterOperator extends MountainRescuer;

        // Use Case Definitions
        usecase def UC1_HikerSendsDistressSignal {
            name = "UC1: Hiker sends distress signal";
            primaryActor = Hiker;
            stakeholders = { RescueCenterOperator };
            // Precondition: Hiker has device with connectivity (smartphone or beacon).
            // Postcondition: Distress signal recorded and forwarded to control system.
        }

        usecase def UC2_DroneLaunchesAndNavigates {
            name = "UC2: Drone launches & navigates";
            primaryActor = RescueCenterOperator;
            // Includes automated flight planning based on last known / estimated position.
        }

        usecase def UC3_DroneSearchesForHiker {
            name = "UC3: Drone searches for hiker";
            primaryActor = RescueCenterOperator;
            // Uses onboard sensors (EO/IR, GNSS, inertial, altimeters) and search patterns.
        }

        usecase def UC4_DroneIdentifiesAndSendsCoordinates {
            name = "UC4: Drone identifies & sends coordinates";
            primaryActor = RescueCenterOperator;
            // Drone confirms likely victim and transmits position + imagery.
        }

        usecase def UC5_RescuerManuallyTakesControl {
            name = "UC5: Rescuer manually takes control (optional)";
            primaryActor = MountainRescuer;
            // Rescuer overrides autonomy to adjust position or follow instructions from victim.
        }

        // Relationships (informal textual form)
        // UC1 «triggers» UC2
        // UC2 «includes» UC3
        // UC3 «includes» UC4
        // UC2, UC3, UC4 «extend» UC5 (manual override possible at any time)

        // Trace to requirements (refine relations)
        refine requirements::F_01 by UC1_HikerSendsDistressSignal;
        refine requirements::F_02 by UC3_DroneSearchesForHiker;
        refine requirements::F_03 by UC2_DroneLaunchesAndNavigates;
    }


    /////////////////////////////////
    // 3. LOGICAL ARCHITECTURE
    /////////////////////////////////

    package logical_architecture {

        // Top-level System
        block def AlpsRescueSystem {
            part drone          : DroneSubsystem;
            part controlDevice  : ControlDeviceSubsystem;
            part rescueCenter   : RescueCenterSubsystem;
            part hikerInterface : HikerInterfaceSubsystem;
        }

        // === Subsystems (high-level) ===

        block def DroneSubsystem {
            // Focus of detailed structure

            // Parts (sub-subsystems / components)
            part flightPlatform       : FlightPlatform;
            part propulsionSystem     : PropulsionSystem;
            part powerSystem          : PowerSystem;
            part sensorSuite          : SensorSuite;
            part commsLink            : CommunicationLink;
            part navAndAutonomySW     : NavigationAutonomySoftware;
            part manualControlModule  : ManualControlModule;
            part onboardProcessing    : OnboardProcessingUnit;

            // External interfaces
            port uplinkCmdPort        : CommandPort;          // from control device
            port downlinkDataPort     : TelemetryVideoPort;   // to control device
            port powerIn              : ChargePort;           // ground charging
        }

        block def RescueCenterSubsystem {
            part missionControlSW : MissionControlSoftware;
            part operatorWS       : OperatorWorkstation;
        }

        block def ControlDeviceSubsystem {
            // Tablet / rugged handheld carried by rescuer
            part handheldDevice    : RescueTablet;
            part uiApp             : DroneControlApp;
            part mapService        : MapAndTerrainService;
        }

        block def HikerInterfaceSubsystem {
            // Assumption: Hiker uses smartphone app OR SOS beacon
            part hikerApp          : HikerMobileApp;
            part sosBeacon         : EmergencyBeacon;
        }

        // === Interfaces / Ports ===

        interface def CommandPort {
            // Command & control messages from ground to drone.
        }

        interface def TelemetryVideoPort {
            // Telemetry, video stream, images from drone to ground.
        }

        interface def ChargePort {
            // Electrical charging on ground.
        }

        // === Drone sub-structure details ===

        block def FlightPlatform {
            part airframe       : Airframe;
            part landingGear    : LandingGear;
        }

        block def PropulsionSystem {
            part rotors         : RotorArray;       // assumption: multi-rotor for hovering
            part motors         : ElectricMotorSet;
            part motorDrivers   : MotorControllers;
        }

        block def PowerSystem {
            part mainBattery    : LiIonBatteryPack;
            part powerMgmtUnit  : PowerManagementModule;
        }

        block def SensorSuite {
            part eoCamera       : EO_DayCamera;
            part irCamera       : ThermalIRCamera;
            part gnssReceiver   : GNSSModule;
            part imu            : IMUSensor;
            part altimeter      : BarometricAltimeter;
            // optional: terrain radar / lidar for poor visibility
            part terrainSensor  : TerrainAwarenessSensor;
        }

        block def CommunicationLink {
            part rcLink         : ManualRCRadio;
            part dataLink       : BroadbandDataLink;  // e.g. LTE/5G or long-range RF
        }

        block def NavigationAutonomySoftware {
            // Logical SW components
            part flightController   : FlightControlSW;
            part pathPlanner        : SearchPathPlanningSW;
            part obstacleAvoidance  : ObstacleAvoidanceSW;
            part targetDetection    : VictimDetectionSW;
            part healthMonitoring   : DroneHealthMonitorSW;
        }

        block def ManualControlModule {
            // Ensures R-03: manual override
            part modeManager        : ControlModeManager;   // AUTO / ASSISTED / MANUAL
            part safetyInterlocks   : SafetyInterlockLogic;
        }

        block def OnboardProcessingUnit {
            part computeHW          : FlightComputer;
            part storage            : MissionDataStorage;
            port swBus              : InternalSWBus;
        }

        // === Non-drone components (just functional placeholders, less detail) ===

        block def RescueTablet {
            // rugged tablet or smartphone
        }

        block def DroneControlApp {
            // Provides UI for mission setup, manual control, video, map, etc.
            // Functions:
            //  - Configure mission area
            //  - Launch / land drone
            //  - Display map and live video
            //  - Take manual control (joystick / virtual sticks)
        }

        block def MissionControlSoftware {
            // Functions:
            //  - Receive distress call / signal
            //  - Estimate search area
            //  - Assign drone and start mission
            //  - Track drone status
        }

        block def HikerMobileApp {
            // Functions:
            //  - Send SOS with location if available
            //  - Allow simple text / voice messages
            //  - Provide basic instructions to injured hiker
        }

        block def EmergencyBeacon {
            // Simple GPS + RF beacon alternative to smartphone.
        }

        // Supporting type stubs (resolve referenced part types)
        block def OperatorWorkstation {}
        block def MapAndTerrainService {}
        block def Airframe {}
        block def LandingGear {}
        block def RotorArray {}
        block def ElectricMotorSet {}
        block def MotorControllers {}
        block def LiIonBatteryPack {}
        block def PowerManagementModule {}
        block def EO_DayCamera {}
        block def ThermalIRCamera {}
        block def GNSSModule {}
        block def IMUSensor {}
        block def BarometricAltimeter {}
        block def TerrainAwarenessSensor {}
        block def ManualRCRadio {}
        block def BroadbandDataLink {}
        block def FlightControlSW {}
        block def SearchPathPlanningSW {}
        block def ObstacleAvoidanceSW {}
        block def VictimDetectionSW {}
        block def DroneHealthMonitorSW {}
        block def ControlModeManager {}
        block def SafetyInterlockLogic {}
        block def FlightComputer {}
        block def MissionDataStorage {}
        block def InternalSWBus {}

        // === Satisfy relations (requirements -> logical elements) ===

        // F-01: overall system for rescue center
        satisfy requirements::F_01 by AlpsRescueSystem;

        // F-02: detect hikers in emergency
        satisfy requirements::F_02 by DroneSubsystem;
        satisfy requirements::F_02 by NavigationAutonomySoftware::targetDetection;

        // F-03: respond with drone to spot victim
        satisfy requirements::F_03 by DroneSubsystem;
        satisfy requirements::F_03 by MissionControlSoftware;
        satisfy requirements::F_03 by DroneControlApp;

        // R-02: poor visibility → IR + terrain sensor + autonomy
        satisfy requirements::R_02 by SensorSuite::irCamera;
        satisfy requirements::R_02 by SensorSuite::terrainSensor;
        satisfy requirements::R_02 by NavigationAutonomySoftware::obstacleAvoidance;

        // R-03: manual control at any time
        satisfy requirements::R_03 by ManualControlModule;
        satisfy requirements::R_03 by CommunicationLink::rcLink;
        satisfy requirements::R_03 by DroneControlApp;

        // R-04: minimize environmental impact
        satisfy requirements::R_04 by PropulsionSystem::motors;        // electric
        satisfy requirements::R_04 by SearchPathPlanningSW;            // efficient paths
        satisfy requirements::R_04 by MissionControlSoftware;          // optimized mission planning

        // R-05: affordability
        // Modeled as requirement satisfied by choice of COTS hardware & reuse of consumer devices
        satisfy requirements::R_05 by RescueTablet;
        satisfy requirements::R_05 by HikerMobileApp;
        satisfy requirements::R_05 by PropulsionSystem;
    }


    /////////////////////////////////
    // 4. PARAMETRIC MODEL FOR R-01
    /////////////////////////////////

    package parametrics {

        // Constraint block for time-to-locate requirement R-01
        constraint def TimeToLocateConstraint {
            // Parameters
            parameter t_dispatch   : Real;   // time between distress receptions and mission start [min]
            parameter t_flight     : Real;   // flight time until first detection [min]
            parameter t_processing : Real;   // processing / confirmation time [min]
            parameter t_locate     : Real;   // total time until location known [min]

            // Constraint
            constraint totalTime: t_locate = t_dispatch + t_flight + t_processing;
            constraint threshold: t_locate <= 15.0;
        }

        // Parametric binding to logical elements (informal textual mapping)
        // t_dispatch   ← MissionControlSoftware + RescueCenterOperator workflow
        // t_flight     ← DroneSubsystem::PropulsionSystem + NavigationAutonomySoftware::pathPlanner
        // t_processing ← OnboardProcessingUnit + VictimDetectionSW + communication latency
        // t_locate     ← performance measure allocated to AlpsRescueSystem satisfying R-01

        // Requirement verification relationship
        verify requirements::R_01 by TimeToLocateConstraint;
    }

}
