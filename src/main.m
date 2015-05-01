clear;
%Compile code for face FIRST!
addpath('./face_detection');
%read image
im = imread('../data/3_resize.jpg');
%show image
imagesc(im); axis image; axis off; drawnow;
%detect face
area = detectSingleFace(im);


