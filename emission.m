clear;clc;
tic
current_path = fileparts(mfilename('fullpath'));% Get the folder path of the currently running script/function
path1=fullfile(current_path, 'province_interpolated.xlsx');
path2=fullfile(current_path, 'Supplementary information.xlsx');
[~,pn,~]=xlsread(path1,'low_scale','a2:a32');
IT_scale0=xlsread(path1,'low_scale','b2:b32');% 2023 MWh

IT_scale=repmat(IT_scale0,1,27);
low_scale0=xlsread(path1,'low_scale','d2:ad32');
medium_scale0=xlsread(path1,'medium_scale','d2:ad32');
high_scale0=xlsread(path1,'high_scale','d2:ad32');

low_scale=low_scale0.*IT_scale;% 24-50 MWh
medium_scale=medium_scale0.*IT_scale;
high_scale=high_scale0.*IT_scale;

low_PUE=xlsread(path1,'low_PUE','c2:ac32');% dimensionless
medium_PUE=xlsread(path1,'medium_PUE','c2:ac32');
high_PUE=xlsread(path1,'high_PUE','c2:ac32');

low_perf=xlsread(path1,'low_perf','c2:ac32');
medium_perf=xlsread(path1,'medium_perf','c2:ac32');
high_perf=xlsread(path1,'high_perf','c2:ac32');

scale=zeros(31,27,3);
pue=zeros(31,27,3);
perf=zeros(31,27,3);
scale(:,:,1)=low_scale;
scale(:,:,2)=medium_scale;
scale(:,:,3)=high_scale;

pue(:,:,1)=low_PUE;
pue(:,:,2)=medium_PUE;
pue(:,:,3)=high_PUE;

perf(:,:,1)=low_perf;
perf(:,:,2)=medium_perf;
perf(:,:,3)=high_perf;
% electricity consumption 24-50 scale*PUE/perf MWh
ec=zeros(31,27,3);% province year scenario
ec(:,:,1)=scale(:,:,1).*pue(:,:,3)./perf(:,:,3);
ec(:,:,2)=scale(:,:,2).*pue(:,:,2)./perf(:,:,2);
ec(:,:,3)=scale(:,:,3).*pue(:,:,1)./perf(:,:,1);
ec_n=squeeze(sum(ec,1))/10^6;
ec_n_y=sum(ec_n,1);
emissions_historical=xlsread(path2,'emissions_historical','b2:s32');
emissions_historical_n=sum(emissions_historical,1)/10^6;

intensity_con=xlsread(path2,'emission_intensities','t35:at65');
em_con=ec.*repmat(intensity_con,[1,1,3]);
em_con_n=squeeze(sum(em_con,1))/10^6;
em_con_f=zeros(28,3);
em_con_f(2:28,:)=em_con_n(1:27,:);
em_con_f(1,:)=repmat(emissions_historical_n(18),1,3);
em_con_p=squeeze(sum(em_con,2))/10^6;

year_his=xlsread(path2,'emissions_historical','b1:s1');
year_f=xlsread(path1,'low_scale','c1:ad1');

intensity_gen=xlsread(path2,'emission_intensities','t2:at32');% tCO2/MWh
em_gen=ec.*repmat(intensity_gen,[1,1,3]);
em_gen_n=squeeze(sum(em_gen,1))/10^6;%MtCO2
em_gen_f=zeros(28,3);
em_gen_f(2:28,:)=em_gen_n(1:27,:);
em_gen_f(1,:)=repmat(emissions_historical_n(18),1,3);
em_gen_p=squeeze(sum(em_gen,2))/10^6;

e_t=em_gen_f-em_con_f;% reduced cumulative emission during 24-50 by power transmission
e_t_s=sum(e_t,1);
e_t_p=em_gen_p-em_con_p;
xlswrite(path2,em_con(:,:,1),'emission_future','b2');
xlswrite(path2,em_con(:,:,2),'emission_future','b34');
xlswrite(path2,em_con(:,:,3),'emission_future','b66');

xlswrite(path2,em_gen(:,:,1),'emission_future','ae2');
xlswrite(path2,em_gen(:,:,2),'emission_future','ae34');
xlswrite(path2,em_gen(:,:,3),'emission_future','ae66');

