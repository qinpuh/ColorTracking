function [t_delay, f_xy, d_xy] = alignForceVelocityTraces(vel, touch)
sf_video = 200;
sf_force = 63; 
%rename the force data file into 'touch'
%touch = BumpyPolyesterexplorationA; 
f_x = touch(:,1)-touch(1,1);  
f_y = touch(:,2)-touch(1,2); 

f_xy = sqrt(f_x.^2 + f_y.^2);
torq_x = touch(:,4)-touch(1,4); torq_y = touch(:,5)-touch(1,5); torq_z = touch(:,6)-touch(1,6);
d_xy = torq_z./f_xy; 



figure; subplot(211); 
plot((1:length(vel))/sf_video, vel,'col','k','LineWidth',2); xlabel('t'); ylim([0 500]);
subplot(212); 
plot((1:length(f_xy))/sf_force, f_xy,'col','k','LineWidth',2); xlabel('t');
title(['Do not close it']);

prompt = {'How many aligning points did you see'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'5'};
len_ans = inputdlg(prompt,dlgtitle,dims,definput);
NumofAlignPoints = str2num(cell2mat(len_ans));

% find t delay
figure; title('Click the aligning points on this velocity trace plot');
plot((1:length(vel))/sf_video, vel,'col','k','LineWidth',2); xlabel('t'); ylim([0 500]);
hold on;
maxAllowablePoints = NumofAlignPoints; % how many points to collect
numPointsClicked = 0;
promptMessage = sprintf('Click the aligning points', maxAllowablePoints);
[x,y] = ClickFig(numPointsClicked,maxAllowablePoints,promptMessage);
vel_x_acc = x;
pause(0.2); close(fig2);


figure; title('Click the aligning points on this force trace plot');
plot((1:length(f_xy))/sf_force, f_xy,'col','k','LineWidth',2); xlabel('t');
hold on;
maxAllowablePoints = NumofAlignPoints; % how many points to collect
numPointsClicked = 0;
promptMessage = sprintf('Click the aligning points', maxAllowablePoints);
[x,y] = ClickFig(numPointsClicked,maxAllowablePoints,promptMessage);
force_x_acc = x;
pause(0.2); close(fig2);


t_delay = mean(force_x_acc - vel_x_acc);
