
function [vel] = plot_velocity(xyRealMat, center_point)

sf_video = 200;
xy_len = 1:length(xyRealMat(:,1)); 

vel=[0];
for eid = 2:length(xyRealMat(:,1))
    vel = [vel, sqrt( (xyRealMat(eid,1) - xyRealMat(eid-1,1)).^2 + (xyRealMat(eid,2) - xyRealMat(eid-1,2)).^2)/(1/sf_video)] ;
end

figure; 
subplot(221); hold;
plot(xy_len/sf_video, xyRealMat(:,1),'col','k','LineWidth',2); ylabel('x position (mm)'); box off;  

subplot(222); hold; 
plot(xy_len/sf_video, xyRealMat(:,2),'col','k','LineWidth',2); ylabel('y position (mm)'); box off;

subplot(223); hold;
plot(xy_len/sf_video, vel,'col','k','LineWidth',2); ylabel('velocity (mm/s)'); box off; xlabel('t(s)');

subplot(224); hold;
dist_array = sqrt( (xyRealMat(:,1)-center_point(1)).^2 + (xyRealMat(:,2)-center_point(2)).^2 );
plot(xy_len/sf_video, dist_array,'col','k','LineWidth',2); ylabel('distance from center (mm)'); box off; xlabel('t(s)');

set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',15,'FontWeight','Bold', 'LineWidth', 2);