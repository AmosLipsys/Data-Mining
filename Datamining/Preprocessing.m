clc;
clear;

rawdata = readtable('AmericaStateHospitalRawData.csv');
processesed_data = rawdata;
processesed_data(:,3) = [];
processesed_data(:,3) = [];
processesed_data(:,4) = [];



