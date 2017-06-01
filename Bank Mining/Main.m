clc
clear

file_name = 'bank-full.csv';

% PreProcessing Step
processed_data = Preprocessing(file_name);

% Seperate Training and Testing Data
[training_data, testing_data] = SplitData(processed_data, percent_training);

% Classifying Step
classifed_data = ClassifyData(processed_data);

% Testing Step
results = TestingWithTable(testing_data, classifed_data);


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
    processed_data.balance( 0 <= processed_data.balance & processed_data.balance <= 1499 ) = 2;
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

function var_map  =  ClassifyData(table)
    vars_names = table.Properties.VariableNames;
    length_table = width(table);
    
    vars_names(end) = [];
    
    amount_of_data = height(table);
    total_win = sum(table.y);
    total_lose = sum(~table.y);
    probability_win = total_win/amount_of_data;
    probability_lose = total_lose/amount_of_data;
    
    % Create array of category data
    var_map = containers.Map;
    var_array = {};
    total_percent_array = [];
    for i = (1:length_table-1)
        % Create Unique Table 
        categories = table2array(unique(table(:,i)));
        categories_map = containers.Map;
        categories_array = {};
        for j = (1:size(categories))
            variable_array = table2array(table(:,i));
            category = categories(j);
            category = [category];
            if iscell(category)
                category = string(category);
            end
                        
            is_catagory = eq(variable_array, category);
            
            amount_correct = sum(and(is_catagory, table.y));
            amount_incorrect = sum(and(is_catagory, ~table.y));
                             
            probability_correct = amount_correct/total_win;
            probability_incorrect = amount_incorrect/total_lose;
            
            if isa(category, 'double')
                category = num2str(category);
            else
                category = char(category);
            end
            categories_map(category) = {probability_correct, probability_incorrect};
            categories_sub_array = [probability_correct, probability_incorrect];
            categories_array = [categories_array, categories_sub_array];
            
        end
        var_map(table.Properties.VariableNames{i}) = categories_map;
        var_array = [var_array, {categories_array}];
    end
    
    var_map('prob_win') = probability_win;
    var_map('prob_lose') = probability_lose;    
end

function [training, testing] = SplitData(processed_data, percent_training)
    training = processed_data;
    testing = processed_data;
    traing_size = int32(height(training)*percent_training);
            
    testing(1:traing_size,:) = [];
    training(traing_size:end,:) = [];
    
    
end

function results = TestingWithTable(testing_data, classifed_data)
    num_of_data = height(testing_data);
    correct = 0;
    for i = (1:num_of_data)
        testing_row = testing_data(i,:);
        chance = TestOneRow(testing_row, classifed_data);
        if testing_row.y == (chance >= .50)
            correct = correct + 1;
        end
        disp(correct / i) 
    end
    disp(correct / num_of_data)
        
    results = chance;  
end


function probility_of_success = TestOneRow(row, classifed_data)
    
    number_of_vars = width(row) - 1;
    prob_true = classifed_data('prob_win');
    prob_false = classifed_data('prob_lose');
    cat_prob_true = [];
    cat_prob_false = [];
    for i = (1:number_of_vars)
        string = table2array(row(1,i));
        if isa(string, 'double')
            string = num2str(string);
        else
            string = char(string);
        end
        
        
        category_map = classifed_data(row.Properties.VariableNames{i});
        try            
            cat_probs = category_map(string);
        catch ME
            cat_probs = {1, 1};
            disp(string)
            disp(row.Properties.VariableNames{i})
            disp(ME)
        end
           
        cat_prob_true = [cat_prob_true, cat_probs(1)];
        cat_prob_false = [cat_prob_false, cat_probs(2)];
        
    end
    likelyhood_win = prod(cell2mat(cat_prob_true)) * prob_true;
    likelyhood_lose = prod(cell2mat(cat_prob_false)) * prob_false;
    
    probility_of_success = likelyhood_win/(likelyhood_win + likelyhood_lose);
       
    
end
