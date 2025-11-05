Welcome to the Pressure Support Ventilation (PSV) Patient-Ventilator (P-V) Interaction model repository.

First download all the files. Open the matlab app "pv_app_matlab.mlapp" into Matlab. Ensure that the app is run in the directory in which this repository is saved.

To use the model, users can first select which patient to consider from the drop-down list, the absolute desired peak respiratory effort ($P_{mus, peak}$) [cmH2O], and the number of breaths to model.
If desired, values listed under "Tunable Parameters" can also be adjusted.

To run the model, press the "Run Simulation" button.

Modeled ventilator and patient effort signals will then be shown on the four axes. 

Expiration signals are included for visual reference. However, note that the expiratory phase of the model has not been validated against clinical data.

For additional flexibility (e.g., for research study use), the model is also provided as a Matlab function (psv_pv_model.m). An example using this function is provided (example_model_solve.m). 
