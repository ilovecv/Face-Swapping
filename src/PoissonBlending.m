function[result] = PoissonBlending(im_src,im_dst, mask)
im_dst_lapr = double(im_dst(:, :, 1));
im_dst_lapg = double(im_dst(:, :, 2));
im_dst_lapb = double(im_dst(:, :, 3));

%Calulating divergance of Guiding vectors: div((Gx,Gy))=Laplacian(G)
h = [0 -1 0; -1 4 -1; 0 -1 0];
LaplacianSource = imfilter(double(im_src), h, 'replicate');
VR = LaplacianSource(:, :, 1);
VG = LaplacianSource(:, :, 2);
VB = LaplacianSource(:, :, 3);

%Place div guidance vector into Target image
im_dst_lapr(logical(mask(:))) = VR(logical(mask(:)));
im_dst_lapg(logical(mask(:))) = VG(logical(mask(:)));
im_dst_lapb(logical(mask(:))) = VB(logical(mask(:)));


AdjacencyMat = calcAdjancency( mask );
im_dst_boundary  = bwboundaries( mask, 8);

im_dst_fillr = PoissonGrayImEditor(im_dst_lapr, mask, AdjacencyMat, im_dst_boundary);
im_dst_fillg = PoissonGrayImEditor(im_dst_lapg, mask, AdjacencyMat, im_dst_boundary);
im_dst_fillb = PoissonGrayImEditor(im_dst_lapb, mask, AdjacencyMat, im_dst_boundary);

result = cat(3, im_dst_fillr, im_dst_fillg, im_dst_fillb);

end