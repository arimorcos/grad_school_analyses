function distToHPSVM
labels = prevTurn;
labels(labels == 0) = -1;
w = model.SVs' * model.sv_coef;
b = -model.rho;
gamma = labels.*((w/norm(w))'*binFactors) + (b/norm(w));