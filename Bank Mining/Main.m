clc
clear

file_name = 'bank-full.csv';

processed_data = Preprocessing(file_name);
Clustering(processed_data)



function processed_data = Preprocessing(file_name)
    raw_data = readtable(file_name);
    raw_data(:,10) = [];
    
    processed_data = raw_data;
end

function Clustering(processed_data)
      
end