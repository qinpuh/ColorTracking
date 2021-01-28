%% 5. plot position and velocity traces
sf_video=200;
xy_len = 1:length(xyRealMat(:,1)); 

vel=[0];
for eid = 2:length(xyRealMat(:,1))
    vel = [vel, sqrt( (xyRealMat(eid,1) - xyRealMat(eid-1,1)).^2 + (xyRealMat(eid,2) - xyRealMat(eid-1,2)).^2)/(1/sf_video)] ;
end

figure; 
plot(xy_len/sf_video, vel,'col','k','LineWidth',2); ylabel('velocity'); box off; xlabel('t(s)');


ind_end = find(xyPixelMat(:,1)==0,1,'first');

figure; 
subplot(121); hold;
plot(xy_len/sf_video, xyRealMat(:,1),'col','k','LineWidth',2); ylabel('x position'); box off;  

subplot(122); hold; 
plot(xy_len/sf_video, xyRealMat(:,2),'col','k','LineWidth',2); ylabel('y position diff'); box off;

subplot(223); hold;
plot(xy_len/sf_video, vel,'col','k','LineWidth',2); ylabel('velocity'); box off; xlabel('t(s)');

subplot(224); hold;
dist_array = sqrt( (xyRealMat(:,1)-center_point(1)).^2 + (xyRealMat(:,2)-center_point(2)).^2 );
plot(xy_len/sf_video, dist_array,'col','k','LineWidth',2); ylabel('distance from center'); box off; xlabel('t(s)');

set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',15,'FontWeight','Bold', 'LineWidth', 2);

%% 6. import force data (through 'importdata' under the home menu) and find the t delay between force and velocity data
sf_force=63; 
%rename the force data file into 'touch'
%touch = BumpyPolyesterexplorationA; 
f_x = touch(:,1)-touch(1,1);  
f_y = touch(:,2)-touch(1,2); 

f_xy = sqrt(f_x.^2 + f_y.^2);
torq_x = touch(:,4)-touch(1,4); torq_y = touch(:,5)-touch(1,5); torq_z = touch(:,6)-touch(1,6);
d_xy = torq_z./f_xy; 


% find t delay
figure; subplot(211); 
plot((1:length(vel))/sf_video, vel,'col','k','LineWidth',2); xlabel('t'); ylim([0 500]);
subplot(212); 
plot((1:length(f_xy))/sf_force, f_xy,'col','k','LineWidth',2); xlabel('t');

% dots=[];
% dots(:,1) = [1.49,1.77,2.08, 3.85,8.24]; %this data are read from the peaks of the finger taps used to align the two data set
% dots(:,2) = [2.5, 3.95, 5.3, 6.3, 13.4];
% 
% figure;hold;
% for eid = 1:size(dots,1)
%     scatter(dots(eid,1),dots(eid,2),100,'k.');
% end
% 
% t_delay = mean(dots(:,2)-dots(:,1));

%% 7. plot force and xy position from video on the same subplot
%x_off = -t_delay;
x_off=0;
figure; hold; 
plot([1:length(vel)]/sf_video, vel,'col','k','LineWidth',2); xlabel('t');

t_len = length(f_xy);
plot(x_off+(1:t_len)/sf_force,20*f_xy ,'col','r','LineWidth',2); 
xrange = xlim;

plot(x_off+(1:t_len)/sf_force,50*d_xy+20 ,'col','g','LineWidth',2); 
%set(gca,'xtick',[0:200:xrange(2)],'xticklabel',[0:200/sf_force:xrange(2)/sf_force]); xlabel('time (s)');
legend({'velocity','xy force'}); legend box off