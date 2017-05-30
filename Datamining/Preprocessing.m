clc;
clear;

%% Pre Processing for Small Data

% rawdata = readtable('AmericaStateHospitalRawData.csv');
% clc;
% processesed_data = rawdata;
% processesed_data(:,3) = [];
% processesed_data(:,3) = [];
% processesed_data(:,4) = [];
% 
% xx = processesed_data.State;
% states = unique(xx,'stable');
% 
% number_of_questions= cellfun(@(x) sum(ismember(xx,x)), states,'un',0);
% number_of_questions = number_of_questions{1};
% 
% % Edit Headings
% questions = processesed_data.HCAHPSQuestion(1:number_of_questions)';
% questions = replace(questions,'Patients who reported that ','');
% questions = replace(questions,'Patients who ','');
% questions = replace(questions,' before giving it to them','');
% questions = replace(questions,' ','_');
% questions = replace(questions,'"','');
% questions = replace(questions,',','');
% questions = replace(questions,'“','');
% questions = replace(questions,'”','');
% questions = replace(questions,'_about','');
% questions = replace(questions,'_they_were_not_given','');
% questions = replace(questions,'_they_were_given','');
% questions = replace(questions,'_the_hospital','');
% questions = replace(questions,'_when_they_left','');
% questions = replace(questions,'on_a_scale_from_0_(lowest)_to_10_(highest)','');
% questions = replace(questions,'the_area_around_','');
% 
% 
% 
% % Make a table of answers with questions as headings
% answers_row = processesed_data(1 + number_of_questions - number_of_questions:number_of_questions,3);
% answers_row = table2array(answers_row);
% answers = array2table(answers_row.');
% for i = 2:size(states,1)
%     answers_row = processesed_data(1 + i*number_of_questions - number_of_questions:i*number_of_questions,3);
%     answers_row = table2array(answers_row);
%     answers_row = array2table(answers_row.');
%     answers = [answers;answers_row];
% end
% answers.Properties.VariableNames = questions;
% 
% % Create New Table 
% answers.States = states;
% new_table = answers (:,[end 1:end-1]);


%% Pre Processing for Large Data
rawdata = readtable('AllAmericaHospitalRawData.csv');
clc;
processesed_data = rawdata;
processesed_data(:,[1,3,4,6,7,8,10,11,13,15,18,20,21,22]) = [];

indices = find(processesed_data(:,2)=='Not Available');

processesed_data(indices,:) = [];
 


xx = processesed_data.HospitalName;
hospital_names = unique(xx,'stable');

array = table2array(processesed_data);
array = replace(array,'Not Applicable','0');

a = array(:,4:6);
a = cell_


