% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function WakeState = UpdateWakeState(input,WakeState)

%shift states
WakeState.States = [input(:),WakeState.States(:,1:end-1)];

