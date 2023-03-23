function [sys,x0,str,ts] = tp_pendan_g(t,x,u,flag)

%PENDAN S-function for making pendulum animation.
%
%   See also: PENDDEMO.

%   Copyright 1990-2001 The MathWorks, Inc.
%   $Revision: 1.20 $

% Plots every major integration step, but has no states of its own
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 1, 3, 4, 9 },
    sys = [];
    
  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock',
    LocalDeleteBlock
    
  %%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%
  case 'DeleteFigure',
    LocalDeleteFigure
  
  %%%%%%%%%%
%   % Slider %
%   %%%%%%%%%%
%   case 'Slider',
%     LocalSlider
  
  %%%%%%%%%
  % Close %
  %%%%%%%%%
  case 'Close',
    LocalClose
  
  %%%%%%%%%%%%
  % Playback %
  %%%%%%%%%%%%
  case 'Playback',
    LocalPlayback
   
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

% end pendan

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times, for the pendulum demo,
% the animation is updated every 0.1 seconds
%
ts  = [0.1 0];

%
% create the figure, if necessary
%
LocalPendInit;

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Update the pendulum animation.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

fig = get_param(gcbh,'UserData');
if ishandle(fig),
  if strcmp(get(fig,'Visible'),'on'),
    ud = get(fig,'UserData');
    LocalPendSets(t,ud,u);
  end
end;
 
sys = [];

% end mdlUpdate

%
%=============================================================================
% LocalDeleteBlock
% The animation block is being deleted, delete the associated figure.
%=============================================================================
%
function LocalDeleteBlock

fig = get_param(gcbh,'UserData');
if ishandle(fig),
  delete(fig);
  set_param(gcbh,'UserData',-1)
end

% end LocalDeleteBlock

%
%=============================================================================
% LocalDeleteFigure
% The animation figure is being deleted, set the S-function UserData to -1.
%=============================================================================
%
function LocalDeleteFigure

ud = get(gcbf,'UserData');
set_param(ud.Block,'UserData',-1);
  
% end LocalDeleteFigure


%
%=============================================================================
% LocalClose
% The callback function for the animation window close button.  Delete
% the animation figure window.
%=============================================================================
%
function LocalClose

delete(gcbf)

% end LocalClose

%
%=============================================================================
% LocalPlayback
% The callback function for the animation window playback button.  Playback
% the animation.
%=============================================================================
%
function LocalPlayback

%
% first find the animation data in the base workspace, issue an error
% if the information isn't there
%
t = evalin('base','t','[]');
y = evalin('base','y','[]');
 
if isempty(t) | isempty(y),
  errordlg(...
    ['You must first run the simulation before '...
     'playing back the animation.'],...
    'Animation Playback Error');
end

%
% playback the animation, note that the playback is wrapped in a try-catch
% because is it is possible for the figure and it's children to be deleted
% during the drawnow in LocalPendSets
%
try
  ud = get(gcbf,'UserData');
  for i=1:length(t),
    LocalPendSets(t(i),ud,y(i,:));
  end
end

% end LocalPlayback

%
%=============================================================================
% LocalPendSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
%=============================================================================
%
function LocalPendSets(time,ud,u)

XDelta   = .1;
PDelta   = 0.005;
L=1;
XPendTop = u(1) + L*sin(u(2));
YPendTop = L*cos(u(2));
PDcosT   = PDelta*cos(u(2));
PDsinT   = -PDelta*sin(u(2));
set(ud.Cart,...
  'XData',ones(2,1)*[u(1)-XDelta u(1)+XDelta]);
set(ud.Pend,...
  'XData',[XPendTop-PDcosT XPendTop+PDcosT; u(1)-PDcosT u(1)+PDcosT], ...
  'YData',[YPendTop-PDsinT YPendTop+PDsinT; -PDsinT PDsinT]);
set(ud.TimeField,...
  'String',num2str(time));

% Force plot to be drawn
pause(0.05)
drawnow

% end LocalPendSets

%
%=============================================================================
% LocalPendInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
%
function LocalPendInit

sys = get_param(gcs,'Parent');

TimeClock = 0;
%x_init=get_param([sys,'/Pendule/equation'],'x0');
x_init=get_param([sys,'/Pendule'],'x0');
x_init=evalin('base',x_init,'[]');
xp=x_init(1);
xt=x_init(3);

XCart     = x_init(3);
Theta     = x_init(1);

