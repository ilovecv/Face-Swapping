
TargImPasteR = double(TargIm(:, :, 1));
TargImPasteG = double(TargIm(:, :, 2));
TargImPasteB = double(TargIm(:, :, 3));

%Calulating divergance of Guiding vectors: div((Gx,Gy))=Laplacian(G)
h = [0 -1 0; -1 4 -1; 0 -1 0];
LaplacianSource = imfilter(double(SourceIm), h, 'replicate');
VR = LaplacianSource(:, :, 1);
VG = LaplacianSource(:, :, 2);
VB = LaplacianSource(:, :, 3);

%Place div guidance vector into Target image
TargImPasteR(logical(MaskTarg(:))) = VR(SourceMask(:));
TargImPasteG(logical(MaskTarg(:))) = VG(SourceMask(:));
TargImPasteB(logical(MaskTarg(:))) = VB(SourceMask(:));

TargImPaste = cat(3, TargImPasteR, TargImPasteG, TargImPasteB);


%% paste Laplacian of source into Target image
[MaskTarg, TargImPaste] = paste_source_into_targ(SourceIm, TargIm, SourceMask, shift_in_target_image);

%% Solve POisson equations in target image wihtihn masked area
TargFilled = PoissonColorImEditor(TargImPaste, MaskTarg);
