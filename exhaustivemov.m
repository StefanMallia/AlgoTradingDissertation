%%
clear
clf
clc

data=xlsread('EURUSD_hour.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Defining Variables                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

ISstart=1;
ISend=56175;
sharpee=nan(1,2);
parameters=nan(1,2);
calendar=nan(1,2);
finalreturn=nan(1,2);
profitfactor=nan(1,2);
maxdrawdown=nan(1,2);
sortinoratio=nan(1,2);
winningrate=nan(1,2);
numberoftrades=nan(1,2);



walkforward=18725;
tic


%%    
OOSstart=ISend+1;
OOSend=OOSstart+walkforward;
date=data(ISstart:OOSend,1);
prices=data(ISstart:ISend,6);
sh=nan(100,100);

%%



for s=2:99
for l=s+1:100
    

smas=nan(length(prices),1);
smal=nan(length(prices),1);
status=zeros(length(prices),1);
state=0; 

for i=l:length(prices)
    %Simple Moving average
    smas(i,1)=(sum(prices(i-s+1:i)))/s;
    smal(i,1)=(sum(prices(i-l+1:i)))/l;
end
for i = l+1 : length(prices)
if prices(i)>smas(i,1) && prices(i)>smal(i,1)
    state=1;
end
if prices(i)<smas(i,1) && prices(i)>smal(i,1)
    state=0;
end
if prices(i)<smas(i,1) && prices(i)<smal(i,1)
    state=-1;
end
if prices(i)>smas(i,1) && prices(i)<smal(i,1)
    state=0;
end
status(i,1)=state;    
end
    
    r=[0;status(1:end-1).*diff(prices)];
    sh(l,s)=sharpe(r,0)*sqrt(6125);

clc

display(' ')
display('Current Parameters')
display(' ')
display('Slow Moving average: ')
disp(l)
display('Fast Moving average: ')
disp(s)
display(' ')
maxSH=max(max(sh));
display(['Max Sharpe: ', num2str(maxSH)])
end
end


%%
maxSH=max(max(sh));

[l,s]=ind2sub(size(sh),find(sh==max(max(sh)),1,'last'));

%%
prices=data(ISstart:ISend,6); 
smas=nan(length(prices),1);
smal=nan(length(prices),1);
status=zeros(length(prices),1);
profitloss=nan(length(prices),1);
state=0; 

for i=l:length(prices)
    %Simple Moving average
    smas(i,1)=(sum(prices(i-s+1:i)))/s;
    smal(i,1)=(sum(prices(i-l+1:i)))/l;
end


for i = l+1 : length(prices)
if prices(i)>smas(i,1) && prices(i)>smal(i,1)
    state=1;
end
if prices(i)<smas(i,1) && prices(i)>smal(i,1)
    state=0;
end
if prices(i)<smas(i,1) && prices(i)<smal(i,1)
    state=-1;
end
if prices(i)>smas(i,1) && prices(i)<smal(i,1)
    state=0;
end
status(i,1)=state;    

if status(i,1)==1 && status(i-1,1)==0
    entrylong=prices(i);
end
if status(i,1)==0 && status(i-1,1)==1
    profitloss(i)=prices(i)-entrylong;
end
if status(i,1)==-1 && status(i-1,1)==0
    entryshort=prices(i);
end
if status(i,1)==0 &&  status(i-1,1)==-1
    profitloss(i)=entryshort-prices(i);
end
if status(i,1)==1 && status(i-1,1)==-1
    entrylong=prices(i);
    profitloss(i)=entryshort-prices(i);
end
if status(i,1)==-1 && status(i-1,1)==1
    entryshort=prices(i);
    profitloss(i)=prices(i)-entrylong;
end
end


r=[0;status(1:end-1).*diff(prices)];
sharp=sharpe(r,0)*sqrt(6125);

winningrate(1)=numel(profitloss(profitloss>0))/numel(profitloss(profitloss<0));
numberoftrades(1)=numel(profitloss(profitloss>0))+numel(profitloss(profitloss<0));
sortinoratio(1),downsidedeviation(1)=sortino(r,0);
profitfactor(1)=sum(r(r>0))/-sum(r(r<0));

cumsumr=cumsum(r);
drawdowns=zeros(length(cumsumr),1);

for i=1:length(cumsumr) 
maxr=find(cumsumr==max(cumsumr(1:i)),1,'last');

drawdowns(i)=cumsumr(maxr)-sum(r(1:i));
end

maxdrawdown(1)=(max(drawdowns)*10000);

sharpee(1)=sharp;
finalreturn(1)=sum(r)*10000;
%%
figure (1)
figure1(1)=subplot(2,1,1);
plot([prices(l:end),smas(l:end),smal(l:end)]); grid on
legend ('Close',['Fast ',num2str(s,3)],['Slow ',num2str(l,3)],'Location', 'Best')
title(['Optimised Result on the sample test from ', num2str(date(1)),' to ', num2str(date(ISend-ISstart)),])

figure1(2)=subplot(2,1,2);
plot([status(l:end)*100,cumsum(r(l:end))*10000]); grid on
title([' Annual Sharpe Ratio= ', num2str(sharp,3), '     ', 'Final Return ', num2str(sum(r)*10000)])
legend('Position','Cumulative Return','Location','Best')
linkaxes(figure1,'x')

%%
prices=data(OOSstart-l+1:OOSend,6);

smas=nan(length(prices),1);
smal=nan(length(prices),1);
status=zeros(length(prices),1);
profitloss=nan(length(prices),1);
state=0; 

for i=l:length(prices)
    %Simple Moving average
    smas(i,1)=(sum(prices(i-s+1:i)))/s;
    smal(i,1)=(sum(prices(i-l+1:i)))/l;
end

for i=l:length(prices)
    %Simple Moving average
    smas(i,1)=(sum(prices(i-s+1:i)))/s;
    smal(i,1)=(sum(prices(i-l+1:i)))/l;
end
for i = l+1 : length(prices)
if prices(i)>smas(i,1) && prices(i)>smal(i,1)
    state=1;
end
if prices(i)<smas(i,1) && prices(i)>smal(i,1)
    state=0;
end
if prices(i)<smas(i,1) && prices(i)<smal(i,1)
    state=-1;
end
if prices(i)>smas(i,1) && prices(i)<smal(i,1)
    state=0;
end
status(i,1)=state;


if status(i,1)==1 && status(i-1,1)==0
    entrylong=prices(i);
end
if status(i,1)==0 && status(i-1,1)==1
    profitloss(i)=prices(i)-entrylong;
end
if status(i,1)==-1 && status(i-1,1)==0
    entryshort=prices(i);
end
if status(i,1)==0 &&  status(i-1,1)==-1
    profitloss(i)=entryshort-prices(i);
end
if status(i,1)==1 && status(i-1,1)==-1
    entrylong=prices(i);
    profitloss(i)=entryshort-prices(i);
end
if status(i,1)==-1 && status(i-1,1)==1
    entryshort=prices(i);
    profitloss(i)=prices(i)-entrylong;
end
end


r=[0;status(1:end-1).*diff(prices)];

sharp=sharpe(r,0)*sqrt(6125);

winningrate(2)=numel(profitloss(profitloss>0))/numel(profitloss(profitloss<0));
numberoftrades(2)=numel(profitloss(profitloss>0))+numel(profitloss(profitloss<0));
profitfactor(2)=sum(r(r>0))/-sum(r(r<0));
sortinoratio(2)=sortino(r,0);

cumsumr=cumsum(r);
drawdowns=zeros(length(cumsumr),1);

for i=1:length(cumsumr) 
maxr=find(cumsumr==max(cumsumr(1:i)),1,'last');

drawdowns(i)=cumsumr(maxr)-sum(r(1:i));
end

maxdrawdown(2)=(max(drawdowns)*10000);

sharpee(2)=sharp;
finalreturn(2)=sum(r)*10000;
parameters(1)=l;
parameters(2)=s;
calendar(1)=date(OOSstart-ISstart);
calendar(2)=date(end);
%%
figure (2)
figure2(1)=subplot(2,1,1);
plot([prices(l:end),smas(l:end),smal(l:end)]); grid on
legend ('Close',['Fast ',num2str(s,3)],['Slow ',num2str(l,3)],'Location', 'Best')
title(['Optimised Result on the out of sample test from ', num2str(date(OOSstart-ISstart)),' to ', num2str(date(end)),])

figure2(2)=subplot(2,1,2);
plot([status(l:end)*50,cumsum(r(l:end))*10000]); grid on
title([' Annual Sharpe Ratio= ', num2str(sharp,3), '     ', 'Final Return ', num2str(sum(r)*10000)])
legend('Position','Cumulative Return','Location','Best')
linkaxes(figure2,'x')


%%

toc
timetaken=toc;
                                        

                                              
                                                                                
                                                                              
