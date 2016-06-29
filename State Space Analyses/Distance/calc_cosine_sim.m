function cosine_sim = calc_cosine_sim(vec1, vec2)
%CALC_COSINE_SIM Summary of this function goes here
%   Detailed explanation goes here

num = vec1'*vec2;
den = norm(vec1)*norm(vec2);
cosine_sim = num/den;

end

