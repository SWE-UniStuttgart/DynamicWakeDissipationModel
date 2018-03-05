% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function WakeObject = WakeDissipationModel(WakeState,Parameter)

% internal variables
nStates     = Parameter.WakeModel.nStates;

% local wake grid
[LocalGridY,LocalGridZ] = meshgrid(Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z);

% wake parameter
RotorDiameter   = Parameter.Turbine.RotorRadius*2;
k_d             = Parameter.WakeModel.k_d;
ForceScale      = Parameter.WakeModel.ForceScale;

% init
WakeCenter      = zeros(1,nStates);
WakeAngle       = zeros(1,nStates);
[ny,nz]         = size(LocalGridY);
WakeDeficit     = zeros(ny,nStates,nz);

LocalU          = zeros(ny,nStates,nz);
LocalV          = zeros(ny,nStates,nz);
LocalW          = zeros(ny,nStates,nz);

% wake calculation
parfor iState = 1:nStates
    % input mapping
    v_0                     = WakeState.States(1,iState);
    AxialInduction          = WakeState.States(2,iState);
    WakeDissipationRate     = WakeState.States(3,iState);
    Yaw                     = WakeState.States(4,iState);
    Position                = WakeState.LocalPositions(iState);
    
    c_P = 4*AxialInduction.*(1-AxialInduction).^2;
    if AxialInduction<=0.4
        c_T = 4*ForceScale*AxialInduction.*(1-AxialInduction);
    else
        % Glauert correction
        c_T = 8/9+(36*ForceScale-40)/9*AxialInduction+(50-36*ForceScale)/9*AxialInduction^2;
    end
    
    % wake center from yaw 
    WakeCenter(iState)      = GetWakeCenter(Yaw,c_T,Position,RotorDiameter,k_d);
    
    % wake rotation from yaw 
    WakeAngle(iState)       = GetWakeAngle(Yaw,c_T,Position,RotorDiameter,k_d);
    
    % wake deficit
    WakeDeficit(:,iState,:)      = interp2(Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z,GetWakeDeficit(v_0,c_P,WakeDissipationRate,Position,Parameter),LocalGridY-WakeCenter(iState),LocalGridZ,'linear',0)';
    
end

for iState = 1:nStates
    %transform in local wake coordinate system
    tmp.Wind.Elevation    = 0;
    tmp.Wind.Azimuth      = WakeAngle(iState);
    [u,v,w] = W2I(WakeDeficit(:,iState,:),0,0,tmp);
        
    LocalU(:,iState,:) = u;
    LocalV(:,iState,:) = v;
    LocalW(:,iState,:) = w;
end
%% map output
WakeObject.WakeCenter   = WakeCenter;
WakeObject.LocalU       = LocalU;
WakeObject.LocalV       = LocalV;
WakeObject.LocalW       = LocalW;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WakeCenterInit =  GetWakeCenterInit(yaw,c_T)
WakeCenterInit = (1/2*cos(yaw).^2.*sin(yaw).*c_T);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WakeCenter = GetWakeCenter(yaw,c_T,DeltaX,D,k_d)
yaw = -yaw;
WakeCenterInit = GetWakeCenterInit(yaw,c_T);
WakeCenter = WakeCenterInit.*(15.*((2.*k_d.*DeltaX)/D+1).^4+WakeCenterInit.^2)./(30*k_d./D.*(2.*k_d.*DeltaX/D+1).^5) - WakeCenterInit.*D.*(15+WakeCenterInit.^2)./(30.*k_d);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WakeAngle = GetWakeAngle(yaw,c_T,Position,RotorDiameter,k_d)
yaw = -yaw;
WakeCenterInit = GetWakeCenterInit(yaw,c_T);
WakeAngle = WakeCenterInit./(1+k_d.*Position./RotorDiameter).^2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitialWakeDeficit = GetInitialWakeDeficit(v_0,c_P,NormalizedDeficit,PointsInside)
persistent SumDefizit SumSquaredDefizit nPointsInside
if isempty(SumDefizit)
    SumDefizit          = sum(NormalizedDeficit(PointsInside(:)));
    SumSquaredDefizit   = sum(NormalizedDeficit(PointsInside(:)).^2);
    nPointsInside       = sum(sum(PointsInside));
end
% calculation
InitialWakeDeficit = (-v_0.*SumDefizit - v_0 .* sqrt(SumDefizit^2-SumSquaredDefizit.*c_P*nPointsInside))./(SumSquaredDefizit);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WakeDeficit = GetWakeDeficit(v_0,c_P,WakeDissipationRate,Position,Parameter)
persistent PointsInside NormalizedDeficit RGrid Rsq
if isempty(PointsInside)
    [Y,Z]   = meshgrid(Parameter.WakeModel.grid.y,Parameter.WakeModel.grid.z);
    RGrid       = (Z.^2+Y.^2).^0.5;
    PointsInside = RGrid<=Parameter.Turbine.RotorRadius;
    NormalizedDeficit     = - interp1(Parameter.v_0.my,Parameter.v_0.dcpdmy,RGrid/Parameter.Turbine.RotorRadius,'linear',0);
    Rsq             = RGrid.^2;
end

% initial wake deficit
InitialWakeDeficit = GetInitialWakeDeficit(v_0,c_P,NormalizedDeficit,PointsInside);

%% Evolution of Deficit for each point
Data            = (v_0+InitialWakeDeficit*NormalizedDeficit).^2;
FWHM                = Position*WakeDissipationRate;

if FWHM~=0
    sigma_f         = FWHM/(2*sqrt(2*log(2)));
    KernelTemp      = exp(-1/2*Rsq/sigma_f^2);
    Kernel          = KernelTemp/sum(KernelTemp(:));
    SmoothedData    = double(imfilter(single(Data), Kernel, v_0^2,'conv'));
    EvolvedDeficit  = (SmoothedData).^(1/2)-v_0;
else
    EvolvedDeficit  = InitialWakeDeficit*NormalizedDeficit;
end
WakeDeficit     = EvolvedDeficit;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



