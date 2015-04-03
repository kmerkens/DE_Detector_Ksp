function [delFlag] = clickInlinePProc(outFileName,clickTimes,p,...
    encounterTimes,guideDetector,hdr)

% Step through vector of click times, looking forward and back to throw out
% solo clicks, and pairs of clicks, if they are too far away from a cluster
% of clicks with >2 members.
% outputs a vector of pruned times, and a vector flagging which members
% should be removed from other variables.
% Writes pruned times to .pTg file.

% % % Get rid of lone clicks % % %

% Step through deleting clicks that are too far from their preceeding
% and following click
clickTimesPruned = [];

clickTimes = sortrows(clickTimes);
if size(clickTimes,1) > 2
    
    %%%%Added 150219 KPM - check to see how many clicks there are within 60 
    %%%%seconds of this click, and if there are more than 75, flag all for 
    %%%%removal. 
    
%     delFlag = ones(size(clickTimes(:,1)));
%     for itrm = 1:size(clickTimes,1)
%         winsize = 60;
%         winstart = clickTimes(itrm); %The start of the 60 second window
%         winend = winstart + winsize; %End of the window
%         [idx,~] = find((clickTimes(:,1) >= winstart) & ...
%             (clickTimes(:,2) <= winend));
%         wincount = size(idx,1);
%         expandsize = 300;
%         if wincount >= 75
%             delFlag(idx) = 0;
%             %%%Then check to see if there are clicks within 60 seconds of the
%             %%%start or end, and remove those too, and if there are check to
%             %%%see if there are clicks in that direction in the next 60
%             %%%seconds, and expand out until there is a minute with no clicks.
%             expandstart = winstart;
%             expandend = winend;
%             expand = 2;
%             while (expand == 2)
%                 %%%start with going into past
%                 expandstartstep = expandstart - expandsize; %the next step of expansion
%                 [idx,~] = find((clickTimes(:,1) >= expandstartstep) & ...
%                     (clickTimes(:,2) <= expandstart));
%                 expandcount = size(idx,1);
%                 if expandcount >= 1
%                     delFlag(idx) = 0;
%                     expandstart = expandstartstep;
%                 else 
%                     expand = 1;
%                 end
%             end
%             while (expand == 1)
%                 %%%repeat for going into future
%                 expandendstep = expandend + expandsize; %the next step of expansion
%                 [idx,~] = find((clickTimes(:,2) <= expandendstep) & ...
%                     (clickTimes(:,1) >= expandend));
%                 expandcount = size(idx,1);
%                 if expandcount >= 1
%                     delFlag(idx) = 0;
%                     expandend = expandendstep;
%                 else 
%                     expand = 0;
%                 end
%             end    
%         end
%     end  
%     
%     %%%%Then check to see how many clicks there are within 1 second of the
%     %%%%click, and if there are more than 20, flag all for removal. 
%     for itrs = 1:size(clickTimes,1)
%         winsize = 1;
%         winstart = clickTimes(itrs); %The start of the 60 second window
%         winend = winstart + winsize; %End of the window
%         [idx,~] = find((clickTimes(:,1) >= winstart) & ...
%             (clickTimes(:,2) <= winend));
%         wincount = size(idx,1);
%         expandsize = 300;
%         if wincount >= 20
%             delFlag(idx) = 0;
%             %%%same as above.
%             expandstart = winstart;
%             expandend = winend;
%             expand = 2;
%             while (expand == 2)
%                 %%%start with going into past
%                 expandstartstep = expandstart - expandsize; %the next step of expansion
%                 [idx,~] = find((clickTimes(:,1) >= expandstartstep) & ...
%                     (clickTimes(:,2) <= expandstart));
%                 expandcount = size(idx,1);
%                 if expandcount >= 1
%                     delFlag(idx) = 0;
%                     expandstart = expandstartstep;
%                 else 
%                     expand = 1;
%                 end
%             end
%             while (expand == 1)
%                 %%%repeat for going into future
%                 expandendstep = expandend + expandsize; %the next step of expansion
%                 [idx,~] = find((clickTimes(:,2) <= expandendstep) & ...
%                     (clickTimes(:,1) >= expandend));
%                 expandcount = size(idx,1);
%                 if expandcount >= 1
%                     delFlag(idx) = 0;
%                     expandend = expandendstep;
%                 else 
%                     expand = 0;
%                 end
%             end    
%         end
%     end  

    %%%%End Added 150209 KPM
    
    
    delFlag = ones(size(clickTimes(:,1)));
    for itr1 = 1:size(clickTimes,1)
        if itr1 == 1
            if clickTimes(itr1+2,1)-clickTimes(itr1,1)>p.maxNeighbor
                delFlag(itr1) = 0;
            end
        elseif itr1 >= size(clickTimes,1)-1
            [I,~] = find(delFlag(1:itr1-1)==1);
            prevClick = max(I);
            if isempty(prevClick)
                delFlag(itr1) = 0;
            elseif clickTimes(itr1,1) - clickTimes(prevClick,1)>p.maxNeighbor
                delFlag(itr1) = 0;
            end
        else
            [I,~] = find(delFlag(1:itr1-1)==1);
            prevClick = max(I);
            if isempty(prevClick)
                if clickTimes(itr1+2,1) - clickTimes(itr1,1)>p.maxNeighbor
                    delFlag(itr1) = 0;
                end
            elseif clickTimes(itr1,1)- clickTimes(prevClick,1)>p.maxNeighbor &&...
                    clickTimes(itr1+2,1)-clickTimes(itr1,1)>p.maxNeighbor
                delFlag(itr1) = 0;
            end
        end
    end
    %clickTimesPruned = clickTimes(delFlag==1,:);
