function plot_MarkerOnNail(FileListAll, moving_points, fixed_points, xyPixelMat)
figure; 
k = length(FileListAll);
for t = 1:k
    oriFrame=imread(FileListAll(t).name);
    [rgbFrame] = PicTrans(moving_points, fixed_points, oriFrame);
    rgbFrameout = rgb2gray(rgbFrame);
    imshow(rgbFrameout);  
    hold on; drawnow;
    thisCentroid = xyPixelMat(t,:); 
    
    plot(thisCentroid(1), thisCentroid(2), 'r.', 'MarkerSize',20);
    drawnow; 
    
	caption = sprintf('Frame #%d 0f %d', t, k);
	title(caption, 'FontSize', 15);
    hold off
	drawnow;
end

