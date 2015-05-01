function [points] = detectSingleFace(im)
    load face_p146_small.mat;
    % 5 levels for each octave
    model.interval = 5;
    % set up the threshold
    model.thresh = min(-0.65, model.thresh);

    % define the mapping from view-specific mixture id to viewpoint
    if length(model.components)==13 
        posemap = 90:-15:-90;
    elseif length(model.components)==18
        posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
    else
        error('Can not recognize this model');
    end

    bs = detect(im, model, model.thresh);
    bs = clipboxes(im, bs);
    bs = nms_face(bs,0.3);
    
    %show results
    %figure;
    %showboxes(im, bs(1),posemap),title('Highest scoring detection');

    bs = bs(1);
    points = zeros(size(bs.xy,1),2);
    for i = 1 : size(bs.xy,1)
        x = (bs.xy(i,1) + bs.xy(i,3))/2;
        y = (bs.xy(i,2) + bs.xy(i,4))/2;
        points(i,:) = [x y];
    end
    
    %figure;
    %imshow(area);
end