XDelta    = 0.1;
PDelta    = 0.005;
L=1;
XPendTop  = XCart + L*sin(Theta); % Will be zero
YPendTop  = L*cos(Theta);         % Will be 10
PDcosT    = PDelta*cos(Theta);     % Will be 0.2
PDsinT    = -PDelta*sin(Theta);    % Will be zero

%
% The animation figure handle is stored in the pendulum block's UserData.
% If it exists, initialize the reference mark, time, cart, and pendulum
% positions/strings/etc.
%
Fig = get_param(gcbh,'UserData');
if ishandle(Fig),
  FigUD = get(Fig,'UserData');
  set(FigUD.TimeField,...
      'String',num2str(TimeClock));
  set(FigUD.Cart,...
      'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);
  set(FigUD.Pend,...
      'XData',[XPendTop-PDcosT XPendTop+PDcosT; XCart-PDcosT XCart+PDcosT],...
      'YData',[YPendTop-PDsinT YPendTop+PDsinT; -PDsinT PDsinT]);
  %
  % bring it to the front
  %
  figure(Fig);
  pause(0.75)
  return
end

%
% the animation figure doesn't exist, create a new one and store its
% handle in the animation block's UserData
%
FigureName = 'Pendulum Visualization';
Fig = figure(...
  'Units',           'pixel',...
  'Position',        [100 100 500 300],...   % [100 100 500 300],[800 500 500 300]
  'Name',            FigureName,...
  'NumberTitle',     'off',...
  'IntegerHandle',   'off',...
  'HandleVisibility','callback',...
  'Resize',          'off',...
  'DeleteFcn',       'tp_pendan_g([],[],[],''DeleteFigure'')',...
  'CloseRequestFcn', 'tp_pendan_g([],[],[],''Close'');');
AxesH = axes(...
  'Parent',  Fig,...
  'Units',   'pixel',...
  'Position',[50 70 400 200],...
  'CLim',    [1 64], ...
  'Xlim',    [-.6 .6],...
  'Ylim',    [-.1 1.5],...
  'Visible', 'on');
Cart = surface(...
  'Parent',   AxesH,...
  'XData',    ones(2,1)*[XCart-XDelta XCart+XDelta],...
  'YData',    [0 0; -0.1 -0.1],...
  'ZData',    zeros(2),...
  'CData',    ones(2),...
  'EraseMode','xor');
Pend = surface(...
  'Parent',   AxesH,...
  'XData',    [XPendTop-PDcosT XPendTop+PDcosT; XCart-PDcosT XCart+PDcosT],...
  'YData',    [YPendTop-PDsinT YPendTop+PDsinT; -PDsinT PDsinT],...
  'ZData',    zeros(2),...
  'CData',    11*ones(2),...
  'EraseMode','xor');
uicontrol(...
  'Parent',  Fig,...
  'Style',   'text',...
  'Units',   'pixel',...
  'Position',[0 0 500 50]);
uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [150 0 100 25], ...
  'HorizontalAlignment','right',...
  'String',             'Time: ');
TimeField = uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [250 0 100 25],...
  'HorizontalAlignment','left',...
  'String',             num2str(TimeClock));
uicontrol(...
  'Parent',  Fig,...
  'Style',   'pushbutton',...
  'Position',[415 15 70 20],...
  'String',  'Close', ...
  'Callback','tp_pendan_g([],[],[],''Close'');');
uicontrol(...
  'Parent',  Fig,...
  'Style',   'pushbutton',...
  'Position',[15 15 70 20],...
  'String',  'Revoir', ...
  'Callback','tp_pendan_g([],[],[],''Playback'');',...
  'Interruptible','off',...
  'BusyAction','cancel');

%
% all the HG objects are created, store them into the Figure's UserData
%
FigUD.Cart         = Cart;
FigUD.Pend         = Pend;
FigUD.TimeField    = TimeField;
% FigUD.SlideControl = SlideControl;
FigUD.Block        = get_param(gcbh,'Handle');
set(Fig,'UserData',FigUD);

drawnow
pause(0.75)

%
% store the figure handle in the animation block's UserData
%
set_param(gcbh,'UserData',Fig);

% end LocalPendInit




% get_param('tp_comdec/Pendule/equation','handle')
% get_param(eq,'ObjectParameters')
% get_param('tp_comdec/Pendule/equation','DialogParameters')
% st_x_init=get_param('tp_comdec/Pendule/equation','X0')
% eval(st_x_init)
% 
% st_A=get_param('tp_comdec/Pendule/equation','A')
% eval(st_A)