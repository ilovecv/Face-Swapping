function replaceImage = changeLumination(oriImage, replaceImage)
    oriLumMap = 0.2125 * oriImage(:,:,1) + 0.7154 * oriImage(:,:,2) + 0.0721 * oriImage(:,:,3);
    repLumMap = 0.2125 * replaceImage(:,:,1) + 0.7154 * replaceImage(:,:,2) + 0.0721 * replaceImage(:,:,3);
    
    oriAveLum = calcAveLum(oriLumMap);
    repAveLum = calcAveLum(repLumMap);
    
    replaceImage = updateImage(replaceImage, oriAveLum, repAveLum);
end

function aveLum = calcAveLum(lumMap)
    height = size(lumMap, 1);
    width = size(lumMap, 2);
    sumAll = 0;
    sumWhite = 0;
    sumBlack = 0;
    countWhite = 0;
    countBlack = 0;
    for i = 1 : height
        for j = 1 : width
            sumAll = sumAll + double(lumMap(i, j));
%             if(lumMap(i, j) > 60)
%                 sumWhite = sumWhite + double(lumMap(i, j));
%                 countWhite = countWhite + 1;
%             end
            if(lumMap(i, j) == 0)
                sumBlack = sumBlack + double(lumMap(i, j));
                countBlack = countBlack + 1;
            end
        end
    end

    aveLum = (sumAll - sumWhite - sumBlack) / (height * width - countWhite - countBlack);
end

function replaceImage = updateImage(replaceImage, oriLum, replaceLum)
    height = size(replaceImage, 1);
    width = size(replaceImage, 2);
    for i = 1 : height
        for j = 1 : width
                for k = 1 : 3
                    replaceImage(i, j, k) = double(replaceImage(i, j, k)) * double(oriLum) / double(replaceLum);
                    if(replaceImage(i, j, k) > 255)
                        replaceImage(i, j, k) = 255;
                    end
                end
        end
    end
    replaceImage = uint8(replaceImage);
end