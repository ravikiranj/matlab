%%# Read the image
img = imread('./Images/Utah_teapot.png');
%# Add a constant to each pixel in the image
img_add = imadd(img, 25);
%# Save the intermediate image
imwrite(img_add, './Images/Utah_teapot_constadd.png');
%# Create a Gaussian Filter
gauss_filter = fspecial('gaussian', [5 5], 2);
%# Apply it on the image
img_gauss = imfilter(img_add, gauss_filter, 'same');
%# Save the Final Image
imwrite(img_gauss, './Images/Utah_teapot_gausss.png');