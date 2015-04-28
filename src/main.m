clear;
%Compile code for face FIRST!
addpath('./face_detection');
%read image
im = imread('../data/1.jpg');
%show image
imagesc(im); axis image; axis off; drawnow;
%detect face
[bs, posemap] = detectSingleFace(im);
% show highest scoring one
figure,showboxes(im, bs(1),posemap),title('Highest scoring detection');
    