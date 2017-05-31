clc
clear

file_name = 'bank-full.csv';

% PreProcessing Step
processed_data = Preprocessing(file_name);
clustered_data = Clustering(processed_data);


function processed_data = Preprocessing(file_name)
    %Try to open file
    try
        raw_data = readtable(file_name);
        
    catch ME
        disp(ME.message)
        disp('Make sure the file in the same folder as this code :)')
        processed_data = [];
        return
    end
    
    % Deleate Row: Days beacuse the day in terms of 1 - 365 seems
    % irrelvant
    % Deleate Rows: pdays, previous, poutcome because of too much missing data
    raw_data(:,[10,14:16]) = [];
    
    % Remove Rows with unknown data
    processed_data = standardizeMissing(raw_data,'unknown');
    processed_data = rmmissing(processed_data);
    
    % Make Final collumn logical (1: Yes, 0: No)
    processed_data.y = strcmpi(processed_data.y, 'yes');
    
    % --AGE--
    % 1: Young (0 - 34), 2: Middle Age (35 - 55) , 3: 55+
    processed_data.age( processed_data.age < 35 ) = 1;
    processed_data.age( 35 <= processed_data.age & processed_data.age < 55 ) = 2;
    processed_data.age( processed_data.age >= 55 ) = 3;
    
    % --BALANCE-- 
    % 1: Balance under 0, 2: Balance 0 - $1499, 3: Balance $1500+
    processed_data.balance( 0 <= processed_data.balance & processed_data.balance < 1499 ) = 2;
    processed_data.balance( processed_data.balance < 0 ) = 1;
    processed_data.balance( processed_data.balance >= 1500 ) = 3;
    
    % --DURATION(CAll)-- 
    % 1: Less than 2 mins, 2: Between 2 - 5 mins, 3: More than 5 mins 
    processed_data.duration( processed_data.duration <= 120) = 1;
    processed_data.duration( processed_data.duration > 120 & processed_data.duration <= 300 ) = 2;
    processed_data.duration( processed_data.duration > 300 ) = 3;
    
    % --CAMPAIN(Number of Calls)-- 
    % 1: One, 2: Between 2 - 10 , 3: More than 10
    processed_data.campaign( processed_data.campaign <= 1) = 1;
    processed_data.campaign( processed_data.campaign > 1 & processed_data.campaign <= 10 ) = 2;
    processed_data.campaign( processed_data.campaign > 10 ) = 3;
    
    
end

function clustered_data =  Clustering(table)
    vars_names = table.Properties.VariableNames;
    length_table = width(table);
    height_table = height(table);
    vars_names(end) = [];
    
    
    
    % Create array of category data
    var_array = {};
    total_percent_array = [];
    for i = (1:length_table-1)
        % Create Unique Table 
        categories = table2array(unique(table(:,i)));
        percent_array = [];
        categories_array = {};
        for j = (1:size(categories))
            var = table2array(table(:,i));
            category = categories(j);
            category = [category];
            if iscell(category)
                category = string(category);
            end
                        
            is_catagory = eq(var, category);
            amount_cat = sum(is_catagory);
            amount_incorrect = sum(and(is_catagory, ~table.y));      
            percent = amount_incorrect/amount_cat;
            categories_sub_array = [category, amount_cat, amount_incorrect];
            categories_array = [categories_array, categories_sub_array];
            percent_array = [percent_array, percent];
        end
        total_percent_array = [total_percent_array, [percent_array]];
        var_array = [var_array, {categories_array}];
    end
    
       clustered_data = var_array;
    
end