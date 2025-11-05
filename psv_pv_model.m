%%psv pv interactions model function
%author: Kaelan Lindup
%date initially created: 5th November 2025

%required inputs: patient number, pmus peak value, number of breaths
%optional inputs: struct ("pv_options") containing updated patient characteristics and
%ventilator settings
%outputs: modeled patient effort and ventilator settings as struct

function model_outputs = psv_pv_model(pat_num,pmus_peak,num_breaths,pv_options)

%load ip file
ip = readtable("ip_app.xlsx");

%Patient mechanics
R = ip.R(pat_num);
E = ip.E(pat_num);

%Ventilator settings
PEEP = ip.PEEP(pat_num);
ps_upper = ip.ps_upper(pat_num);
t_insp_rise = ip.t_insp_rise(pat_num);
q_cycle = ip.Q_cycle(pat_num);
triangle_paw_trig = ip.triangle_paw(pat_num);

%PV interaction relationships (fixed)
m_k = ip.m_k(pat_num);
int_k = ip.int_k(pat_num);
m_tau = ip.m_tau(pat_num);
int_tau = ip.int_tau(pat_num);
m_t_insp = ip.m_t_insp(pat_num);
int_t_insp = ip.int_t_insp(pat_num);

%overwrite nominal model parameters if provided by user
if nargin == 4
    %Patient mechanics
    R = pv_options.R;
    E = pv_options.E;
    
    %Ventilator settings
    PEEP = pv_options.PEEP;
    ps_upper = pv_options.ps_upper;
    t_insp_rise = pv_options.t_insp_rise;
    q_cycle = pv_options.q_cycle;
    triangle_paw_trig = pv_options.triangle_paw_trig;
end

%pmus general model
%load model
general_model = load("general_pmus_model\"+string(ip.file_general_model(pat_num)));
pmus_model = general_model.pmus_model;

shortest_breath = 150;
%scale magnitude and duration
pmus_model_scaled = pmus_peak*pmus_model;
Tinsp = m_t_insp*pmus_peak+int_t_insp; %+ median(T_onset);
stretch_factor = Tinsp/shortest_breath; %factor to stretch/compress effort
[P, Q] = rat(stretch_factor, 1e-3); %determine ratio using integer num + den values
pmus_scaled_stretched = resample(pmus_model_scaled, P, Q);   %resample to adjust duration

Pmus = zeros(1,100); %initial padding

%ensure length of breath (insp + exp) the same for each breath
if length(pmus_scaled_stretched) >= 700
    pmus_scaled_stretched =  pmus_scaled_stretched(1:700);
else
    pmus_scaled_stretched = [pmus_scaled_stretched, zeros(1,700-length(pmus_scaled_stretched))];
end

for i =1:num_breaths
    Pmus = [Pmus pmus_scaled_stretched];
end

t = 0:0.01:length(Pmus)/100-0.01;
pmus_in = timeseries(Pmus,t);

% Prepare variables for Simulink workspace
assignin('base', 'R', R/1000);
assignin('base', 'E', E/1000);
assignin('base', 'pmus_peak', pmus_peak);
assignin('base', 'PEEP', PEEP);
assignin('base', 'ps_upper', ps_upper);
assignin('base', 't_insp_rise', t_insp_rise);
assignin('base', 'q_cycle', q_cycle);
assignin('base', 'triangle_paw_trig', triangle_paw_trig);
assignin('base', 'm_k', m_k);
assignin('base', 'int_k', int_k);
assignin('base', 'm_tau', m_tau);
assignin('base', 'int_tau', int_tau);
assignin('base','simTime', t(end));
assignin('base','pmus_in', pmus_in);

%run model
simOut = sim('pv_interactions', 'ReturnWorkspaceOutputs', 'on');

%extract signals
model_outputs.paw = simOut.paw.data;
model_outputs.ps_target = simOut.ps_target.data;
model_outputs.flow = simOut.flow.data;
model_outputs.volume = simOut.vol.data;
model_outputs.pmus = squeeze(simOut.pmus.data);
model_outputs.T_sim = simOut.tout;
end

