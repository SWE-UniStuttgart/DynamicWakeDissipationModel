% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function windfield = GetCurrentWindfieldFlow(BasisWindField,currentTime,Parameter)

% t -> x calculation
x_Offset = Parameter.Windfarm.URef*currentTime;

[X,Y,Z] = meshgrid(-BasisWindField.grid.t*Parameter.Windfarm.URef+x_Offset,BasisWindField.grid.y,BasisWindField.grid.z);
% perhaps trafo to different coordiante system
if isfield(BasisWindField,'IinW')
    Parameter.Wind.PositionIinW = [BasisWindField.IinW];
    Parameter.Wind.Elevation    = 0;
    Parameter.Wind.Azimuth      = 0;
    [X,Y,Z] = W2I(X,Y,Z,Parameter);
end
% u
windfield.u = interp3(X,Y,Z,BasisWindField.u,Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z,'linear',NaN);
windfield.u(isnan(windfield.u)) = Parameter.Windfarm.URef;
% v
windfield.v = interp3(X,Y,Z,BasisWindField.v,Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z,'linear',NaN);
windfield.v(isnan(windfield.v)) = 0;
% w
windfield.w = interp3(X,Y,Z,BasisWindField.w,Parameter.Windfarm.Grid.X,Parameter.Windfarm.Grid.Y,Parameter.Windfarm.Grid.Z,'linear',NaN);
windfield.w(isnan(windfield.w)) = 0;

%grid
windfield.grid = Parameter.Windfarm.Grid;