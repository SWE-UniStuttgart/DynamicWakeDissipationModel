% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function v_0 = GetCurrentRotorEffectiveWindSpeed(windfield,iTurbine,Parameter)
% Internal variables
RotorRadius     = Parameter.Turbine.RotorRadius;
Z = squeeze(windfield.grid.Z(:,1,:));
Y = squeeze(windfield.grid.Y(:,1,:));
R               = (Z(:).^2+Y(:).^2).^0.5;
PointsInside    = R<=RotorRadius;
xGrid       = windfield.grid.x;
xTurbine    = Parameter.Windfarm.Layout.x(iTurbine);

[Value,ID] = min((xGrid-xTurbine).^2);

if Value > 0
    if xGrid>xTurbine
        IDs = (ID-1:ID);
    else
        IDs = (ID:ID+1);
    end
    DX = diff(xGrid(IDs));
    ratio = (xTurbine - xGrid(IDs(1)))/DX;
    % linear interpolation
    CurrentWind     = squeeze(windfield.u(:,IDs(2),:))'*ratio + squeeze(windfield.u(:,IDs(1),:))'*(1-ratio); %transpose, because 3D grid is (nz x nt x ny) and 2D (nz x ny)
else
    CurrentWind     = squeeze(windfield.u(:,ID,:))';
end
u   = CurrentWind(PointsInside);
v_0	= mean(u);