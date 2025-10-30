%%  Load extracted LS data and then extrapolate it

clear
close all
clc

%%  load data
load LS_Time_model_2.mat

ns=ttt(end,1);
ng=ttt(end,2);

%%  Mute the direct arrivals
ref_rate=0.0008;
for is=1:ns
    for ig=2:ng
        if tt_in(ig,is)-tt_in(ig-1,is)<ref_rate
            break
        end
    end
    tt_in(1:ig-1,is)=0;
end

%%  Create virtual data set
np_v=ns+ng-1;
data_v=zeros(np_v,np_v);
stck=zeros(np_v,np_v);
for is=1:ns
    for ig1=2:ng-1
        p1=(is-1)+ig1;
        for ig2=ig1+1:ng
            p2=(is-1)+ig2;
            if tt_in(ig2,is)>0 && tt_in(ig1,is)>0
                data_v(p1,p2)=data_v(p1,p2)+tt_in(ig2,is)-tt_in(ig1,is);
                stck(p1,p2)=stck(p1,p2)+1;
            end
        end
    end
end

%   Find the avrage
data_v=data_v./stck;
aa=isnan(data_v);
data_v(aa)=0;

%%  Creat Super-virtual data

data_sv=zeros(np_v,np_v);
stck=zeros(np_v,np_v);
nss=ns-ng-1;
for is=1:nss
    for ig1=1:ng
        p1=(is-1)+ig1;
        for p2=(is-1)+ng+1:(is-1)+2*ng
            if tt_in(ig1,is)>0 && data_v(p1,p2)>0
                data_sv(p2,is)=data_sv(p2,is)+tt_in(ig1,is)+data_v(p1,p2);
                stck(p2,is)=stck(p2,is)+1;
            end
        end
    end
end

%   Find the avrage
data_sv=data_sv./stck;
aa=isnan(data_sv);
data_sv(aa)=0;

%   Apply NMO to data_sv
dsv=zeros(ng*2,nss);
g1=ng+1;
for is=1:nss
    dsv(ng+1:end,is)=data_sv(g1:g1+ng-1,is);
    g1=g1+1;
end

%   Reload the traveltimes to retreive the deleted direct pickings
load LS_Time_model_2.mat
dsv(1:ng,:)=tt_in(:,1:nss);

dsv=dsv(1:end-2,:);

% %   Interpolate missing picks
% x=(1:505)';
% for iz=53:84
%     k=1;
%     clear xin din
%     for ix=1:505
%         if dsv(iz,ix)>0
%             din(k,1)=dsv(iz,ix);
%             xin(k,1)=ix;
%             k=k+1;
%         end
%     end
%     if k>1
%         dsv(iz,:)=interp1(xin,din,x,"cubic");
%     end
% end

subplot(221);
imagesc(dsv*1000)
colorbar
xlabel('Source No.')
ylabel('Receiver No.')
title('Extrapolated Data')
colormap jet

for is=1:size(dsv,2)
    for ig=1:size(dsv,1)
        if dsv(ig,is)>0 && tt_ref(ig,is)>0
            err(ig,is)=dsv(ig,is)-tt_ref(ig,is);
        end
    end
end
subplot(222)
imagesc(err*1000,[-4 4])
colormap jet
xlabel('Source No.')
ylabel('Receiver No.')
title('Error of Extrapolated Data')

colorbar

subplot(223)
histogram(err(49:end,:)*1000,100)
xlabel('Error (ms)')
ylabel('Frequency')
title('Histogram of the Error')

subplot(224)
e=err(49:end,:);
cdfplot(reshape(e,size(e,1)*size(e,2),1))
title('Accmulative Error')