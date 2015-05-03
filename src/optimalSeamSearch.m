%% Find optimal seam search 
% Input: im_src_wrap: source image after wrapping
%        im_dst: destination image
%        mask_dst: mask for destination image
%        mask_src: mask for source image (may not use)
% Output: flow: no use
%         labels: label for each pixel

function [flow, labels] = optimalSeamSearch(im_src_warp, im_dst_warp, mask_dst, mask_src)
    %only use the dst mask, may be use src as well?
    
    %split mask to head and below part
    top_mask = mask_dst;
    bottom_mask = mask_dst;
    [v, indx] = max(mask_dst,[],1);
    bd = indx(find(v==1,1));
    top_mask(bd+1:end,:) = 0;
    bottom_mask(1:bd,:) = 0;
    SE_disk = strel('disk',10,6);
    top_mask_outer = imdilate(top_mask, SE_disk);
    top_mask_inner = top_mask;

    bottom_mask_outer = bottom_mask;
    SE_disk = strel('disk',10,6);
    bottom_mask_inner = imerode(bottom_mask, SE_disk);

    mask_outer = logical(top_mask_outer + bottom_mask_outer);
    mask_inner = bwconvhull(logical(top_mask_inner + bottom_mask_inner));
    %}
    %{
    SE_disk = strel('disk', 3, 6);
    mask_outer = imdilate(mask_dst, SE_disk);
    SE_disk = strel('disk', 3, 6);
    mask_inner = imerode(mask_dst, SE_disk);
    %}
    %if mask == 1, it belongs to overlap
    mask = mask_outer - mask_inner;
    %if M_dst == 1, it belongs to dst
    M_dst = ~mask_outer;
    %if M_src == 1, it belongs to src
    M_src = mask_inner;
    %{
    figure;
    imshow(imfuse(uint8(im_dst_warp),mask_outer));
    figure;
    imshow(imfuse(uint8(im_dst_warp),mask_inner));
    figure;
    %}
    pixel_num = size(im_dst_warp,1)*size(im_dst_warp,2);

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
    im_shift_src = padarray(im_src_warp,[0,1],'pre');
    im_shift_dst = padarray(im_dst_warp,[0,1],'pre');

    im_shift_src = circshift(im_shift_src,[0,-1]);
    im_shift_dst = circshift(im_shift_dst,[0,-1]);

    im_shift_src = im_shift_src(:,2:end,:);
    im_shift_dst = im_shift_dst(:,2:end,:);
    
    
    M_right = sum(abs(im_src_warp - im_dst_warp), 3) + sum(abs(im_shift_src - im_shift_dst), 3);

    im_shift_src = padarray(im_src_warp,[0,1],'post');
    im_shift_dst = padarray(im_dst_warp,[0,1],'post');

    im_shift_src = circshift(im_shift_src,[0,1]);
    im_shift_dst = circshift(im_shift_dst,[0,1]);

    im_shift_src = im_shift_src(:,1:end-1,:);
    im_shift_dst = im_shift_dst(:,1:end-1,:);
    
    M_left = sum(abs(im_src_warp - im_dst_warp), 3) + sum(abs(im_shift_src - im_shift_dst), 3);

    im_shift_src = padarray(im_src_warp,[1,0],'pre');
    im_shift_dst = padarray(im_dst_warp,[1,0],'pre');

    im_shift_src = circshift(im_shift_src,[-1,0]);
    im_shift_dst = circshift(im_shift_dst,[-1,0]);

    im_shift_src = im_shift_src(2:end,:,:);
    im_shift_dst = im_shift_dst(2:end,:,:);

    M_down = sum(abs(im_src_warp - im_dst_warp), 3) + sum(abs(im_shift_src - im_shift_dst), 3);

    im_shift_src = padarray(im_src_warp,[1,0],'post');
    im_shift_dst = padarray(im_dst_warp,[1,0],'post');

    im_shift_src = circshift(im_shift_src,[1,0]);
    im_shift_dst = circshift(im_shift_dst,[1,0]);

    im_shift_src = im_shift_src(1:end-1,:,:);
    im_shift_dst = im_shift_dst(1:end-1,:,:);

    M_up = sum(abs(im_src_warp - im_dst_warp), 3) + sum(abs(im_shift_src - im_shift_dst), 3);


    [M,N,~] = size(im_dst_warp);

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
            
            if n ~= 0 && mod(n,M) ~= 0
                T_cnt = T_cnt + 1;
                T_row(T_cnt) = n;
                T_col(T_cnt) = v;
            end
            %down
            n = i + 1;
            if n <= pixel_num && mod(n,M) ~= 1
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
            if n <= pixel_num
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
            if n > 0 && mod(n,M) ~= 0 && mask(n) == 1
                n_count = n_count + 1;
                A_cnt = A_cnt + 1;
                A_row(A_cnt) = i;
                A_col(A_cnt) = n;
                A_val(A_cnt) = M_up(n);
            else
                %continue;
            end
            %down
            n = i + 1;
            if n<= pixel_num && mod(n,M) ~= 1 && mask(n) == 1
                n_count = n_count + 1;
                A_cnt = A_cnt + 1;
                A_row(A_cnt) = i;
                A_col(A_cnt) = n;
                A_val(A_cnt) = M_down(n);
            else
                %A_cnt = A_cnt - n_count;
                %continue;
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
                %A_cnt = A_cnt - n_count;
                %continue;
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
                %A_cnt = A_cnt - n_count;
                %continue;
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
    %{
    bd = bwboundaries(labels);
    imshow(imfuse(uint8(im_dst_warp), mask));
    hold on;
    for k = 1:1
        boundary = bd{k};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
    end
    hold off;
    %}
end