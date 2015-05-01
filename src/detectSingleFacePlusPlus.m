function [points] = detectSingleFacePlusPlus(img)
    API_KEY = '4c233c47107187c32e42424be7b2bd08';
    API_SECRET = 'Wd2wzmlrCsHu1DTI7R4MDx8tucFR-lUs';


    api = facepp(API_KEY, API_SECRET, 'US');

    % Detect faces in the image, obtain related information (faces, img_id, img_height, 
    % img_width, session_id, url, attributes)
    rst = detect_file(api, img, 'all');
    img_width = rst{1}.img_width;
    img_height = rst{1}.img_height;
    face = rst{1}.face;
    fprintf('Totally %d faces detected!\n', length(face));
    %{
    im = imread(img);
    imshow(im);
    hold on;
    %}
    for i = 1 : length(face)
        % Draw face rectangle on the image
        face_i = face{i};

        %{
        center = face_i.position.center;
        w = face_i.position.width / 100 * img_width;
        h = face_i.position.height / 100 * img_height;
        rectangle('Position', ...
            [center.x * img_width / 100 -  w/2, center.y * img_height / 100 - h/2, w, h], ...
            'Curvature', 0.4, 'LineWidth',2, 'EdgeColor', 'blue');
        %}

        % Detect facial key points
        rst2 = api.landmark(face_i.face_id, '83p');
        landmark_points = rst2{1}.result{1}.landmark;
        landmark_names = fieldnames(landmark_points);

        % Draw facial key points
        points = zeros(length(landmark_names),2);
        for j = 1 : length(landmark_names)
            pt = getfield(landmark_points, landmark_names{j});
            %scatter(pt.x * img_width / 100, pt.y * img_height / 100, 'g.');
            points(j,:) = [pt.x * img_width / 100, pt.y * img_height / 100]; 
        end
    end
end
