clc
clear

file_name = 'weather_nominal2.csv';

% PreProcessing Step
processed_data = Preprocessing(file_name);


% Classifying Step
classifed_data = ClassifyData(processed_data);

% Testing Step
results = TestingWithTable(processed_data, classifed_data);


function processed_data = Preprocessing(file_name)
    %Try to open file
    processed_data = readtable(file_name);
    
        
            
    end

function var_map  =  ClassifyData(table)
    vars_names = table.Properties.VariableNames;
    length_table = width(table);
    
    vars_names(end) = [];
    
    amount_of_data = height(table);
    total_win = sum(table.PlayGolf);
    total_lose = sum(~table.PlayGolf);
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
            
            amount_correct = sum(and(is_catagory, table.PlayGolf));
            amount_incorrect = sum(and(is_catagory, ~table.PlayGolf));
                             
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



function results = TestingWithTable(testing_data, classifed_data)
    num_of_data = height(testing_data);
    true_positive = 0;
    false_positive = 0;
    true_negitive = 0;
    false_negitive = 0;
    chance = 0;
    for i = (1:num_of_data)
        testing_row = testing_data(i,:);
        chance = TestOneRow(testing_row, classifed_data);
        if testing_row.PlayGolf
            if (chance >= .50)
                true_positive = true_positive + 1;                
            else
                false_negitive = false_negitive + 1;
            end
        else
            if (chance < .50)
                true_negitive = true_negitive + 1;                
            else
                false_positive = false_positive + 1;
            end
            
            
            
        end
        
    end
    disp([true_positive, false_positive])
    disp([false_negitive, true_negitive])
        
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
