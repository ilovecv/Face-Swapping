clear;
%Compile code for face FIRST!
addpath('./face_detection');
addpath('./max_flow');
addpath('./face_plusplus');
addpath('./TPS');

srcImgFile = '../data/4.jpg';
dstImgFile = '../data/5.jpg';

%read image
im_src = imread(srcImgFile);

%detect face
%[point_src] = detectSingleFace(im_src);
[point_src] = detectSingleFacePlusPlus(srcImgFile);
%get mask
point_src_M = point_src(convhull(point_src),:);
mask_src = roipoly(im_src,point_src_M(:,1),point_src_M(:,2));

%read image
im_dst = imread(dstImgFile);
%detect face
%[point_dst] = detectSingleFace(im_dst);
[point_dst] = detectSingleFacePlusPlus(dstImgFile);
%get mask
point_dst_M = point_dst(convhull(point_dst),:);
mask_dst = roipoly(im_dst,point_dst_M(:,1),point_dst_M(:,2));

%{
%get transform matrix
tform = fitgeotrans(point_src,point_dst,'nonreflectivesimilarity');
%transform src image to align with dst image
im_src_wrap = imwarp(im_src,tform,'OutputView',imref2d(size(im_dst)));
%}

%Morph the src image
[im_src_wrap, im_dst, mask_src, mask_dst] = morph_tps_wrapper(uint8(im_src), uint8(im_dst), point_src, point_dst,1,0,1, mask_src, mask_dst);

%Find optimal seam
[~,labels] = optimalSeamSearch(im_src_wrap, im_dst, mask_dst, mask_src);

%blending
R = uint8(im_src_wrap).*repmat(uint8(labels),[1,1,3]) + uint8(im_dst).*repmat(uint8(1-labels), [1 1 3]);

imshow(R)


%{
figure;
hold on;
imagesc(im_dst); axis image; axis off; drawnow; 1, 0
plot(point_dst(:,1),point_dst(:,2),'g.','markersize',15);
hold off;
%}