function [resha_feature,resha_filter,resha_conv] = reshape_8b(featuremap_8b,fmapfilter_8b,conv8b) 
N=8;
[fmapH,fmapW,fmapC] = size(featuremap_8b);
[filterH,filterW,filterC,filterK] = size(fmapfilter_8b);
[convH,convW,convC] = size(conv8b);

%  Reshape the input featuremap by CHW.
fmap_matrix_temp = int8(zeros(fmapH*fmapW*fmapC,1));
for j=1:fmapW
        for k=1:fmapH
            fmap_temp = featuremap_8b(k,j,:);
            fmap_temp1 = fmap_temp(:);
            fmap_matrix_temp((((k-1)*fmapC+1)+(j-1)*fmapC*fmapH):(k*fmapC+(j-1)*fmapC*fmapH)) = fmap_temp1;
        end
end
% Transform the scale int4 to bin
filter_matrix_temp = int8(zeros(filterH*filterW*filterC,filterK));
for i=1:filterK
    for j=1:filterW
        for k=1:filterH
            filter_temp = fmapfilter_8b(k,j,:,i);
            filter_temp1 = filter_temp(:);
            filter_matrix_temp((((k-1)*filterC+1)+(j-1)*filterC*filterH):(k*filterC+(j-1)*filterC*filterH),i) = filter_temp1;
        end
    end
end

filter_matrix_temp2 = int8(zeros(16*64/N,(filterK/16)*(filterH*filterW*filterC/(64/N))));
    for j = 1:filterK/16
        for i = 1:filterH*filterW*filterC/(64/N)
           temp1 = filter_matrix_temp(((i-1)*(64/N)+1):(i*(64/N)),((j-1)*16+1):(j*16));
           temp2 = temp1(:);
           filter_matrix_temp2(:,(filterH*filterW*filterC/(64/N))*(j-1)+i) = temp2;
        end
    end
filter_matrix_temp3 = filter_matrix_temp2(:);

conv_matrix_temp = int32(zeros(convH*convW*convC,1));
for j=1:convW
        for k=1:convH
            conv_temp = conv8b(k,j,:);
            conv_temp1 = conv_temp(:);
            conv_matrix_temp((((k-1)*convC+1)+(j-1)*convC*convH):(k*convC+(j-1)*convC*convH)) = conv_temp1;
        end
end

resha_feature = fmap_matrix_temp;
resha_filter = filter_matrix_temp3;
resha_conv = conv_matrix_temp;
end
