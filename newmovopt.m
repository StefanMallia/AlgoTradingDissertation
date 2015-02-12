%%
clear
clf
clc
%%

data=xlsread('EURUSD_hour.csv');

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

%Used to store the sharpe ratio for each iterarion. Iterations are
%determined by the short, medium, and long moving averages, hence why it is
%a 3d matrix. Iterations are not independent of one another because medium
%moving averages must always have more data points than the short and the
%long must always have more than the medium. This means that when 34 point
%short moving average is being calculated, the long moving average can only
%range from 35 to 100.
so=nan(100,1);% To prevent repetitions
sm=round(linspace(2,98,5));
%To shorten optimisation times we pick 5 equidistant points from the short
%range and then "zoom in" on the point which has the largest sharpe ratio.
%If we have [1 25 50 74 98] and 74 happens to have the largest sharpe
%ratio then the zoom in region is between 50 and 98. 5 equidistant points
%are taken from this area and the process is repeated.
%%



for s=sm;
    
so(s,1)=s;% To prevent repetitions
for l=round(linspace(s+1,100,round((100-s)/4)))
    
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
    sh(s,l)=sharpe(r,0)*sqrt(6125);

clc
display('Current Parameters')
display(' ')
display('Slow Moving average: ')
disp(l)
display('Fast Moving average: ')
disp(s)
display(' ')
maxSH=max(max(sh));
display(' ')
display(['Max Sharpe: ', num2str(maxSH)])
display(' ')

end
end


%%
maxSH=max(max(sh));
v=find(sh==max(max(sh)),1,'last');
[x,z]=ind2sub(size(sh),find(sh==max(max(sh)),1,'last'));
%Selection of the best sharpe ratio from sh
%v finds the position of that ratio in the matrix and ind2sub serves to
%convert that number into x, y, z coordinates which correspond to the
%short, medium, and long moving average parameters respectively.
%%
sm1=find(sm==x);
sm2=min(sm(sm1+1:end));
sm3=max(sm(1:sm1-1));

if isempty(sm2)
    sm2=sm(end);
end
if isempty(sm3)
    sm3=sm(1);
end

%sm1 is used to determine what value for the short moving average should be
%used for the zoom in region. sm2 and sm3 find the neighboring moving
%average parameters which would act as the maximum and minimum values of
%the range.

%%


for u=1:10
sm4=round(linspace(sm3,sm2,5));


if isequal(sm,sm4)~=1
sm=sm4;


for s=sm
if so(s,1)~=s %to prevent repetions
so(s,1)=s;% To prevent repetitions



%sm corresponds to the zoom in region being worked on while s corresponds
%to the short moving average parameter.

for l=round(linspace(s+1,100,round((100-s)/4)))
clc
display(' ')
display(['Max Sharpe: ', num2str(maxSH)])
display(['Iteration: ', num2str(u)])    
display(' ')
display(['Fast SMA: ', num2str(sm)])
display(['Slow SMA: ', num2str(round(linspace(s+1,100,round((100-s)/4))))])

smas=nan(length(prices),1);
smal=nan(length(prices),1);
status=zeros(length(prices),1);
state=0; 

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
    sh(s,l)=sharpe(r,0)*sqrt(6125);

end
end
end
maxSH=max(max(sh));
v=find(sh==max(max(sh)),1,'last');
[x,z]=ind2sub(size(sh),find(sh==max(max(sh)),1,'last'));



sm1=find(sm==x);
if isempty(sm1)
    x=lm(find(abs(x-sm)==min(abs(x-sm)),1,'last'));
    sm1=find(sm==x);
end

sm2=min(sm(sm1+1:end));
sm3=max(sm(1:sm1-1));

if isempty(sm2)
    sm2=sm(end);
end
if isempty(sm3)
    sm3=sm(1);
end



end
end


%%

s=x;
l=z;


prices=data(ISstart:ISend,6); 

smas=nan(length(prices),1);
smal=nan(length(prices),1);
status=zeros(length(prices),1);
profitloss=nan(length(prices),1);
state=0; 

for i=l+1:length(prices)
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


%%
r=[0;status(1:end-1).*diff(prices)];


sharp=sharpe(r,0)*sqrt(6125);

winningrate(1)=numel(profitloss(profitloss>0))/numel(profitloss(profitloss<0));
numberoftrades(1)=numel(profitloss(profitloss>0))+numel(profitloss(profitloss<0));
sortinoratio(1)=sortino(r,0);
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
figure(1)
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

maxdrawdown(2)=max(drawdowns)*10000;

sharpee(2)=sharp;
finalreturn(2)=sum(r)*10000;
parameters(1)=l;
parameters(2)=s;
calendar(1)=date(OOSstart-ISstart);
calendar(2)=date(end);

%%
figure(2)
figure2(1)=subplot(2,1,1);
plot([prices(l:end),smas(l:end),smal(l:end)]); grid on
legend ('Close',['Fast ',num2str(s,3)],['Slow ',num2str(l,3)],'Location', 'Best')
title(['Optimised Result on the out of sample test from ', num2str(date(OOSstart-ISstart)),' to ', num2str(date(end)),])

figure2(2)=subplot(2,1,2);
plot([status(l:end)*100,cumsum(r(l:end))*10000]); grid on
title([' Annual Sharpe Ratio= ', num2str(sharp,3), '     ', 'Final Return ', num2str(sum(r)*10000)])
legend('Position','Cumulative Return','Location','Best')
linkaxes(figure2,'x')


%%

toc
timetaken=toc;

