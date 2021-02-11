
function plot_VelandForce(vel, f_xy, d_xy, t_delay)
x_off= -t_delay; 
sf_force = 63; 
sf_video = 200;

figure; hold; 
plot([1:length(vel)]/sf_video, vel,'col','k','LineWidth',2); xlabel('t');

t_len = length(f_xy);
plot(x_off+(1:t_len)/sf_force,100*f_xy+50 ,'col','r','LineWidth',2); 
xrange = xlim;

plot(x_off+(1:t_len)/sf_force,100*d_xy+50 ,'col','g','LineWidth',2); 
%set(gca,'xtick',[0:200:xrange(2)],'xticklabel',[0:200/sf_force:xrange(2)/sf_force]); xlabel('time (s)');
legend({'velocity','xy force'}); legend box off