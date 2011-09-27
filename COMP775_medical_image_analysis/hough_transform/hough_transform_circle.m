function hough_transform_circle(img, radius, gauss_sigma, gauss_window, polarity, parzen, grad_mag_threshold, mean_sigmoid, sigma_sigmoid) 
%   hough_transform_circles - function to find discs/circles in an image using Hough Transform 
%
%   Usage
%   =====
%   img - image
%   radius - radius(px) of the disc/circle    
%   gauss_sigma - gaussian standard deviation (scale)
%   gauss_window - gaussian window size (used for gaussian filter) 
%   polarity - 0 (light on dark), 1 (dark on light)
%   parzen - standard deviation used to blur the accumulator (parzen windowing) 
%   grad_mag_threshold - pixels with gradient magnitude below this
%                        threshold do not get to vote
%   mean_sigmoid - mean of the sigmoid function (used for determining vote
%                  strength)
%   sigma_sigmoid - standard deviation of the sigmoid function (used for
%                   determining vote strength)

% Convert to grayscale if required
if ndims(img) >= 3
    img = im2bw(img);
    %img = rgb2gray(img);
end

% Type cast to double
I = double(img);

% Convolve with a Gaussian Filter and Obtain the Gradient Magnitude and
% Direction
g1 = fspecial('gaussian', gauss_window, gauss_sigma);
I = imfilter(I, g1, 'replicate');

% Compute the Gradients in X and Y direction
[FX, FY] = gradient(I);
% Compute the Magnitude of the Gradient at (X,Y) = SQRT(FX^2+FY^2)
grad_mag = (FX .^ 2 + FY .^ 2) .^ 0.5;
%grad_mag_threshold = mean2(grad_mag);

% Compute the size of the image, initialize the accumulator and vote
[maxx, maxy] = size(I);
accum = zeros(maxx, maxy);
vote = zeros(maxx, maxy);

% For each pixel in the image, check if the Gradient_Magnitude at (x,y) is 
% greater than the Gradient_Magnitude_Threshold.
% If yes, 
%   a) Compute Gradient Magnitude Direction, theta = atan(FY/FX)
%   b) Based on the polarity(0 or 1), compute the center of the 
%      circle at radius distance.
for x = 1:maxx
    for y = 1:maxy
        if grad_mag(x,y) > grad_mag_threshold
            theta = atan( FY(x,y)/FX(x,y) );
            xc = int32(x + (-1 ^ polarity) * (radius * sin(theta)));
            yc = int32(y + (-1 ^ polarity) * (radius * cos(theta)));
            % Check if 1 <= xc <= maxx and 1 <= yc <= maxy,
            % If yes,
            %       a) Add the entry to the accumulator for (xc, yc)
            %       b) Add to the vote strength
            if(xc >= 1 && xc <= maxx && yc >= 1 && yc <= maxy)
                % Compute vote strength using sigmoid function i.e, sigmf
                % f(x,a,c) = 1 / (1 + e^(x-c/a)), 
                % where c = mean, a = standard deviation
                vote(x,y) = sigmf(grad_mag(x,y), [sigma_sigmoid mean_sigmoid]);                
                accum(xc,yc) = accum(xc,yc) + vote(x,y);
                %accum(xc,yc) = accum(xc,yc) + 1;
            end                    
        end
    end
end

% Compute screen size to position figures [left, bottom, maxx, maxy]
screen_size = get(0, 'ScreenSize');
outputAccPos = [uint32((screen_size(3)-screen_size(1)+1)/2) uint32((screen_size(4)-screen_size(2)+1)/4) maxy+100 maxx+100];
% Show the accumulator
figure('Position', outputAccPos);
%figure();
hold on;
imagesc(accum);
colormap(gray);
axis image;
title 'Accumulator';
hold off;

% Show the first disc/circle by default
first_time = 1;
% Compute position of the result
outputResPos = [uint32((screen_size(3)-screen_size(1)+1)/10) uint32((screen_size(4)-screen_size(2)+1)/4) maxy+100 maxx+100];

% Find maxima until user clicks 'Yes'
while true
    % Ask the user if he wants to find more discs/circles
    if first_time
        choice = 'Yes';
    else            
        choice = questdlg('Would you like to find another circle?', 'User Input', 'Yes', 'No', 'Yes');
    end
    % Quit the application if user does not want to find more
    % discs/circles
    if strcmp(choice, 'No')        
        break;
    end                       
   

    % Smooth the Accumulator by Gaussian Filter controlled by Parzen
    % Standard Deviation
    g2 = fspecial('gaussian', gauss_window, parzen);
    % Parzen Windowing
    accum = imfilter(accum, g2, 'replicate');

    % To eliminate the problem of finding a nearby maxima of an already
    % found maxima, mask the neighbourhood of found maxima by a window
    mask_maxima_window = uint32(radius/3);

    [row_val row_ind] = max(accum, [], 1);
    [col_val col_ind] = max(row_val);
    % Row = Y level, Column = X Level
    x = col_ind;
    y = row_ind(col_ind);        

    % Reset Value at maxima position and its sorrounding 3x3 matrix,
    % decrease no. of peaks by 1 and increase index by 1                
    for i = x-mask_maxima_window : x+mask_maxima_window
        for j = y-mask_maxima_window : y+mask_maxima_window
            % j or y = row , i or x = column, hence (j,i)
            if (j > 0 && j <= maxx && i > 0 && i < maxy)
                accum(j, i) = 0.0;
            end
        end
    end        

    % Show the results 
    % Show the original image only the first time and then super impose the
    % circles from then on
    if first_time
        figure('Position', outputResPos);
        %figure();
        %img = imread(imgpath);
        %imshow(img);        
        imagesc(img);
        colormap(gray);
        axis on;
        axis image;
        title 'Identified Discs in the image';
    end
    
     % Reset first_time
    first_time = 0;
    hold on;
    
    % Number of points to draw the circle
    N = 100;
    % Draw the circles centered at (x,y) and radius
    t=(0:N)*2*pi/N;
    xp=radius*cos(t)+x;
    yp=radius*sin(t)+y;
    p = plot(xp, yp);    
    set(p,'Color','red','LineWidth',2)        
    hold off
end
