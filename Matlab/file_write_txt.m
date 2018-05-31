function [ ] = file_write_txt(fmapH,fmapW,...
                          filterHW,filterC,filterK,path1,...
                          path2,data_type,layer_type,inputfilter_333,stride,...
                          resha_in,resha_filter,resha_conv,...
                          in_name,filter_name,conv_name,head_name)
%FILE_WRITE write reshaped parameters and convolution results

% context of the head file for C model
str1 = ['#define D_Kernel_size ',num2str(filterHW)];
str2 = ['#define D_Data_type ', num2str(data_type)];
str3 = ['#define D_Layer_type ', num2str(layer_type)];
str4 = ['#define D_Kernel_333 ',num2str(inputfilter_333)];
str5 = ['#define D_H ',num2str(fmapH)];
str6 = ['#define D_W ',num2str(fmapW)];
str7 = ['#define D_C ',num2str(filterC)];
str8 = ['#define D_K ',num2str(filterK)];
str9 = ['#define D_STRIDE ',num2str(stride)];
str10 = ['#define D_fmap_file_path ".\\',path1,'\\',path2,'\\',in_name,'.bin','"'];
str11 = ['#define D_kernel_file_path ".\\',path1,'\\',path2,'\\',filter_name,'.bin','"'];
str12 = ['#define D_conv_file_path ".\\',path1,'\\',path2,'\\',conv_name,'.bin','"'];

filename_hfile = fopen([path1,'\',path2,'\',head_name,'.h'],'wt');
fprintf(filename_hfile,'%s\n',str1,str2,str3,str4,str5,str6,str7,str8,str9,str10,str11,str12);

% context of the head file for RTL
str01 = ['`define D_Kernel_size ',num2str(filterHW)];
str02 = ['`define D_Data_type ', num2str(data_type)];
str03 = ['`define D_Layer_type ', num2str(layer_type)];
str04 = ['`define D_Kernel_333 ',num2str(inputfilter_333)];
str05 = ['`define D_H ',num2str(fmapH)];
str06 = ['`define D_W ',num2str(fmapW)];
str07 = ['`define D_C ',num2str(filterC)];
str08 = ['`define D_K ',num2str(filterK)];
str09 = ['`define D_STRIDE ',num2str(stride)];
str010 = ['`define D_fmap_file_path ".\\',path1,'\\',path2,'\\',in_name,'.bin','"'];
str011 = ['`define D_kernel_file_path ".\\',path1,'\\',path2,'\\',filter_name,'.bin','"'];
str012 = ['`define D_conv_file_path ".\\',path1,'\\',path2,'\\',conv_name,'.bin','"'];

filename_hfile = fopen([path1,'\',path2,'\',head_name,'.vh'],'wt');
fprintf(filename_hfile,'%s\n',str01,str02,str03,str04,str05,str06,str07,str08,str09,str010,str011,str012);

fclose(filename_hfile);
if (data_type == 3)
    filename_fmap = fopen([path1,'\',path2,'\',in_name,'.bin'],'w');
    fwrite(filename_fmap,resha_in,'int8');
    fclose(filename_fmap);
    filename_filter = fopen([path1,'\',path2,'\',filter_name,'.bin'],'w');
    fwrite(filename_filter,resha_filter,'int8');
    fclose(filename_filter);
    
    filename_fmap_txt = [path1,'\',path2,'\',in_name,'.txt'];
    resha_in2 = comple(resha_in,8);
    dlmwrite(filename_fmap_txt,resha_in2,'precision','%2x');
    filename_filter_txt = [path1,'\',path2,'\',filter_name,'.txt'];
    resha_filter2= comple(resha_filter,8);
    dlmwrite(filename_filter_txt,resha_filter2,'precision','%2x');
else
    filename_fmap = fopen([path1,'\',path2,'\',in_name,'.bin'],'w');
    fwrite(filename_fmap,resha_in,'uint8');
    fclose(filename_fmap);
    filename_filter = fopen([path1,'\',path2,'\',filter_name,'.bin'],'w');
    fwrite(filename_filter,resha_filter,'uint8');
    fclose(filename_filter);
    
    filename_fmap_txt = [path1,'\',path2,'\',in_name,'.txt'];
    resha_in2 = comple(resha_in,8);
    dlmwrite(filename_fmap_txt,resha_in2,'precision','%2x');
    filename_filter_txt = [path1,'\',path2,'\',filter_name,'.txt'];
    resha_filter2= comple(resha_filter,8);
    dlmwrite(filename_filter_txt,resha_filter2,'precision','%2x');
end

filename_conv = fopen([path1,'\',path2,'\',conv_name,'.bin'],'w');
fwrite(filename_conv,resha_conv,'int32');
fclose(filename_conv);

filename_conv_txt = [path1,'\',path2,'\',conv_name,'.txt'];
resha_conv2 = comple(resha_conv,32);
dlmwrite(filename_conv_txt,resha_conv2,'precision','%8x');
end

