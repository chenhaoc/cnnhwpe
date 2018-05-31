function [inputimage,inputfilter,conv] = case_gen_write_txt( inputH,inputW,inputC,...
                           filterH,filterW,filterC,filterK,...
                           stride,path1,path2,layer_type,data_type)
%CASE_GEN Summary of this function goes here
%   inputH,inputW,inputC are the size of input image or featuremap
%   filterH,filterW,filterC,filterK are the size of filter kernel
%   stride is stride of convolution
%   path1 is the master node of different cases in the samestride
%   path2 is different cases in the same stride
%   layer_type = 1 means the input is inputimage;layer_type = 0 means the input is featuremap
%   datatype is the datatype of parameters 1/2/3 for 2bits/4bits scale/8bits
%   the convH of output(convolution result) is a multiple of 4 
  judge = mod(((inputH - filterH)/stride + 1),4);
  if(judge == 0)
      switch(layer_type)
          case 0
              switch(data_type)
                  case 1 
                      load('ternary.mat');
                      inputimage = int8(ternary(randi(3,inputH,inputW,inputC)));
                      inputfilter = int8(ternary(randi(3,filterH,filterW,filterC,filterK)));
                      conv = int32(cnnConv(single(inputimage),single(inputfilter),[stride,stride]));
                      input_name = 'featuremap_2b';
                      filter_name = 'fmapfilter_2b';
                      conv_name = 'conv_2b';
                      head_name = 'inter_layer_2b';
                      mkdir([path1,'\',path2]);
                      input_path = [path1,'\',path2,'\',input_name,'.mat'];
                      filter_path = [path1,'\',path2,'\',filter_name,'.mat'];
                      conv_path = [path1,'\',path2,'\',conv_name,'.mat'];
                      save(input_path,'inputimage');
                      save(filter_path,'inputfilter');
                      save(conv_path,'conv');
                      inputfilter_333 = 0;
                      [resha_fmap_2b,resha_fmapfilter_2b,resha_conv_2b] = reshape_2b(inputimage,inputfilter,conv);
                      file_write_txt(inputH,inputW,...
                                 filterH,filterC,filterK,path1,...
                                 path2,data_type,layer_type,inputfilter_333,stride,...
                                 resha_fmap_2b,resha_fmapfilter_2b,resha_conv_2b,...
                                 input_name,filter_name,conv_name,head_name);
                  case 2
                      load('scaleint4.mat');
                      inputimage = int8(scaleint4(randi(15,inputH,inputW,inputC)));
                      inputfilter = int8(scaleint4(randi(15,filterH,filterW,filterC,filterK)));
                      conv = int32(cnnConv(single(inputimage),single(inputfilter),[stride,stride]));
                      input_name = 'featuremap_4b';
                      filter_name = 'fmapfilter_4b';
                      conv_name = 'conv_4b';
                      head_name = 'inter_layer_4b';
                      mkdir([path1,'\',path2]);
                      input_path = [path1,'\',path2,'\',input_name,'.mat'];
                      filter_path = [path1,'\',path2,'\',filter_name,'.mat'];
                      conv_path = [path1,'\',path2,'\',conv_name,'.mat'];
                      save(input_path,'inputimage');
                      save(filter_path,'inputfilter');
                      save(conv_path,'conv');
                      inputfilter_333 = 0;
                      [resha_fmap_4b,resha_fmapfilter_4b,resha_conv_4b] = reshape_4b(inputimage,inputfilter,conv);
                      file_write_txt(inputH,inputW,...
                                 filterH,filterC,filterK,path1,...
                                 path2,data_type,layer_type,inputfilter_333,stride,...
                                 resha_fmap_4b,resha_fmapfilter_4b,resha_conv_4b,...
                                 input_name,filter_name,conv_name,head_name);
                  case 3
                      inputimage = int8(randi([-128,127],inputH,inputW,inputC));
                      inputfilter = int8(randi([-128,127],filterH,filterW,filterC,filterK));
                      conv = int32(cnnConv(single(inputimage),single(inputfilter),[stride,stride]));
                      input_name = 'featuremap_8b';
                      filter_name = 'fmapfilter_8b';
                      conv_name = 'conv_8b';
                      head_name = 'inter_layer_8b';
                      mkdir([path1,'\',path2]);
                      input_path = [path1,'\',path2,'\',input_name,'.mat'];
                      filter_path = [path1,'\',path2,'\',filter_name,'.mat'];
                      conv_path = [path1,'\',path2,'\',conv_name,'.mat'];
                      save(input_path,'inputimage');
                      save(filter_path,'inputfilter');
                      save(conv_path,'conv');
                      inputfilter_333 = 0;
                      [resha_fmap_8b,resha_fmapfilter_8b,resha_conv_8b] = reshape_8b(inputimage,inputfilter,conv);
                      file_write_txt(inputH,inputW,...
                                 filterH,filterC,filterK,path1,...
                                 path2,data_type,layer_type,inputfilter_333,stride,...
                                 resha_fmap_8b,resha_fmapfilter_8b,resha_conv_8b,...
                                 input_name,filter_name,conv_name,head_name);
                  otherwise
                      disp('The input data tpye is wrong');
              end
          case 1
              if (inputC == 3)
                 inputimage = int8(randi([-128,127],inputH,inputW,inputC));
                 inputfilter = int8(randi([-128,127],filterH,filterW,filterC,filterK));
                 conv = int32(cnnConv(single(inputimage),single(inputfilter),[stride,stride]));
                 input_name = ['inputimage_', num2str(filterH)];
                 filter_name = ['inputfilter_', num2str(filterH)];
                 conv_name = ['conv_',  num2str(filterH)];
                 head_name = ['input_layer_', num2str(filterH),'_8b'];
                 mkdir([path1,'\',path2]);
                 input_path = [path1,'\',path2,'\',input_name,'.mat'];
                 filter_path = [path1,'\',path2,'\',filter_name,'.mat'];
                 conv_path = [path1,'\',path2,'\',conv_name,'.mat'];
                 save(input_path,'inputimage');
                 save(filter_path,'inputfilter');
                 save(conv_path,'conv');
                 if (filterH == 3)
                     inputfilter_333 = 1;
                     [resha_inputimage_3,resha_inputfilter_3,resha_conv_3] = reshape_input_3_div2_fix(inputimage,inputfilter,conv,stride);
                     file_write_txt(inputH,inputW,...
                                filterH,filterC,filterK,path1,...
                                path2,data_type,layer_type,inputfilter_333,stride,...
                                resha_inputimage_3,resha_inputfilter_3,resha_conv_3,...
                                input_name,filter_name,conv_name,head_name);
                 else
                     inputfilter_333 = 0;
                     [resha_inputimage,resha_inputfilter,resha_conv] = reshape_input_except3_fix(inputimage,inputfilter,conv,stride);
                     file_write_txt(inputH,inputW,...
                                filterH,filterC,filterK,path1,...
                                path2,data_type,layer_type,inputfilter_333,stride,...
                                resha_inputimage,resha_inputfilter,resha_conv,...
                                input_name,filter_name,conv_name,head_name);
                 end
              else
                  disp('The size of filterC is wrong');
              end
          otherwise
           disp('The input layer tpye is wrong');
      end         
  else
      disp(' The height or weight of output(convolution result) is not a multiple of 4');
  end

end

