%%%pillow thing
%%need to find a way to get rid of the bad values in "the_matrix"
%%%%get the matrix of features

 [big_matrix,this_trial_start,thisloc,thisfreq,big_matrix_ids,response] = make_big_matrix_v2(imaging_spk,'behav');
features = 1:size(big_matrix,1);
save big_matrix_ids big_matrix_ids
for cel = 1:size(response,1);
    cel
    for tr = 1;
        fit_size = ceil(size(big_matrix,2)*.7);
        fit_start = randi(size(big_matrix,2)-fit_size);
        fit_sample = fit_start:fit_start+fit_size-1;
        %         fit_sample = randsample((size(big_matrix,2)),ceil(size(big_matrix,2)*.7));
        ind = 0;
        for i = 1:size(big_matrix,2);
            if isempty(find(fit_sample==i))==1;
                ind = ind+1;
                test_sample(ind) = i;
            end
        end
        
        
        rand_sample = big_matrix(:,fit_sample);
        response_sample = response(cel,fit_sample);
        
        
        
        %     [B,Dev,Stats] = glmfit(zscore(big_matrix(features,fit_sample)'),PV_sample,'binomial','link','logit');
        %         [B,Dev,Stats] = glmfit(big_matrix(features,fit_sample)',response_sample);
        [B,Info] = lassoglm(big_matrix(features,fit_sample)',response_sample,'normal','NumLambda',25,'CV',10);
        beta_index = Info.IndexMinDeviance;
        %                 [B,Dev,Info] = glmfit(zscore(big_matrix(features,fit_sample)'),response_sample','normal','link','probit');
        
        %         yhat = glmval(B,zscore(big_matrix(features,test_sample)'),'logit',Info);
%         yhat = glmval(B,(big_matrix(features,test_sample)'),'identity',Stats);
cnst = Info.Intercept(beta_index);
B1 = [cnst;B(:,beta_index)];
[yhat] = glmval(B1,(big_matrix(features,test_sample))','identity');
        PV_yhat(:,:,tr) = [response(cel,test_sample);yhat'];
%         dev_tr(tr) = Dev;
        
        Beta(cel,tr,:) =B1;
%         pvals(cel,tr,:) = Info.p;
       
    end
     fit(cel,:,:,:) = PV_yhat;
    PV_yhat_all = [];
    for tr = 1:size(PV_yhat,3)
        %         PV_yhat_all = cat(1,PV_yhat_all,PV_yhat(:,:,tr));
        %         PV_yhat_all(1+12*(tr-1):12+12*(tr-1),:) = PV_yhat(:,:,tr);
        temp = find(isnan(PV_yhat(2,:,tr))==0);
        ss(cel,tr) = sum((PV_yhat(1,temp,tr) - PV_yhat(2,temp,tr)).^2);
    end
    save fit fit
    save Beta Beta
    
end







