clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.


x = [zeros(11,1), 6*ones(11,1) , 137*ones(11,1) ,...
    84*ones(11,1) ,9*ones(11,1) ,4*ones(11,1)];

y = [ ones(1,6) ; 4*ones(1,6)  ; 45*ones(1,6) ;...
    25*ones(1,6) ; 2*ones(1,6) ; 2*ones(1,6) ;...
    13*ones(1,6) ; 52*ones(1,6) ; 58*ones(1,6) ;...
    15*ones(1,6) ; 4*ones(1,6)];

NumSensorsCol = 6;
NumSensorsRow = 11;

InputMatrix = y+x;
panelLength = 700; % width is adjusted to length to have square tiles
% panelWidth = 300;
panelWidth = round(panelLength - (size(InputMatrix,2)/size(InputMatrix,1))*panelLength);
windowPosX=100; windowPosY = 100;

%% Add Gaussian Pulses

% touchPanelLength = 1080;
% touchPanelWidth = 720;
touchPanelLength = panelLength;
touchPanelWidth = panelWidth;

pointerSize = 30;
numberOfPointers = 2;

% Set up some parameters.

windowSize = round(0.5*touchPanelWidth); % Could be random if you want.
sigma = pointerSize; % Could be random if you want.
numberOfGaussians = numberOfPointers;
rows = touchPanelLength;
columns = touchPanelWidth;
% Create one Gaussian.
g = fspecial('gaussian', windowSize, sigma);
grayImage = ones(rows, columns);
sRegions=ones(1,size(g,2)); % all positive gaussians
% Get a list of random locations.
randomRow = randi(rows-windowSize+1, [1 numberOfGaussians]);
randomCol = randi(columns-windowSize+1, [1 numberOfGaussians]);

disp('Original Gaussian Pulses Locations:')
disp(' col(x) row(y)')
disp( [randomCol' randomRow'])

% Place the Gaussians on the image at those random locations.
for k = 1 : numberOfGaussians
  grayImage(randomRow(k):randomRow(k)+windowSize-1,...
      randomCol(k):randomCol(k)+windowSize-1) = ...
    grayImage(randomRow(k):randomRow(k)+windowSize-1,...
    randomCol(k):randomCol(k)+windowSize-1) + ...
    sRegions(k) * g; %multiplying signs and adding the gaussian pulses.
end
% Display the final image = grayImage

%adding random noise
gM = grayImage + grayImage .* 1e-5.*rand(size(grayImage));
%rescaling/converting
gMgray = mat2gray(gM);
analogMat = cat(3,gMgray,gMgray,gMgray);
analogMat = flip(analogMat); % correct x axis

image(analogMat)

set(gcf ,...
    'position',[windowPosX+300 windowPosY panelWidth panelLength])
axis([0 size(analogMat,2) 0 size(analogMat,1)])
% set(gcf,'MenuBar', 'none','NumberTitle', 'on' ,...
%     'position',[windowPosX windowPosY panelWidth panelLength])
% set(gca,'position', [0, 0, 1, 1])
% 



%% Quantization to the pseudo analog input

rgbImage = analogMat;
% Get the dimensions of the image.  numberOfColorBands should be = 3.
[rows columns numberOfColorBands] = size(rgbImage);
%==========================================================================
% The first way to divide an image up into blocks is by using mat2cell().
blockSizeR = round(rows / NumSensorsRow); % Rows in block.
blockSizeC = round( columns / NumSensorsCol); % Columns in block.
% Figure out the size of each block in rows. 
% Most will be blockSizeR but there may be a remainder amount of less than that.
wholeBlockRows = floor(rows / blockSizeR);
blockVectorR = [blockSizeR * ones(1, wholeBlockRows), rem(rows, blockSizeR)];
% Figure out the size of each block in columns. 
wholeBlockCols = floor(columns / blockSizeC);
blockVectorC = [blockSizeC * ones(1, wholeBlockCols), rem(columns, blockSizeC)];
% Create the cell array, ca.  
% Each cell (except for the remainder cells at the end of the image)
% in the array contains a blockSizeR by blockSizeC by 3 color array.
% This line is where the image is actually divided up into blocks.
if numberOfColorBands > 1
  % It's a color image.
  ca = mat2cell(rgbImage, blockVectorR, blockVectorC, numberOfColorBands);
else
  ca = mat2cell(rgbImage, blockVectorR, blockVectorC);
end
% Now display all the blocks.
plotIndex = 1;
numPlotsR = size(ca, 1);
numPlotsC = size(ca, 2);

caMeans = ca;

% figure(3) %****** 
% set(gcf,'MenuBar', 'none','NumberTitle', 'off' ,...
%     'position',[windowPosX windowPosY panelWidth panelLength])
% set(gca,'position', [0, 0, 1, 1])

for r = 1 : numPlotsR
  for c = 1 : numPlotsC
%     subplot(numPlotsR, numPlotsC, plotIndex); % **** plot chopped
    % Extract the numerical array out of the cell
    % just for tutorial purposes.
    rgbBlock = ca{r,c};
    
    % averaging the block and create a new block
    b = ca{r,c};
    meanB = mean(b(:));
    % put the block back
    caMeans{r,c} = meanB;
%     imshow(rgbBlock); % Could call imshow(ca{r,c}) if you wanted to.****
%     [rowsB columnsB numberOfColorBandsB] = size(rgbBlock);
    plotIndex = plotIndex + 1;
  end
end

capMat = 100*cell2mat(caMeans); % capacitance Matrix values from 20~100
capMat = capMat(:,1:end-1); % last col is garbage



%% Heat Map
% Making Heatmap figure has square tiles
heatmapInputMatrix = capMat;
heatmapLength = panelLength; % width adjusted to length for square tiles
heatmapWidth = round(heatmapLength -...
    (size(heatmapInputMatrix,2)/size(heatmapInputMatrix,1))*heatmapLength);
figure('Renderer', 'painters', 'Position',...
        [windowPosX windowPosY heatmapWidth heatmapLength])
tempMap = heatmap(heatmapInputMatrix);
% set(gcf,'MenuBar', 'none','NumberTitle', 'on')
% % Make heatmap fill the figure
% tempMap.InnerPosition = [0 0 1 1];

%%
 sRegions = regionprops(capMat,capMat,{'Centroid','WeightedCentroid'});

 sRegions.WeightedCentroid
% xyPositions = structfun( @rmmissing , sRegions.WeightedCentroid , 'UniformOutput' , false);
% remove threshould 
threshould =45;
% xyPositions(xyPositions(:)<threshould)=0)
disp('result is x y relative to the resolution of the heatmap 6,11')