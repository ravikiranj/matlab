function generated_image = generate_disk_image(radius, intensities, ndiscs, blur_size, blur_sigma, noise, polarity)
% generate_disk_image - used to generate an image of discs

% Usage
% =====
% radius - radius of the disc
% intensities - list of possible disc intensities in the range of [0, 1]
% ndiscs - number of discs
% blur_size - gaussian blur window size
% blur_sigma - gaussian blur standard deviation
% noise - gaussian noise variance
% polarity - 0 (light on dark), 1 (dark on light)

% initialize height and width of the image
height = 300;
width = 500;

% initialize the generated_image
generated_image = zeros(height, width, 1);

% represent each disk as a matrix [y, x, index_of_intensity]
disk_basis = [height, width, size(intensities,2)];
for n = 1 : ndiscs
    % create a disk with random intensity from the list and random center
    % (x,y)
    disk = floor(disk_basis .* rand(1,3));
    disk(3) = intensities(disk(3)+1);
    
    % fill each pixel where the distance between the center of disc and
    % pixel is less than the radius
    for i = 1:height
        for j = 1:width
            distance = sqrt( (disk(1)-i)^2 + (disk(2)-j)^2 );
            if distance <= radius
                intensity = generated_image(i, j, 1);
                generated_image(i, j, 1) = intensity + (1 - intensity) * disk(3);
            end
        end
    end
end

% apply gaussian blur
g = fspecial('gaussian', blur_size, blur_sigma);
generated_image = imfilter(generated_image, g, 'replicate');

% add gaussian noise
noise_distribution = sqrt(noise) * randn(height, width);
generated_image = generated_image + (1-generated_image) .* noise_distribution;


% invert the image if we selected inverse polarity
if polarity ~= 0
  generated_image = 1 - generated_image;
end

% Write image to file
filename = strcat('generated_img/img_',int2str(randi(1000,1)),'.png');
disp(filename);
imwrite(generated_image, filename,'png');

figure;
imshow(generated_image);
title 'Generated Image';
axis on;
axis image;

end

