function [] = NM_reid_wcnwasa12_main()
%   Compute person re-identification
%
%   Author:    Niki Martinel
%   Copyright: Niki Martinel, 2012
%
   
%% STARTUP
NM_startup

%% INIT PARAMETERS
pars = NM_reid_wcnwasa12_init_parameters('WARD', '001', 'SvsS', 1);

%% LOAD DATASET
dataset = NM_reid_wcnwasa12_load_dataset( pars );

%% COMPUTE SIGNATURES
signatures = NM_reid_wcnwasa12_compute_signature(dataset, pars);

%% MATCH SIGNATURES
matches = NM_reid_wcnwasa12_match_signature(signatures, pars);

%% COMPUTE STATS
stats = NM_reid_wcnwasa12_evaluate_matches(dataset, matches, pars);

%% PLOT RESULTS
NM_reid_wcnwasa12_results(dataset, stats, pars);

