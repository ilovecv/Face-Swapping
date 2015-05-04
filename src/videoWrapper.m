function videoWrapper(inputVideoName, outputVideoName, srcImageName)

clear;
%Compile code for face FIRST!
addpath('./face_detection');
addpath('./max_flow');
addpath('./face_plusplus');
addpath('./TPS');

%srcImgFile = '../data/test/3.jpg';
%dstImgFile = '../data/test/8.jpg';

%read src image
im = imread('../data/test/3.jpg');
srcImgFile = '../data/test/3.jpg';
%show src image
imagesc(im); axis image; axis off; drawnow;
im_src = imread(srcImgFile);

% read dst video
video = VideoReader('../data/WHCD_PresidentObama.mp4');
outputVideo = avifile('output.avi','FPS', video.FrameRate);

% resize src image
firstFrame = read(video, 1);
im_src = imresize(im_src, [size(firstFrame, 1), size(firstFrame, 2)]);
imresize_src_name = 'temp_resize_src.jpg';
imwrite(im_src, imresize_src_name);
%detect face
%[point_src] = detectSingleFace(im_src);
[point_src, placeholder] = detectSingleFacePlusPlus(imresize_src_name);
%get mask
point_src_M = point_src(convhull(point_src),:);        
mask_src = roipoly(im_src,point_src_M(:,1),point_src_M(:,2));

nFrames = video.NumberOfFrames;
for i = 1 : 300
    
    disp(datestr(now));
    sprintf('Frame %d in the video', i)
    im_dst = read(video, i);
    dstImgFile = 'temp_dst.jpg';
    imwrite(im_dst, dstImgFile);
    %detect face
    %[point_dst] = detectSingleFace(im_dst);
    [point_dst, check] = detectSingleFacePlusPlus(dstImgFile);
    if(check == 0)
        sprintf('No face or more than one face detected! Add the original frame.')
        outputVideo = addframe(outputVideo,im_dst);
        continue;
    end

    %get mask
    point_dst_M = point_dst(convhull(point_dst),:);        
    mask_dst = roipoly(im_dst,point_dst_M(:,1),point_dst_M(:,2));

    %{
    %get transform matrix
    tform = fitgeotrans(point_src,point_dst,'nonreflectivesimilarity');
    %transform src image to align with dst image
    im_src_wrap = imwarp(im_src,tform,'OutputView',imref2d(size(im_dst)));
    %}

    im_src_wrap = morph_tps_wrapper(uint8(im_src), uint8(im_dst), point_src, point_dst,1,0,0);


    [~,labels] = optimalSeamSearch(im_src_wrap, im_dst, mask_dst, mask_src); 

    R = uint8(im_src_wrap).*repmat(uint8(labels),[1,1,3]) + uint8(im_dst).*repmat(uint8(1-labels), [1 1 3]);
    %imshow(R)
    outputVideo = addframe(outputVideo,R);
end

outputVideo = close(outputVideo);
%read dst image
%im_dst = imread(dstImgFile);

%{
figure;
hold on;
imagesc(im_dst); axis image; axis off; drawnow; 1, 0
plot(point_dst(:,1),point_dst(:,2),'g.','markersize',15);
hold off;



R = uint8(im_src_wrap).*repmat(uint8(mask_dst),[1,1,3]) + uint8(im_dst).*repmat(uint8(1-mask_dst), [1 1 3]);

imshow(R);


falsecolorOverlay = imfuse(I,Jregistered);
figure
imshow(falsecolorOverlay,'InitialMagnification','fit');
%}
end
