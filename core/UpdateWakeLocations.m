% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function WakeState = UpdateWakeLocations(WakeState,LocalU,Parameter)

% internal variable
dt = Parameter.Time.dt;
% update positions by local velocities
WakeState.LocalPositions = WakeState.LocalPositions + (nanmean(nanmean(LocalU,3),1)+WakeState.States(1,:))*dt;
WakeState.LocalPositions = sort([0 WakeState.LocalPositions(1:end-1)]);