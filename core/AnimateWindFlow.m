% (c) Universitaet Stuttgart and sowento (TTI-GmbH)
function AnimateWindFlow(WF,Parameter)

if Parameter.AnimateWindFlow
    % figure
    figure;colormap(diverging_map(linspace(0,1,100),[0.230,0.299,0.754],[0.706,0.016,0.150])); % get the paraview colormap
    
    % internal constants
    HubHeight = mean(Parameter.Windfarm.Layout.z);
    [~,ID] = min(abs(WF{1}.grid.z-HubHeight));
    
    [X,Y] = meshgrid(Parameter.Windfarm.Grid.x,Parameter.Windfarm.Grid.y);
    U = squeeze(WF{1}.u(:,:,ID));
    h = surf(X,Y,U,'EdgeColor','none');
    axis equal;
    xlabel('x in [m]')
    ylabel('y in [m]')
    colorbar('SouthOutside')
    drawnow;
    view([0 90])
    axis equal; axis tight; shading interp;
    title(['u- component: t = ',num2str(Parameter.Time.t(1))]);
    
    nExecutions = numel(Parameter.Time.t);
    T = timer('Period',.5,... %period
        'ExecutionMode','fixedRate',... %{singleShot,fixedRate,fixedSpacing,fixedDelay}
        'BusyMode','drop',... %{drop, error, queue}
        'TasksToExecute',nExecutions,...
        'StartDelay',0,...
        'TimerFcn',@tcb,...
        'StartFcn',[],...
        'StopFcn',[],...
        'ErrorFcn',[]);
    
    % Start it
    start(T);
end
%Nested function!  Has access to variables in above workspace
    function tcb(src,evt)
        if ~isvalid(h)
            U = squeeze(WF{1}.u(:,:,ID));
            h = surf(X,Y,U,'EdgeColor','none');
            axis equal;
            xlabel('x in [m]')
            ylabel('y in [m]')
            colorbar('SouthOutside')
            drawnow;
            view([0 90])
            axis equal; axis tight; shading interp;
            drawnow;
        end
        
        %What task are we on?  Use this instead of for-loop variable ii
        iTime = get(src,'TasksExecuted');
        
        %Update the x and y data.
        h.ZData = squeeze(WF{iTime}.u(:,:,ID));
        caxis([0,Parameter.Windfarm.URef*1.2])
        title(['u- component: t = ',num2str(Parameter.Time.t(iTime))]);
        drawnow; %force event queue flush
    end


end
