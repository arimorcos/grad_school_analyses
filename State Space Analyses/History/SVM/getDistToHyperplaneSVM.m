function gamma = getDistToHyperplaneSVM(model,traces,labels)
%getDistToHyperplaneSVM.m Calculates the distance of a given point to the
%hyperplane (gamma) for each trial
%
%INPUTS
%model - svm model trained by the libsvm library
%traces - nFeatures x nTrials array of values 
%labels - nTrials x 1 array of labels 
%
%OUTPUTS
%gamma - 1 x nTrials array of distances to hyperplane, normalized so all
%   are positive
%
%ASM 2/15

%ensure only two classes 
assert(length(unique(labels)) == 2,'Can only calculate gamma for two classes');

%convert 0 labels to -1 
if any(labels == 0)
    labels(labels == 0) = -1;
end 

%convert labels to double if logical
if islogical(labels)
    labels = double(labels);
end

%get w vector
w = model.SVs' * model.sv_coef;

%get bias term
b = -model.rho;

%calculate distance
gamma = labels.*((w/norm(w))'*traces) + (b/norm(w));

%ensure mean is positive 
if mean(gamma) < -0.5
    gamma = -1*gamma;
end