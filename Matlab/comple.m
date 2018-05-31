function [ output_vector ] = comple( input_vector,N )
%Generate the bin for minus integer
 [length,~] = size(input_vector);
 input_vector = double(input_vector);
 output_vector = zeros(length,1);
for i = 1:length
    if (input_vector(i,1) >=0)
        output_vector(i,1) = input_vector(i,1);
    else
        output_vector(i,1) = 2^N + input_vector(i,1);
    end   
end
end