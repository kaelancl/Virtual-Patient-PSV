%example case of psv pv interations model
%author: Kaelan Lindup
%date: 5th Novemeber 2025

%two examples provided, adjust ind_case = 0 for simple case, or ind_case =
%1 for more detailed case. In more detailed case, additional options
%provided to function.

ind_case = 0;

%required inputs
pat_num = 10; %patient number
pmus_peak = 10; %peak pmus (absolute value), cmH2O
num_breaths = 5; %number of breaths

%optional inputs
pv_options.R = 10; %resistance, cmH2O/L/s
pv_options.E = 10; %elastance, cmH2O/L
pv_options.PEEP = 5; %positive end expiratory pressure, cmH2O
pv_options.ps_upper = 10; %upper pressure support target, cmH2O
pv_options.t_insp_rise = 0.2; %inspiratory rise time, seconds
pv_options.q_cycle = 0.25; %percentage peak flow cycle off criterion, %/100
pv_options.triangle_paw_trig = -0.5; %pressure difference trigger, cmH2O

%psv pv interactions model
if ind_case == 0
    model_outputs = psv_pv_model(pat_num,pmus_peak,num_breaths);
else
    model_outputs = psv_pv_model(pat_num,pmus_peak,num_breaths, pv_options);
end

%visualise outputs
t = tiledlayout(2,2);
nexttile
hold on
plot(model_outputs.T_sim,model_outputs.pmus, 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2);
title("Muscle Pressure")
ylabel("cmH_2O")
xlabel("seconds")
nexttile
hold on
plot(model_outputs.T_sim,model_outputs.paw, 'color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2);
plot(model_outputs.T_sim,model_outputs.ps_target, 'color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1, 'LineStyle',':')
title("Airway Pressure")
ylabel("cmH_2O")
xlabel("seconds")
nexttile
hold on
plot(model_outputs.T_sim,model_outputs.flow, 'color', [0, 0.4470, 0.7410], 'LineWidth', 2);
title("Flow")
ylabel("mL/s")
xlabel("seconds")
nexttile
plot(model_outputs.T_sim,model_outputs.volume, 'color', [0.4940, 0.1840, 0.5560], 'LineWidth', 2);
title("Volume")
ylabel("mL")
xlabel("seconds")



