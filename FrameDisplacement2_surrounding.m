function [Noutlier, meanmotion,sdmotion,outind_all] = FrameDisplacement2_surrounding(motion, th, format)

% This function calculates the Framewise Displacement (FD) for a dataset of motion regressors (motion) and outputs 
% the associated tmap for a given threshold (th).
% motion is assumed to contain translation and rotation regressors.
% format considers two possible values: SPM or FSL. Default value is FSL.
% Created by Silvina Ferradal.
% Modified by Xi Yu to furhter identify/include one proceeding and two following scans of the image with excessive motion

if strcmp(format,'SPM') % SPM
    diff_tra = motion(:,1:3)-circshift(motion(:,1:3),[-1 0]);
    diff_rot = motion(:,4:6)-circshift(motion(:,4:6),[-1 0]);
else % FSL
    diff_tra = motion(:,4:6)-circshift(motion(:,4:6),[-1 0]);
    diff_rot = motion(:,1:3)-circshift(motion(:,1:3),[-1 0]);
end  

FD = sum(abs(diff_tra),2)+sum(abs(diff_rot),2).*35; % Use a radius of 35 mm for infant heads

FD=circshift(FD,[1 0]);
FD(1,1)=0;
FD = FD';


%% Create a temporal mask 
tmap = FD>th;

outind=find(tmap==1);
outind=outind';

outindminus1=outind-1;
outindplus1=outind+1;
outindplus2=outind+2;


outind_all=unique([outind,outindminus1,outindplus1,outindplus2]);

tempind=find(outind_all>length(FD));

if length(tempind)>0
   outind_all(tempind)=[]; 
end

Noutlier=length(outind_all);

Ftemp=FD;
for j=1:Noutlier
    Ftemp(1,outind_all(j))=0;
    
end

meanmotion=mean(Ftemp);
sdmotion=std(Ftemp);




% Nt = length(FD);
% 
% % figure
% plot(FD,'k','LineWidth',2);
% hold on
% plot((1:Nt),ones(1,Nt).*th,'r','LineWidth',2)
% xlabel('frame'), ylabel('FD (mm)')
% title('Frame-wise Displacement')

