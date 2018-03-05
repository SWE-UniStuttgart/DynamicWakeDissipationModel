% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function [BasisWindField,Parameter,TurbineData,SimulationCase,ResultDir] = DynamicWakeDissipationModelConfig

SimulationCase = 'ThreeTurbine-CL-Windcon';

% result dir
Parameter.DynamicWindfield.SaveResults = true;
ResultDir = ['./DynamicWakeSimulation/', SimulationCase];

switch SimulationCase
    case 'InitialTest-CL-Windcon-homogeneous'
        % video plot
        Parameter.AnimateWindFlow = true;
        % time
        Parameter.Time.TMin = 0;
        Parameter.Time.TMax = 300;
        Parameter.Time.dt   = 5;
        Parameter.Time.t    = Parameter.Time.TMin:Parameter.Time.dt:Parameter.Time.TMax;
        
        % wind
        Parameter.Windfarm.URef = 8;
        Parameter.v_0          = load('dcpdmy');
        
        % turbine
        D = 178;
        Parameter.Turbine.RotorRadius   = D/2;
        Parameter.Turbine.Name          = 'DTU10MW';
        
        % layout
        Parameter.Windfarm.nTurbines = 2;
        Parameter.Windfarm.Layout.x  = 50+ [0 5*D]; % inflow from x 0 -> inf
        Parameter.Windfarm.Layout.y  = 150 + [0 0];
        Parameter.Windfarm.Layout.z  = [119 119];
        Parameter.Windfarm.Grid.x   = 0:10:2000;
        Parameter.Windfarm.Grid.y   = 0:20:300;
        Parameter.Windfarm.Grid.z   = 0:20:300;
        [Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z] = meshgrid(Parameter.Windfarm.Grid.x,Parameter.Windfarm.Grid.y,Parameter.Windfarm.Grid.z);
        
        % wake model
        Parameter.WakeModel.InitialParameter   = [Parameter.Windfarm.URef;0.3;0.13;0]; % URef, delta_V, AxialInduction WakeDiss, Yaw
        Parameter.WakeModel.ForceScale  = 1;
        Parameter.WakeModel.k_d         = 0.15;
        Parameter.WakeModel.nParameter  = 4;
        % wake model grid
        
        Parameter.WakeModel.grid.x0 = 0;
        Parameter.WakeModel.grid.dx = Parameter.Windfarm.URef*Parameter.Time.dt;
        
        Parameter.WakeModel.nStates = ceil(1.2*Parameter.Windfarm.Grid.x(end) /Parameter.WakeModel.grid.dx);
        Parameter.WakeModel.grid.xEnd = (Parameter.WakeModel.nStates-1)*Parameter.WakeModel.grid.dx;
        
        Parameter.WakeModel.grid.x = Parameter.WakeModel.grid.x0:Parameter.WakeModel.grid.dx:Parameter.WakeModel.grid.xEnd;
        Parameter.WakeModel.grid.y0 = -150;
        Parameter.WakeModel.grid.dy = 25;
        Parameter.WakeModel.grid.yEnd = 150;
        Parameter.WakeModel.grid.y = Parameter.WakeModel.grid.y0:Parameter.WakeModel.grid.dy:Parameter.WakeModel.grid.yEnd;
        Parameter.WakeModel.grid.z0 = -150;
        Parameter.WakeModel.grid.dz = 25;
        Parameter.WakeModel.grid.zEnd = 150;
        Parameter.WakeModel.grid.z = Parameter.WakeModel.grid.z0:Parameter.WakeModel.grid.dz:Parameter.WakeModel.grid.zEnd;
        [Parameter.WakeModel.grid.X,Parameter.WakeModel.grid.Y,Parameter.WakeModel.grid.Z] = meshgrid(Parameter.WakeModel.grid.x,Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z);
        
        % windfield
        BasisWindField.IinW =  -[0 0 0];
        %x
        inputgrid.nx = 101;
        inputgrid.dx = 10000 /(inputgrid.nx-1);
        inputgrid.x0 = 0;
        inputgrid.x  = inputgrid.x0:inputgrid.dx:inputgrid.dx*(inputgrid.nx-1);
        %y
        inputgrid.ny = 10;
        inputgrid.dy = 300/(inputgrid.ny-1);
        inputgrid.y0 = 0;
        %z
        inputgrid.nz = 10;
        inputgrid.dz = 180/(inputgrid.nz-1);
        inputgrid.z0 = 0;
        % t
        inputgrid.nt = inputgrid.nx;
        inputgrid.dt = inputgrid.dx/Parameter.Windfarm.URef;
        inputgrid.t0 = inputgrid.x0/Parameter.Windfarm.URef;
        % gridding
        inputgrid.t = inputgrid.t0+(0:inputgrid.dt:(inputgrid.nt-1)*inputgrid.dt);
        inputgrid.y = inputgrid.y0+(0:inputgrid.dy:(inputgrid.ny-1)*inputgrid.dy);
        inputgrid.z = linspace(inputgrid.z0,(inputgrid.nz-1)*inputgrid.dz,inputgrid.nz);%inputgrid.z0+(0:inputgrid.dz:(inputgrid.nz-1)*inputgrid.dz);
        [inputgrid.X,inputgrid.Y,inputgrid.Z] = meshgrid(inputgrid.x,inputgrid.y,inputgrid.z);
        BasisWindField.grid = inputgrid;
        BasisWindField.u = ones(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.v = zeros(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.w = zeros(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.IinW =  -[0 mean(Parameter.Windfarm.Layout.y) mean(Parameter.Windfarm.Layout.z)];
        
        % input
        TurbineData.AxialInduction.time            = Parameter.Time.t;
        TurbineData.AxialInduction.signals.values   = ones(size(Parameter.Time.t))*0.3;
        TurbineData.WakeDissipation.time            = Parameter.Time.t;
        TurbineData.WakeDissipation.signals.values   = ones(size(Parameter.Time.t))*0.15;
        
        PhiDesired          = 20:-10:0;
        StepTimes           = linspace(0,Parameter.Time.TMax,numel(PhiDesired)+1);
        StepTimes           = StepTimes(1:numel(PhiDesired));
        TurbineData.Yaw.time            = Parameter.Time.t;
        TurbineData.Yaw.signals.values   = deg2rad(interp1(StepTimes,PhiDesired,Parameter.Time.t,'previous','extrap'));
    case 'ThreeTurbine-CL-Windcon'
        % video plot
        Parameter.AnimateWindFlow = true;
        % time
        Parameter.Time.TMin = 0;
        Parameter.Time.TMax = 200;
        Parameter.Time.dt   = 1;
        Parameter.Time.t    = Parameter.Time.TMin:Parameter.Time.dt:Parameter.Time.TMax;
        
        % wind
        Parameter.Windfarm.URef = 8;
        Parameter.v_0          = load('dcpdmy');
        
        % turbine
        D = 178;
        Parameter.Turbine.RotorRadius   = D/2;
        Parameter.Turbine.Name          = 'DTU10MW';
        
        % layout
        Parameter.Windfarm.nTurbines = 3;
        Parameter.Windfarm.Layout.x  = [0 5*D 10*D]; % inflow from x 0 -> inf
        Parameter.Windfarm.Layout.y  = 200 + [0 0 -0.5*D];
        Parameter.Windfarm.Layout.z  = [119 119 119];
        Parameter.Windfarm.Grid.x   = 0:10:3000;
        Parameter.Windfarm.Grid.y   = 0:20:300;
        Parameter.Windfarm.Grid.z   = 0:20:300;
        [Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z] = meshgrid(Parameter.Windfarm.Grid.x,Parameter.Windfarm.Grid.y,Parameter.Windfarm.Grid.z);
        
        % wake model
        Parameter.WakeModel.InitialParameter   = [Parameter.Windfarm.URef;0.3;0.13;0]; % URef, delta_V, AxialInduction WakeDiss, Yaw
        Parameter.WakeModel.ForceScale  = 1;
        Parameter.WakeModel.k_d         = 0.15;
        Parameter.WakeModel.nParameter  = 4;
        % wake model grid
        
        Parameter.WakeModel.grid.x0 = 0;
        Parameter.WakeModel.grid.dx = Parameter.Windfarm.URef*Parameter.Time.dt;
        
        Parameter.WakeModel.nStates = ceil(1.2*Parameter.Windfarm.Grid.x(end) /Parameter.WakeModel.grid.dx);
        Parameter.WakeModel.grid.xEnd = (Parameter.WakeModel.nStates-1)*Parameter.WakeModel.grid.dx;
        
        Parameter.WakeModel.grid.x = Parameter.WakeModel.grid.x0:Parameter.WakeModel.grid.dx:Parameter.WakeModel.grid.xEnd;
        Parameter.WakeModel.grid.y0 = -150;
        Parameter.WakeModel.grid.dy = 25;
        Parameter.WakeModel.grid.yEnd = 150;
        Parameter.WakeModel.grid.y = Parameter.WakeModel.grid.y0:Parameter.WakeModel.grid.dy:Parameter.WakeModel.grid.yEnd;
        Parameter.WakeModel.grid.z0 = -150;
        Parameter.WakeModel.grid.dz = 25;
        Parameter.WakeModel.grid.zEnd = 150;
        Parameter.WakeModel.grid.z = Parameter.WakeModel.grid.z0:Parameter.WakeModel.grid.dz:Parameter.WakeModel.grid.zEnd;
        [Parameter.WakeModel.grid.X,Parameter.WakeModel.grid.Y,Parameter.WakeModel.grid.Z] = meshgrid(Parameter.WakeModel.grid.x,Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z);
        
     
        % windfield
        BasisWindField.IinW =  -[0 0 0];
        %x
        inputgrid.nx = 10;
        inputgrid.dx = 10000 /(inputgrid.nx-1);
        inputgrid.x0 = 0;
        inputgrid.x  = inputgrid.x0:inputgrid.dx:inputgrid.dx*(inputgrid.nx-1);
        %y
        inputgrid.ny = 23;
        inputgrid.dy = 300/(inputgrid.ny-1);
        inputgrid.y0 = 0;
        %z
        inputgrid.nz = 23;
        inputgrid.dz = 180/(inputgrid.nz-1);
        inputgrid.z0 = 0;
        % t
        inputgrid.nt = inputgrid.nx;
        inputgrid.dt = inputgrid.dx/Parameter.Windfarm.URef;
        inputgrid.t0 = inputgrid.x0/Parameter.Windfarm.URef;
        % gridding
        inputgrid.t = inputgrid.t0+(0:inputgrid.dt:(inputgrid.nt-1)*inputgrid.dt);
        inputgrid.y = inputgrid.y0+(0:inputgrid.dy:(inputgrid.ny-1)*inputgrid.dy);
        inputgrid.z = linspace(inputgrid.z0,(inputgrid.nz-1)*inputgrid.dz,inputgrid.nz);%inputgrid.z0+(0:inputgrid.dz:(inputgrid.nz-1)*inputgrid.dz);
        [inputgrid.X,inputgrid.Y,inputgrid.Z] = meshgrid(inputgrid.x,inputgrid.y,inputgrid.z);
        BasisWindField.grid = inputgrid;
        BasisWindField.u = ones(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.v = zeros(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.w = zeros(size(inputgrid.X))*Parameter.Windfarm.URef;
        
        % input
        TurbineData.AxialInduction.time            = Parameter.Time.t;
        TurbineData.AxialInduction.signals.values   = ones(size(Parameter.Time.t))*0.3;
        TurbineData.WakeDissipation.time            = Parameter.Time.t;
        TurbineData.WakeDissipation.signals.values   = ones(size(Parameter.Time.t))*0.15;
        
        PhiDesired          = 20:-10:0;
        StepTimes           = linspace(0,Parameter.Time.TMax,numel(PhiDesired)+1);
        StepTimes           = StepTimes(1:numel(PhiDesired));
        TurbineData.Yaw.time            = Parameter.Time.t;
        TurbineData.Yaw.signals.values   = deg2rad(interp1(StepTimes,PhiDesired,Parameter.Time.t,'previous','extrap'));
    case 'NineTurbine-CL-Windcon'
        % video plot
        Parameter.AnimateWindFlow = true;
        % time
        Parameter.Time.TMin = 0;
        Parameter.Time.TMax = 100;
        Parameter.Time.dt   = 5;
        Parameter.Time.t    = Parameter.Time.TMin:Parameter.Time.dt:Parameter.Time.TMax;
        
        % wind
        Parameter.Windfarm.URef = 16;
        Parameter.v_0          = load('dcpdmy');
        
        % turbine
        D = 178;
        Parameter.Turbine.RotorRadius   = D/2;
        Parameter.Turbine.Name          = 'DTU10MW';
        
        % layout
        Parameter.Windfarm.nTurbines = 9;
        Parameter.Windfarm.Layout.x  = [0 0 0 7*D 7*D 7*D 14*D 14*D 14*D]; % inflow from x 0 -> inf
        Parameter.Windfarm.Layout.y  = 200 + [0 5*D 10*D 0 5*D 10*D 0 5*D 10*D];
        Parameter.Windfarm.Layout.z  = [119 119 119 119 119 119 119 119 119];
        Parameter.Windfarm.Grid.x    = 0:20:19*D;
        Parameter.Windfarm.Grid.y    = 0:30:(10*D+400);
        Parameter.Windfarm.Grid.z    = 0:30:300;
        [Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z] = meshgrid(Parameter.Windfarm.Grid.x,Parameter.Windfarm.Grid.y,Parameter.Windfarm.Grid.z);
        
        % wake model
        Parameter.WakeModel.InitialParameter   = [Parameter.Windfarm.URef;0.3;0.13;0]; % URef, delta_V, AxialInduction WakeDiss, Yaw
        Parameter.WakeModel.ForceScale  = 1;
        Parameter.WakeModel.k_d         = 0.15;
        Parameter.WakeModel.nParameter  = 4;
        % wake model grid
        
        Parameter.WakeModel.grid.x0 = 0;
        Parameter.WakeModel.grid.dx = Parameter.Windfarm.URef*Parameter.Time.dt;
        
        Parameter.WakeModel.nStates = 120;
        Parameter.WakeModel.grid.xEnd = (Parameter.WakeModel.nStates-1)*Parameter.WakeModel.grid.dx;
        
        Parameter.WakeModel.grid.x = Parameter.WakeModel.grid.x0:Parameter.WakeModel.grid.dx:Parameter.WakeModel.grid.xEnd;
        Parameter.WakeModel.grid.y0 = -150;
        Parameter.WakeModel.grid.dy = 25;
        Parameter.WakeModel.grid.yEnd = 150;
        Parameter.WakeModel.grid.y = Parameter.WakeModel.grid.y0:Parameter.WakeModel.grid.dy:Parameter.WakeModel.grid.yEnd;
        Parameter.WakeModel.grid.z0 = -150;
        Parameter.WakeModel.grid.dz = 25;
        Parameter.WakeModel.grid.zEnd = 150;
        Parameter.WakeModel.grid.z = Parameter.WakeModel.grid.z0:Parameter.WakeModel.grid.dz:Parameter.WakeModel.grid.zEnd;
        [Parameter.WakeModel.grid.X,Parameter.WakeModel.grid.Y,Parameter.WakeModel.grid.Z] = meshgrid(Parameter.WakeModel.grid.x,Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z);
        
        % windfield
        BasisWindField.IinW =  -[0 0 0];
        %x
        inputgrid.nx = 2;
        inputgrid.dx = 5000 /(inputgrid.nx-1);
        inputgrid.x0 = 0;
        inputgrid.x  = inputgrid.x0:inputgrid.dx:inputgrid.dx*(inputgrid.nx-1);
        %y
        inputgrid.ny = 2;
        inputgrid.dy = 300/(inputgrid.ny-1);
        inputgrid.y0 = 0;
        %z
        inputgrid.nz = 2;
        inputgrid.dz = 180/(inputgrid.nz-1);
        inputgrid.z0 = 0;
        % t
        inputgrid.nt = inputgrid.nx;
        inputgrid.dt = inputgrid.dx/Parameter.Windfarm.URef;
        inputgrid.t0 = inputgrid.x0/Parameter.Windfarm.URef;
        % gridding
        inputgrid.t = inputgrid.t0+(0:inputgrid.dt:(inputgrid.nt-1)*inputgrid.dt);
        inputgrid.y = inputgrid.y0+(0:inputgrid.dy:(inputgrid.ny-1)*inputgrid.dy);
        inputgrid.z = linspace(inputgrid.z0,(inputgrid.nz-1)*inputgrid.dz,inputgrid.nz);%inputgrid.z0+(0:inputgrid.dz:(inputgrid.nz-1)*inputgrid.dz);
        [inputgrid.X,inputgrid.Y,inputgrid.Z] = meshgrid(inputgrid.x,inputgrid.y,inputgrid.z);
        BasisWindField.grid = inputgrid;
        BasisWindField.u = ones(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.v = zeros(size(inputgrid.X))*Parameter.Windfarm.URef;
        BasisWindField.w = zeros(size(inputgrid.X))*Parameter.Windfarm.URef;
        
        % input
        TurbineData.AxialInduction.time            = Parameter.Time.t;
        TurbineData.AxialInduction.signals.values   = ones(size(Parameter.Time.t))*0.3;
        TurbineData.WakeDissipation.time            = Parameter.Time.t;
        TurbineData.WakeDissipation.signals.values   = ones(size(Parameter.Time.t))*0.1;
        
        PhiDesired          = 20:-10:0;
        StepTimes           = linspace(0,Parameter.Time.TMax,numel(PhiDesired)+1);
        StepTimes           = StepTimes(1:numel(PhiDesired));
        TurbineData.Yaw.time            = Parameter.Time.t;
        TurbineData.Yaw.signals.values   = deg2rad(interp1(StepTimes,PhiDesired,Parameter.Time.t,'previous','extrap'))*0;
end