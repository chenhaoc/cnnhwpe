function [resha_feature,resha_filter,resha_conv] = reshape_4b(featuremap_4b,fmapfilter_4b,conv4b) 
% Combine the 4b parameters to 8b. In order to use 'fwrite' to write the
% data into .bin file.
%   Generate the size of input feature, filter and convolution results.
[fmapH,fmapW,fmapC] = size(featuremap_4b);
[filterH,filterW,filterC,filterK] = size(fmapfilter_4b);
[convH,convW,convC] = size(conv4b);
N = 4;
%  Reshape the input featuremap by CHW.
fmap_matrix_temp = int8(zeros(fmapH*fmapW*fmapC,1));
for j=1:fmapW
        for k=1:fmapH
            fmap_temp = featuremap_4b(k,j,:);
            fmap_temp1 = fmap_temp(:);
            fmap_matrix_temp((((k-1)*fmapC+1)+(j-1)*fmapC*fmapH):(k*fmapC+(j-1)*fmapC*fmapH)) = fmap_temp1;
            a = (((k-1)*fmapC+1)+(j-1)*fmapC*fmapH);
            b = (k*fmapC+(j-1)*fmapC*fmapH);
        end
end
% Transform the scale int4 to bin
[length_fmap,~] = size(fmap_matrix_temp);
fmap_matrix_temp2 = int8(zeros(length_fmap,1));
for i=1:length_fmap
    switch (fmap_matrix_temp(i,1))
        case -64
          fmap_matrix_temp2(i,1) = 15;  
        case -32
          fmap_matrix_temp2(i,1) = 14;
        case -16
          fmap_matrix_temp2(i,1) = 13;  
        case -8
          fmap_matrix_temp2(i,1) = 12;
        case -4
          fmap_matrix_temp2(i,1) = 11;  
        case -2
          fmap_matrix_temp2(i,1) = 10;
        case -1
          fmap_matrix_temp2(i,1) = 9;  
        case 0
          fmap_matrix_temp2(i,1) = 0;
        case 1
          fmap_matrix_temp2(i,1) = 1;  
        case 2
          fmap_matrix_temp2(i,1) = 2;
        case 4
          fmap_matrix_temp2(i,1) = 3;  
        case 8
          fmap_matrix_temp2(i,1) = 4;
        case 16
          fmap_matrix_temp2(i,1) = 5;  
        case 32
          fmap_matrix_temp2(i,1) = 6;
        case 64
          fmap_matrix_temp2(i,1) = 7;  
        otherwise
          fmap_matrix_temp2(i,1) = fmap_matrix_temp2(i,1);
    end
end

 fmap_matrix_temp3 = uint8(zeros(length_fmap/(8/N),1));
for i = 1:length_fmap/(8/N)
    str1 = dec2bin(fmap_matrix_temp2(2*i-1,1),4);
    str2 = dec2bin(fmap_matrix_temp2(2*i,1),4);
    str3 = strcat(str2,str1);
    fmap_matrix_temp3(i,1) = uint8(bin2dec(str3));
end

%   Reshape the filter by CHW.
filter_matrix_temp = int8(zeros(filterH*filterW*filterC,filterK));
for i=1:filterK
    for j=1:filterW
        for k=1:filterH
            filter_temp = fmapfilter_4b(k,j,:,i);
            filter_temp1 = filter_temp(:);
            filter_matrix_temp((((k-1)*filterC+1)+(j-1)*filterC*filterH):(k*filterC+(j-1)*filterC*filterH),i) = filter_temp1;
            a1 = (((k-1)*filterC+1)+(j-1)*filterC*filterH);
            b1 = (k*filterC+(j-1)*filterC*filterH);
        end
    end
end
[length_filter,width_filter] = size(filter_matrix_temp);
filter_matrix_temp2 = int8(zeros(filterH*filterW*filterC,filterK));
for i=1:length_filter
    for j = 1:width_filter
    switch (filter_matrix_temp(i,j))
        case -64
          filter_matrix_temp2(i,j) = 15;  
        case -32
          filter_matrix_temp2(i,j) = 14;
        case -16
          filter_matrix_temp2(i,j) = 13;  
        case -8
          filter_matrix_temp2(i,j) = 12;
        case -4
          filter_matrix_temp2(i,j) = 11;  
        case -2
          filter_matrix_temp2(i,j) = 10;
        case -1
          filter_matrix_temp2(i,j) = 9;  
        case 0
          filter_matrix_temp2(i,j) = 0;
        case 1
          filter_matrix_temp2(i,j) = 1;  
        case 2
          filter_matrix_temp2(i,j) = 2;
        case 4
          filter_matrix_temp2(i,j) = 3;  
        case 8
          filter_matrix_temp2(i,j) = 4;
        case 16
          filter_matrix_temp2(i,j) = 5;  
        case 32
          filter_matrix_temp2(i,j) = 6;
        case 64
          filter_matrix_temp2(i,j) = 7;  
        otherwise
          filter_matrix_temp2(i,j) = filter_matrix_temp2(i,j);
    end
    end
end
filter_matrix_temp3 = int8(zeros(16*64/N,(filterK/16)*(filterH*filterW*filterC/(64/N))));
    for j = 1:filterK/16
        for i = 1:filterH*filterW*filterC/(64/N)
           temp1 = filter_matrix_temp2(((i-1)*(64/N)+1):(i*(64/N)),((j-1)*16+1):(j*16));
           temp2 = temp1(:);
           filter_matrix_temp3(:,(filterH*filterW*filterC/(64/N))*(j-1)+i) = temp2;
        end
    end
filter_matrix_temp4 = filter_matrix_temp3(:);
[length_filter_temp,~] = size(filter_matrix_temp4);
filter_matrix_temp5 = uint8(zeros(length_filter_temp/(8/N),1));
for i = 1:length_filter_temp/(8/N)
    str1 = dec2bin(filter_matrix_temp4(2*i-1,1),4);
    str2 = dec2bin(filter_matrix_temp4(2*i,1),4);
    str3 = strcat(str2,str1);
    filter_matrix_temp5(i,1) = uint8(bin2dec(str3));
end

conv_matrix_temp = int32(zeros(convH*convW*convC,1));
for j=1:convW
        for k=1:convH
            conv_temp = conv4b(k,j,:);
            conv_temp1 = conv_temp(:);
            conv_matrix_temp((((k-1)*convC+1)+(j-1)*convC*convH):(k*convC+(j-1)*convC*convH)) = conv_temp1;
            a = (((k-1)*convC+1)+(j-1)*convC*convH);
            b = (k*convC+(j-1)*convC*convH);
        end
end
conv_matrix_temp = conv_matrix_temp(:);

resha_feature = fmap_matrix_temp3;
resha_filter = filter_matrix_temp5;
resha_conv = conv_matrix_temp;
end

