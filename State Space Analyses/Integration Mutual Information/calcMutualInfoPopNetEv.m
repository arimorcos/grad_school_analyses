function [diffInfo, netEvInfo, turnInfo] = calcMutualInfoPopNetEv(dataCell)
%calcMutualInfoPopNetEv.m Calculates the difference in mutual information
%between the neuronal activity and the net evidence level and the neuronal
%activity and the turn 
%
%INPUTS
%dataCell - dataCell containing imaging data
%
%OUTPUTS
%diffInfo - turnInfo - netEvInfo. Positive if extra information
%netEvInfo - net evidence information in bits
%turnInfo - turn information in bits
%
%ASM 12/14

%get segment traces
[segTraces,~,netEv] = extractSegmentTraces(dataCell);

%get turn (3 options: -1, right; 0, no net ev; 1, left) 
turn = netEv;
turn(turn > 0) = 1;
turn(turn < 0) = -1;

%set options for mutual information
opts.method = 'dr';
opts.bias = 'naive';
opts.btsp = 100;
opts.xtrp = 1;

%%%%%%%%%%%%%% calc net ev %%%%%%%%%%%%%%%%

fprintf('Calculating net evidence mutual information...');

%construct input matrix
[RNetEv, ntNetEv] = buildr(netEv, segTraces);
RNetEv = binr(RNetEv, ntNetEv, 200,'eqpop');
opts.nt = ntNetEv;

%calculate mutual information for net ev
INetEv = information(RNetEv,opts,'ish');

fprintf('Complete\n');

%%%%%%%%%%%%%%%% calc turn %%%%%%%%%%%%%%%%%

fprintf('Calculating turn mutual information...');

%construct input matrix
[RTurn, ntTurn] = buildr(turn, segTraces);
RTurn = binr(RTurn, ntTurn, 200,'eqpop');
opts.nt = ntTurn;

%calculate mutual information for turn
ITurn = information(RTurn,opts,'ish');

fprintf('Complete\n');

%%%%%%%%%%%%% calc diff
netEvInfo = INetEv(1);
turnInfo = ITurn(1);
diffInfo = turnInfo - netEvInfo;

