% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function WakeStates = InitializeWakeModel(Parameter)

% internal variables
nTurbines   = Parameter.Windfarm.nTurbines;
nStates     = Parameter.WakeModel.nStates;


WakeStates = struct('TurbineName', Parameter.Turbine.Name,...
                    'States', repmat({repmat(Parameter.WakeModel.InitialParameter(:),1,nStates)},nTurbines,1),...
                    'LocalPositions', repmat({Parameter.WakeModel.grid.x},nTurbines,1));