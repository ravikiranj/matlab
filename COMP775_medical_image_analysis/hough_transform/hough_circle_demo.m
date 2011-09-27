%% Demo file to run hough_transform_circles
% Setup
% Reads an existing image or generate a new image using
% generate_disk_image and use it.
choice = questdlg('Please choose one of the below options', ...
                  'User Input', 'Choose an Image from File', 'Generate an Image', 'Choose an Image from File');             
if strcmp(choice, 'Choose an Image from File')    
    [filename, pathname] = uigetfile({'*.jpg; *.jpeg; *.gif; *.bmp; *.png'}, 'File Selector');
    %If valid filename is present, replace imgpath
    if ~isempty(pathname) && ~isempty(filename)
        imgpath = strcat(pathname, filename);
    end

    % Read the image
    img = imread(imgpath);    
else    
    % default values
    radius = 30;
    intensities = [0.15 0.30 0.45 0.60 0.75 0.90];
    ndiscs = 10;
    blur_size = 3;
    blur_sigma = 0.9;
    noise = 0.1;
    polarity = 0;
    

    % Use GUI to read params
    prompt = {'Radius', ...          
              'ndiscs', ...
              'Gaussian Blur Size', ...
              'Gaussian Standard Deviation', ...
              'Noise', ...
              'Polarity'};          
    defaults={'30', '10', '3', '0.9', '0.1', '0'};
    fields = {'radius', 'ndiscs', 'blur_size', 'blur_sigma', 'noise', 'polarity',};
    info = inputdlg(prompt, 'Enter Values to Generate an Image', [1 75], defaults);
    if ~isempty(info)              
       info = cell2struct(info,fields);
       radius = str2num(info.radius);   
       ndiscs = str2num(info.ndiscs);
       blur_size = str2num(info.blur_size);
       blur_sigma = str2double(info.blur_sigma);
       noise = str2double(info.noise);
       polarity = str2num(info.polarity);   
    end
    img = generate_disk_image(radius, intensities, ndiscs, blur_size, blur_sigma, noise, polarity);
end

% Define default values for inputs
debug = false;
gauss_sigma = 2.1; % Gaussian Standard Deviation
gauss_window = 3;  % Gaussian Window Size
radius = 30; % Radius of the disc
% Polarity Values -> 0 = light on dark, 1 = dark on light
polarity = 0; 
parzen = 2.1;  % Parzen Standard Deviation
grad_mag_threshold = 0.2; % Gradient Magnitude Threshold
mean_sigmoid = 2; % Mean of the Sigmoid function
sigma_sigmoid = 1; % Standard Deviation of the Sigmoid function

%% Read Input Parameters
% Use GUI to read params
prompt = {'Gaussian Standard Deviation (Scale)', ...
          'Gaussian Window', ...
          'Disk Radius', ...
          'Polarity (0 - light on dark, 1 - dark on light)', ...
          'Parzen Standard Deviation', ...
          'Gradient Magnitude Threshold', ...
          'Mean of Sigmoid Function', ...
          'Standard Deviation of Sigmoid Function'};             
defaults={'2.1', '3', '30', '0', '2.1', '0.2', '2', '1'};
fields = {'gauss_sigma', 'gauss_window', 'radius', 'polarity', 'parzen', 'grad_mag_threshold', 'mean_sigmoid', 'sigma_sigmoid'};
info = inputdlg(prompt, 'Enter Values to perform Hough Transform', [1 75], defaults);
if ~isempty(info)              
   info = cell2struct(info,fields);
   gauss_sigma = str2double(info.gauss_sigma);
   gauss_window = str2num(info.gauss_window);
   radius = str2double(info.radius);
   polarity = str2double(info.polarity);
   parzen = str2double(info.parzen);
   grad_mag_threshold = str2double(info.grad_mag_threshold);   
   mean_sigmoid = str2double(info.mean_sigmoid);
   sigma_sigmoid = str2double(info.sigma_sigmoid);
end

% Call the hough_transform_circle function
hough_transform_circle(img, radius, gauss_sigma, gauss_window, polarity, parzen, grad_mag_threshold, mean_sigmoid, sigma_sigmoid);