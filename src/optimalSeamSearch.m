%% Find optimal seam search 
% Input: im_src_wrap: source image after wrapping
%        im_dst: destination image
%        mask_dst: mask for destination image
%        mask_src: mask for source image (may not use)
% Output: flow: no use
%         labels: label for each pixel

function [flow, labels] = optimalSeamSearch(im_src_wrap, im_dst_wrap, mask_dst, mask_src)
    %only use the dst mask, may be use src as well?
    SE_disk = strel('disk', 3, 6);
    mask_outer = imdilate(mask_dst, SE_disk);
    SE_disk = strel('disk', 3, 6);
    mask_inner = imerode(mask_dst, SE_disk);

    %if mask == 1, it belongs to overlap
    mask = mask_outer - mask_inner;
    %if M_dst == 1, it belongs to dst
    M_dst = ~mask_outer;
    %if M_src == 1, it belongs to src
    M_src = mask_inner;

    %imshow(imfuse(im_dst,mask));

    pixel_num = size(im_dst_wrap,1)*size(im_dst_wrap,2);

    %For sparse A matrix
    A_cnt = 0;
    A_row = zeros(pixel_num,1);
    A_col = zeros(pixel_num,1);
    A_val = zeros(pixel_num,1);
    %For sparse T matrix
    T_cnt = 0;
    T_row = zeros(pixel_num,1);
    T_col = zeros(pixel_num,1);   %1 for dst, 2 for src

    %For shift matrix
    im_shift_src = padarray(im_src_wrap,[0,1],'pre');
    im_shift_dst = padarray(im_dst_wrap,[0,1],'pre');

    im_shift_src = circshift(im_shift_src,[0,-1]);
    im_shift_dst = circshift(im_shift_dst,[0,-1]);

    im_shift_src = im_shift_src(:,1:end-1,:);
    im_shift_dst = im_shift_dst(:,1:end-1,:);

    M_left = sum((im_src_wrap - im_dst_wrap).^2, 3) + sum((im_shift_src - im_shift_dst).^2, 3);

    im_shift_src = padarray(im_src_wrap,[0,1],'post');
    im_shift_dst = padarray(im_dst_wrap,[0,1],'post');

    im_shift_src = circshift(im_shift_src,[0,1]);
    im_shift_dst = circshift(im_shift_dst,[0,1]);

    im_shift_src = im_shift_src(:,2:end,:);
    im_shift_dst = im_shift_dst(:,2:end,:);

    M_right = sum((im_src_wrap - im_dst_wrap).^2, 3) + sum((im_shift_src - im_shift_dst).^2, 3);

    im_shift_src = padarray(im_src_wrap,[1,0],'pre');
    im_shift_dst = padarray(im_dst_wrap,[1,0],'pre');

    im_shift_src = circshift(im_shift_src,[1,0]);
    im_shift_dst = circshift(im_shift_dst,[1,0]);

    im_shift_src = im_shift_src(1:end-1,:,:);
    im_shift_dst = im_shift_dst(1:end-1,:,:);

    M_up = sum((im_src_wrap - im_dst_wrap).^2, 3) + sum((im_shift_src - im_shift_dst).^2, 3);

    im_shift_src = padarray(im_src_wrap,[1,0],'post');
    im_shift_dst = padarray(im_dst_wrap,[1,0],'post');

    im_shift_src = circshift(im_shift_src,[1,0]);
    im_shift_dst = circshift(im_shift_dst,[1,0]);

    im_shift_src = im_shift_src(2:end,:,:);
    im_shift_dst = im_shift_dst(2:end,:,:);

    M_down = sum((im_src_wrap - im_dst_wrap).^2, 3) + sum((im_shift_src - im_shift_dst).^2, 3);


    [M,N,~] = size(im_dst_wrap);

    %Construct matrix A
    for i = 1 : pixel_num
        if M_dst(i) == 1 || M_src(i) == 1
            %for dst and src

            %check dst or src
            if M_dst(i) == 1
                v = 1;
            else
                v = 2;
            end
            T_cnt = T_cnt + 1;
            T_row(T_cnt) = i;
            T_col(T_cnt) = v;
            %process neighbor need to check!!
            %up
            n = i - 1;
            if mod(i,M) ~= 1
                T_cnt = T_cnt + 1;
                T_row(T_cnt) = n;
                T_col(T_cnt) = v;
            end
            %down
            n = i + 1;
            if mod(i,M) ~= 0
                T_cnt = T_cnt + 1;
                T_row(T_cnt) = n;
                T_col(T_cnt) = v;
            end
            %left
            n = i - M;
            if n > 0
                T_cnt = T_cnt + 1;
                T_row(T_cnt) = n;
                T_col(T_cnt) = v;
            end
            %right
            n = i + M;
            if n < pixel_num
                T_cnt = T_cnt + 1;
                T_row(T_cnt) = n;
                T_col(T_cnt) = v;
            end
        elseif mask(i) == 1

            %for mask
            n_count = 0;
            %process neighbor need to check!!
            %up
            n = i - 1;
            if mod(i,M) ~= 1 && mask(n) == 1
                n_count = n_count + 1;
                A_cnt = A_cnt + 1;
                A_row(A_cnt) = i;
                A_col(A_cnt) = n;
                A_val(A_cnt) = M_up(n);
            else
                continue;
            end
            %down
            n = i + 1;
            if mod(i,M) ~= 0 && mask(n) == 1
                n_count = n_count + 1;
                A_cnt = A_cnt + 1;
                A_row(A_cnt) = i;
                A_col(A_cnt) = n;
                A_val(A_cnt) = M_down(n);
            else
                A_cnt = A_cnt - n_count;
                continue;
            end
            %left
            n = i - M;
            if n > 0 && mask(n) == 1
                n_count = n_count + 1;
                A_cnt = A_cnt + 1;
                A_row(A_cnt) = i;
                A_col(A_cnt) = n;
                A_val(A_cnt) = M_left(n);
            else
                A_cnt = A_cnt - n_count;
                continue;
            end
            %right
            n = i + M;
            if n < pixel_num && mask(n) == 1
                n_count = n_count + 1;
                A_cnt = A_cnt + 1;
                A_row(A_cnt) = i;
                A_col(A_cnt) = n;
                A_val(A_cnt) = M_right(n);
            else
                A_cnt = A_cnt - n_count;
                continue;
            end
        else
            %shouldn't happen
        end
    end

    A = sparse(A_row(1:A_cnt),A_col(1:A_cnt),A_val(1:A_cnt), pixel_num, pixel_num, A_cnt);
    T_val = double(intmax).*ones(T_cnt,1);
    T = sparse(T_row(1:T_cnt),T_col(1:T_cnt),T_val, pixel_num, 2, T_cnt);

    [flow, labels] = maxflow(A,T);
    labels = reshape(labels,[M N]);
end