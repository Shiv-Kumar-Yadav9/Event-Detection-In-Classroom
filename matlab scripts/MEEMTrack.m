

function result = MEEMTrack(input, ext, show_img, init_rect, start_frame, end_frame)

warning('off', 'all')
addpath(genpath('.'));
% parse input arguments
D = dir(fullfile(input,['*.', ext]));
file_list={D.name};

if nargin < 4
    init_rect = -ones(1,4);
end
if nargin < 5
    start_frame = 1;
end
if nargin < 6
    end_frame = numel(file_list);
end

% declare global variables
global sampler
global svm_tracker
global experts
global config
global finish % flag for determination by keystroke
global tld_tracker;


config.display = true;
sampler = createSampler();
svm_tracker = createSvmTracker();
tld_tracker = tldDemo();
experts = {};
finish = 0;


timer = 0;
result.res = nan(end_frame-start_frame+1,4);
result.len = end_frame-start_frame+1;
result.startFrame = start_frame;
result.type = 'rect';

if show_img
    figure(1); set(1,'KeyPressFcn', @handleKey); 
end
fprintf("%f %f %f %f %f\n", init_rect(1, 1), init_rect(1, 2), init_rect(1, 3), init_rect(1, 4), 1.0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    main loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
output = zeros(1,4);

for frame_id = start_frame:end_frame
    if finish == 1
        break;
    end

       
    
    %% read a frame
    I_orig=imread(fullfile(input,file_list{frame_id}));
    
    %% intialization
    if frame_id==start_frame
        
        % crop to get the initial window
        if isequal(init_rect,-ones(1,4))
            assert(config.display)
            figure(1)
            imshow(I_orig);
            [InitPatch init_rect]=imcrop(I_orig);
        end
        init_rect = round(init_rect);
        
        config = makeConfig(I_orig,init_rect,true,true,true,show_img);
        svm_tracker.output = init_rect*config.image_scale;
        svm_tracker.output(1:2) = svm_tracker.output(1:2) + config.padding;
        svm_tracker.output_exp = svm_tracker.output;
        
        output = svm_tracker.output;
    end
        
    %% compute ROI and scale image
    [I_scale]= getFrame2Compute(I_orig);
    
    %% crop frame
    if frame_id == start_frame
        sampler.roi = rsz_rt(svm_tracker.output,size(I_scale),5*config.search_roi,false);
    else%if svm_tracker.confidence > config.svm_thresh
        sampler.roi = rsz_rt(output,size(I_scale),config.search_roi,true);
    end
    I_crop = I_scale(round(sampler.roi(2):sampler.roi(4)),round(sampler.roi(1):sampler.roi(3)),:);
    
    %% compute feature images
    [BC F] = getFeatureRep(I_crop,config.hist_nbin);
   
    %% tracking part
    
    tic
    
    if frame_id==start_frame
        initSampler(svm_tracker.output,BC,F,config.use_color);
        train_mask = (sampler.costs<config.thresh_p) | (sampler.costs>=config.thresh_n);
        label = sampler.costs(train_mask,1)<config.thresh_p;
        fuzzy_weight = ones(size(label));
        initSvmTracker(sampler.patterns_dt(train_mask,:), label, fuzzy_weight);
        
        if config.display
            figure(1);
            imshow(I_orig);
            res = svm_tracker.output;
            res(1:2) = res(1:2) - config.padding;
            res = res/config.image_scale;
            rectangle('position',res,'LineWidth',2,'EdgeColor','b')
        end
    else
        % testing
        
        if config.display
            figure(1)
            imshow(I_orig);       
            roi_reg = sampler.roi; roi_reg(3:4) = sampler.roi(3:4)-sampler.roi(1:2)+1;
            roi_reg(1:2) = roi_reg(1:2) - config.padding;
            rectangle('position',roi_reg/config.image_scale,'LineWidth',1,'EdgeColor','r');
        end
        if mod((frame_id - start_frame + 1),config.expert_update_interval) == 0% svm_tracker.update_count >= config.update_count_thresh
            updateTrackerExperts;
            tldDemo(opt);
        end

        expertsDo(BC,config.expert_lambda,config.label_prior_sigma);
        
        if svm_tracker.confidence > config.svm_thresh
            output = svm_tracker.output;
        end
        res=output;
        res(1:2) = res(1:2) - config.padding;
        res = res/config.image_scale;
        fprintf("%f %f %f %f %f\n", res(1,1), res(1,2), res(1,3), res(1, 4), svm_tracker.confidence);
        if config.display
            figure(1) 
            res = output;
            res(1:2) = res(1:2) - config.padding;
            res = res/config.image_scale;
            if svm_tracker.best_expert_idx ~= numel(experts)
                % red rectangle: the prediction of current tracker
                res_prev = svm_tracker.output_exp;
                res_prev(1:2) = res_prev(1:2) - config.padding;
                res_prev = res_prev/config.image_scale;
                rectangle('position',res_prev,'LineWidth',2,'EdgeColor','r') %
                % yellow rectangle: the prediction of the restored tracker
                rectangle('position',res,'LineWidth',2,'EdgeColor','y')   
            else
                % blue rectangle: indicates no restoration happens 
                rectangle('position',res,'LineWidth',2,'EdgeColor','b') 
            end
       
        end
        
 
        %% update svm classifier
        svm_tracker.temp_count = svm_tracker.temp_count + 1;
        
        if svm_tracker.confidence > config.svm_thresh %&& ~svm_tracker.failure
            train_mask = (sampler.costs<config.thresh_p) | (sampler.costs>=config.thresh_n);
            label = sampler.costs(train_mask) < config.thresh_p;
            
            skip_train = false;
            if svm_tracker.confidence > 1.0 
                score_ = -(sampler.patterns_dt(train_mask,:)*svm_tracker.w'+svm_tracker.Bias);
                if prod(double(score_(label) > 1)) == 1 && prod(double(score_(~label)<1)) == 1
                    skip_train = true;
                end
            end
            
            if ~skip_train
                costs = sampler.costs(train_mask);
                fuzzy_weight = ones(size(label));
                fuzzy_weight(~label) = 2*costs(~label)-1;
                updateSvmTracker (sampler.patterns_dt(train_mask,:),label,fuzzy_weight);  
            end
        else % clear update_count
            svm_tracker.update_count = 0;
        end
% toc
    end

    timer = timer + toc;
    res = output;
    res(1:2) = res(1:2) - config.padding;
    result.res(frame_id-start_frame+1,:) = res/config.image_scale;
end

%% output restuls
result.fps = result.len/timer;


clearvars -global sampler svm_tracker experts config finish 
