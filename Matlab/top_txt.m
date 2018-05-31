clear;
clc;

%CASE_GEN Summary of this function goes here
%   inputH,inputW,inputC are the size of input image or featuremap
%   filterH,filterW,filterC,filterK are the size of filter kernel
%   stride is stride of convolution
%   convH = (inputH - filterH)/stride + 1)
%   the convH of output(convolution result) is a multiple of 4 
%   For feature map,the size of C(channels) need to be a multiple of 8
%   path1 is the master node of different cases in the samestride
%   path2 is different cases in the same stride
%   layer_type = 1 means the input is inputimage;layer_type = 0 means the input is featuremap
%   datatype is the datatype of parameters 1/2/3 for 2bits/4bits scale/8bits

inputH = 10; 
inputW = 10;
inputC = 3;
filterH = 3;
filterW = 3; 
filterC = 3;
filterK = 32;
stride = 1;
path1 = 'case_gen_txt';
path2 = 'conv_input_3str1';
layer_type = 1;
data_type = 3;
[inputimage,inputfilter,conv] = case_gen_write_txt(inputH,inputW,inputC,...
                           filterH,filterW,filterC,filterK,...
                           stride,path1,path2,layer_type,data_type);