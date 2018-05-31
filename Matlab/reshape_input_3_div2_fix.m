function [resha_inputimage,resha_filter,resha_conv] = reshape_input_3_div2_fix(inputimage,inputfilter,conv,stride) 
% reshape the input image into the type for HWPE
% for kernel size 3x3x3
N=8;
%Get the size of input image,filter and convolution result
[fmapH,fmapW,fmapC] = size(inputimage);
[filterH,filterW,filterC,filterK] = size(inputfilter);
[convH,convW,convC] = size(conv);
%Divide the input image into two parts,up and down
up = (ceil(convH/2)-1)*stride + filterH;
down = fmapH -(((convH-ceil(convH/2))-1)*stride + filterH)+1;
overlapH = up-1-(fmapH-down);
inputimage_3_up = inputimage(1:up,:,:);
inputimage_3_down = inputimage(down:fmapH,:,:);
if (overlapH ~= 0)
 inputimage_3_down = [inputimage_3_down,int8(zeros(overlapH,fmapW,fmapC))];
end
[fmapH_up,fmapW_up,fmapC_up] = size(inputimage_3_up);
[fmapH_down,fmapW_down,fmapC_down] = size(inputimage_3_down);
left = (ceil(convW/2)-1)*stride + filterW;
right = fmapW -(((convW-ceil(convW/2))-1)*stride + filterW)+1;
overlapW = left-1-(fmapW-right);
inputimage_3_1 = inputimage_3_up(:,1:left,:);
inputimage_3_2 = inputimage_3_up(:,right:fmapW,:);
inputimage_3_3 = inputimage_3_down(:,1:left,:);
inputimage_3_4 = inputimage_3_down(:,right:fmapW,:);
if (overlapW ~= 0)
  inputimage_3_2 = [inputimage_3_2,int8(zeros(fmapH_down,overlapW,fmapC_down))];
  inputimage_3_4 = [inputimage_3_4,int8(zeros(fmapH_down,overlapW,fmapC_down))];
end
%Get the size of input image(up and down)
[fmapH_1,fmapW_1,fmapC_1] = size(inputimage_3_1);
[fmapH_2,fmapW_2,fmapC_2] = size(inputimage_3_2);
[fmapH_3,fmapW_3,fmapC_3] = size(inputimage_3_3);
[fmapH_4,fmapW_4,fmapC_4] = size(inputimage_3_4);

%reshape the up and down parts into the arrangement of CHW
fmap_matrix_temp_1 = int8(zeros(fmapC_1,fmapH_1*fmapW_1));
fmap_matrix_temp_2 = int8(zeros(fmapC_2,fmapH_2*fmapW_2));
fmap_matrix_temp_3 = int8(zeros(fmapC_3,fmapH_3*fmapW_3));
fmap_matrix_temp_4 = int8(zeros(fmapC_4,fmapH_4*fmapW_4));
for j=1:fmapW_1
        for k=1:fmapH_1
            fmap_temp_1 = inputimage_3_1(k,j,:);
            fmap_temp1_1 = fmap_temp_1(:);
            fmap_matrix_temp_1(:,k+(j-1)*fmapH_up) = fmap_temp1_1;
        end
end
for j=1:fmapW_2
        for k=1:fmapH_2
            fmap_temp_2 = inputimage_3_2(k,j,:);
            fmap_temp1_2 = fmap_temp_2(:);
            fmap_matrix_temp_2(:,k+(j-1)*fmapH_up) = fmap_temp1_2;
        end
end
for j=1:fmapW_3
        for k=1:fmapH_3
            fmap_temp_3 = inputimage_3_3(k,j,:);
            fmap_temp1_3 = fmap_temp_3(:);
            fmap_matrix_temp_3(:,k+(j-1)*fmapH_up) = fmap_temp1_3;
        end
end
for j=1:fmapW_4
        for k=1:fmapH_4
            fmap_temp_4 = inputimage_3_4(k,j,:);
            fmap_temp1_4 = fmap_temp_4(:);
            fmap_matrix_temp_4(:,k+(j-1)*fmapH_up) = fmap_temp1_4;
        end
end
% Join the up and down parts together in C dimension,1 by 1
fmap_matrix_temp_left_join = int8(zeros(fmapC_1,fmapH_1*fmapW_1+fmapH_3*fmapW_3));
for i=1:fmapH_1*fmapW_1
    fmap_matrix_temp_left_join(:,2*i-1) = fmap_matrix_temp_1(:,i);
    fmap_matrix_temp_left_join(:,2*i) = fmap_matrix_temp_3(:,i); 
end
fmap_matrix_temp_right_join = int8(zeros(fmapC_2,fmapH_2*fmapW_2+fmapH_4*fmapW_4));
for i=1:fmapH_1*fmapW_1
    fmap_matrix_temp_right_join(:,2*i-1) = fmap_matrix_temp_2(:,i);
    fmap_matrix_temp_right_join(:,2*i) = fmap_matrix_temp_4(:,i); 
end
% Mix the up and down parts together in C dimension,1 by 1
fmap_matrix_temp_left_mix = int8(zeros(2*fmapC_1,fmapH_1*fmapW_1));
for i=1:fmapH_1*fmapW_1
    temp = fmap_matrix_temp_left_join(:,(2*i-1):2*i);
    temp2 = temp';
    fmap_matrix_temp_left_mix(:,i) = temp2(:);
end
fmap_matrix_temp_right_mix = int8(zeros(2*fmapC_2,fmapH_2*fmapW_2));
for i=1:fmapH_2*fmapW_2
    temp = fmap_matrix_temp_right_join(:,(2*i-1):2*i);
    temp2 = temp';
    fmap_matrix_temp_right_mix(:,i) = temp2(:);
end
final_left = fmap_matrix_temp_left_mix(:);
final_right = fmap_matrix_temp_right_mix(:);
fmap_matrix_temp_div2 = [final_left;final_right];
% reshape the filter into the arrangement of CHW
filter_matrix_temp = int8(zeros(filterH*filterC*filterW,filterK));
for i=1:filterK
    for j=1:filterW
        for k=1:filterH
            filter_temp = inputfilter(k,j,:,i);
            filter_temp1 = filter_temp(:);
            filter_matrix_temp((((k-1)*filterC+1)+(j-1)*filterC*filterH):(k*filterC+(j-1)*filterC*filterH),i) = filter_temp1;
        end
    end
end
%Pading the filter tensor with 0
filter_matrix_temp2 =[filter_matrix_temp(1:22,:);(int8(zeros(2,filterK)));filter_matrix_temp(23:27,:);(int8(zeros(3,filterK)))];
[zeropadH,zeropadK] = size(filter_matrix_temp2);

%64bit splice
filter_matrix_temp4 = int8(zeros(16*64/N,(zeropadK/16)*(zeropadH/(64/N))));
    for j = 1:zeropadK/16
        for i = 1:zeropadH/(64/N)
           temp1 = filter_matrix_temp2(((i-1)*(64/N)+1):(i*(64/N)),((j-1)*16+1):(j*16));
           temp2 = temp1(:);
           filter_matrix_temp4(:,(zeropadH/(64/N))*(j-1)+i) = temp2;
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

conv_matrix_temp = conv_matrix_temp(:);
resha_inputimage = fmap_matrix_temp_div2;
resha_filter = filter_matrix_temp5;
resha_conv = conv_matrix_temp;
end

