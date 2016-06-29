function weights = getSVMWeights(svmModel)

weights = svmModel.SVs' * svmModel.sv_coef;

bias = svmModel.rho;