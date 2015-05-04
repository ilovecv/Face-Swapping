function replaceImage = changeColor(oriImage, replaceImage)

    [or, og, ob] = calcRGBAve(oriImage);
    oriAve = [or, og, ob];
    [rr, rg, rb] = calcRGBAve(replaceImage);
    repAve = [rr, rg, rb];
    
    replaceImage = updateImage(replaceImage, oriAve, repAve);
end

function ave = calcAverage(colorMap) 
    height = size(colorMap, 1);
    width = size(colorMap, 2);
    sumAll = 0;
    sumWhite = 0;
    sumBlack = 0;
    countWhite = 0;
    countBlack = 0;
    for i = 1 : height
        for j = 1 : width
            sumAll = sumAll + double(colorMap(i, j));
%             if(lumMap(i, j) > 60)
%                 sumWhite = sumWhite + double(lumMap(i, j));
%                 countWhite = countWhite + 1;
%             end
            if(colorMap(i, j) == 0)
                sumBlack = sumBlack + double(colorMap(i, j));
                countBlack = countBlack + 1;
            end
        end
    end

    ave = (sumAll - sumWhite - sumBlack) / (height * width - countWhite - countBlack);
end

function [r, g, b] = calcRGBAve(image) 
    r = calcAverage(image(:,:,1));
    g = calcAverage(image(:,:,2));
    b = calcAverage(image(:,:,3));
end

function replaceImage = updateImage(replaceImage, oriAve, repAve)
    height = size(replaceImage, 1);
    width = size(replaceImage, 2);
    for i = 1 : height
        for j = 1 : width
            for k = 1 : 3
                replaceImage(i, j, k) = double(replaceImage(i, j, k)) * double(oriAve(k)) / double(repAve(k));
                if(replaceImage(i, j, k) > 255)
                    replaceImage(i, j, k) = 255;
                end
            end
        end
    end
    replaceImage = uint8(replaceImage);
end