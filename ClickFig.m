function [x,y] = ClickFig(numPointsClicked,maxAllowablePoints,promptMessage)
titleBarCaption = 'Continue?';
button = questdlg(promptMessage, titleBarCaption, 'Continue', 'Cancel', 'Continue');
if strcmpi(button, 'Cancel')
  return;
end
while numPointsClicked < maxAllowablePoints
  numPointsClicked = numPointsClicked + 1;
  [x(numPointsClicked), y(numPointsClicked), button] = ginput(1)  
  plot(x(numPointsClicked), y(numPointsClicked), 'r+', 'MarkerSize', 15);
  if numPointsClicked == 4
    % Exit loop if
    break;
  end
end
msgbox('Done collecting points');