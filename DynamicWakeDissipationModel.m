% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
clear all
close all
clc
if ~isempty(timerfindall)
    stop(timerfindall);
end

%addpath
addpath('./core/');

[BasisWindField,Parameter,TurbineData,SimulationCase,ResultDir] = DynamicWakeDissipationModelConfig;

% internal variables
nTurbines   = Parameter.Windfarm.nTurbines;
nParameter  = Parameter.WakeModel.nParameter;
nStates     = Parameter.WakeModel.nStates;

% initial states
WakeStates  = InitializeWakeModel(Parameter);
LocalWindfield = struct('u',repmat({[]},1,nTurbines),'v',repmat({[]},1,nTurbines),'w',repmat({[]},1,nTurbines));
%% simulation
for iTime = 1:numel(Parameter.Time.t)
    currentTime = Parameter.Time.t(iTime);
    % get undisturbed wind flow
    windfield = GetCurrentWindfieldFlow(BasisWindField,currentTime,Parameter);
    
    for iTurbine = 1:nTurbines

        CurrentState = WakeStates(iTurbine);
        
        v_0 = GetCurrentRotorEffectiveWindSpeed(windfield,iTurbine,Parameter);
        % write input to wake model
        input(:,1) = [v_0];
        input(:,2) = [TurbineData.AxialInduction.signals.values(iTime)];
        input(:,3) = [TurbineData.WakeDissipation.signals.values(iTime)];
        input(:,4) = [TurbineData.Yaw.signals.values(iTime)];

        % update wake states
        CurrentState = UpdateWakeState(input,CurrentState);
                
        % calculate wake for turbine
        WakeObject(iTime,iTurbine) = WakeDissipationModel(CurrentState,Parameter);
        LocalPositions = CurrentState.LocalPositions;

        % update local wake positions
        WakeStates(iTurbine) = UpdateWakeLocations(CurrentState,WakeObject(iTime,iTurbine).LocalU,Parameter);
        
        % transform to inertial coordinate system
        [XLocalGrid,YLocalGrid,ZLocalGrid] = meshgrid(LocalPositions,Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z);
        TinI.x = Parameter.Windfarm.Layout.x(iTurbine);
        TinI.y = Parameter.Windfarm.Layout.y(iTurbine);
        TinI.z = Parameter.Windfarm.Layout.z(iTurbine);
        [X,Y,Z] = T2I(XLocalGrid,YLocalGrid,ZLocalGrid,TinI);
        
        % map on global wind field grid
        LocalWindfield(iTurbine).u = interp3(X,Y,Z,WakeObject(iTime,iTurbine).LocalU,Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z,'linear',0);
        LocalWindfield(iTurbine).v = interp3(X,Y,Z,WakeObject(iTime,iTurbine).LocalV,Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z,'linear',0);
        LocalWindfield(iTurbine).w = zeros(size(Parameter.Windfarm.Grid.X));
        
         windfield.u = windfield.u + LocalWindfield(iTurbine).u;
         windfield.v = windfield.v + LocalWindfield(iTurbine).v;
         windfield.w = windfield.w + LocalWindfield(iTurbine).w;
    end
    
    
    display(['Current simulation time = ', num2str(Parameter.Time.t(iTime)),' of ', num2str(Parameter.Time.t(end))]);
    WF{iTime} = windfield;
    U(:,:,:,iTime) = windfield.u;
end
%% save results
if Parameter.DynamicWindfield.SaveResults
    if ~exist(ResultDir,'dir')
        mkdir(ResultDir);
    end
    save(fullfile(ResultDir,[SimulationCase,'.mat']),'BasisWindField','Parameter','TurbineData','SimulationCase','WF','U');    
end

%% video
AnimateWindFlow(WF,Parameter);