elseif ~isempty(clickTimes)
    delFlag = zeros(size(clickTimes(:,1)));
else 
    delFlag = [];
end
% TODO: Get rid of pulsed calls

% get rid of duplicate times:
if size(clickTimesPruned,1)>1
    dtimes = diff(clickTimesPruned(:,1));
    closeStarts = find(dtimes<.00002);
    delFlag(closeStarts+1,:) = 0;
end

 %%%%Added 150226 KPM - Remove clicks from outside the encounter times,
 %%%%if the detector is being guided by an xls sheet. 
 %newdelFlag = ones(size(clickTimes(:,1)));
 if guideDetector == 1
     if ~isempty(encounterTimes)
        %Convert all clicTimesPruned to "real" datenums, relative to baby
        %jesus
        sec2dnum = 60*60*24; % conversion factor to get from seconds to matlab datenum
        clickDnum = (clickTimes./sec2dnum) + hdr.start.dnum + datenum([2000,0,0]);
        for itr2 = 1:size(clickDnum,1)
            thisstart = clickDnum(itr2,1);
            thisend = clickDnum(itr2,2);
            afterstarts = find(encounterTimes(:,1)> thisstart);
            firstafterstart = min(afterstarts);
            beforeend = find(encounterTimes(:,2)> thisend);
            firstbeforeend = min(beforeend);
            if firstafterstart ~= firstbeforeend+1;
                %Then this click does not fall within an encounter, chuck it
                delFlag(itr2) = 0;
            end
        end
     else
         error('Error: There are no encounter times to use for pruning')
     end
 end
clickTimesPruned = clickTimes(delFlag==1,:);

fidOut = fopen(strcat(outFileName(1:end-1),p.ppExt),'w+');
if ~isempty(clickTimesPruned)
    for itr3 = 1:size(clickTimesPruned,1)
        % Write post-processed click annotations to .pTg file
        fprintf(fidOut, '%f %f\n', clickTimesPruned(itr3,1),clickTimesPruned(itr3,2));
    end
else
    fprintf(fidOut, 'No clicks detected.');
end

fclose(fidOut);
