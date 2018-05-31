function [resha_inputimage,resha_filter,resha_conv] = reshape_input_except3_fix(inputimage,inputfilter,conv,stride) 
% reshape the input image into the type for HWPE
% for kernel size except 3x3x3
N=8;
%  Reshape the input featuremap by CHW.
[fmapH,fmapW,fmapC] = size(inputimage);
[filterH,filterW,filterC,filterK] = size(inputfilter);
[convH,convW,convC] = size(conv);
left = (ceil(convW/2)-1)*stride + filterW;
right = fmapW -(((convW-ceil(convW/2))-1)*stride + filterW)+1;
overlap = left-1-(fmapW-right);
fmap_matrix_left = inputimage(:,1:left,:);
fmap_matrix_right = inputimage(:,right:fmapW,:);

if (overlap ~= 0)
  fmap_matrix_right = [fmap_matrix_right,int8(zeros(fmapH,overlap,fmapC))];
end

fmap_matrix_temp_left = int8(zeros(fmapH*left*fmapC,1));
for j=1:left
        for k=1:fmapH
            fmap_temp = fmap_matrix_left(k,j,:);
            fmap_temp1 = fmap_temp(:);
            fmap_matrix_temp_left((((k-1)*fmapC+1)+(j-1)*fmapC*fmapH):(k*fmapC+(j-1)*fmapC*fmapH)) = fmap_temp1;
        end
end
fmap_matrix_temp_right = int8(zeros(fmapH*left*fmapC,1));
for j=1:left
        for k=1:fmapH
            fmap_temp = fmap_matrix_right(k,j,:);
            fmap_temp1 = fmap_temp(:);
            fmap_matrix_temp_right((((k-1)*fmapC+1)+(j-1)*fmapC*fmapH):(k*fmapC+(j-1)*fmapC*fmapH)) = fmap_temp1;
        end
end
fmap_matrix_temp_div2 = [fmap_matrix_temp_left;fmap_matrix_temp_right];
%   Reshape the filter by CHW.
filter_matrix_temp = int8(zeros(filterH*filterC,filterW,filterK));
for i=1:filterK
    for j=1:filterW
        for k=1:filterH
            filter_temp = inputfilter(k,j,:,i);
            filter_temp1 = filter_temp(:);
            filter_matrix_temp(((k-1)*filterC+1):(k*filterC),j,i) = filter_temp1;
        end
    end
end

pad_value = N - mod(filterW*filterC,N);

%padding 3D tensor with 0
filter_matrix_temp2 =[filter_matrix_temp;(int8(zeros(pad_value,filterW,filterK)))];
[zeropadH,zeropadW,zeropadK] = size(filter_matrix_temp2);
filter_matrix_temp3 = int8(zeros(zeropadH*zeropadW,zeropadK));
for i=1:zeropadK
    temp = filter_matrix_temp2(:,:,i);
    filter_matrix_temp3(:,i) = temp(:);
end
% combine to 64 bits
filter_matrix_temp4 = int8(zeros(16*64/N,(zeropadK/16)*(zeropadH*zeropadW/(64/N))));
    for j = 1:zeropadK/16
        for i = 1:zeropadH*zeropadW/(64/N)
           temp1 = filter_matrix_temp3(((i-1)*(64/N)+1):(i*(64/N)),((j-1)*16+1):(j*16));
           temp2 = temp1(:);
           filter_matrix_temp4(:,(zeropadH*zeropadW/(64/N))*(j-1)+i) = temp2;
        end
    end
filter_matrix_temp5 = filter_matrix_temp4(:);

conv_matrix_temp = int32(zeros(convH*convW*convC,1));
for j=1:convW
        for k=1:convH
            conv_temp = conv(k,j,:);
            conv_temp1 = conv_temp(:);
            conv_matrix_temp((((k-1)*convC+1)+(j-1)*convC*convH):(k*convC+(j-1)*convC*convH)) = conv_temp1;
        end
end

resha_inputimage = fmap_matrix_temp_div2;
resha_filter = filter_matrix_temp5;
resha_conv = conv_matrix_temp;
end

