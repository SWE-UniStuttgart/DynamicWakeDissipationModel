% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function [x_I,y_I,z_I] = T2I(x_T,y_T,z_T,TinI)
 % only translation not rotation
 
 x_I = x_T + TinI.x;
 y_I = y_T + TinI.y;
 z_I = z_T + TinI.z;
