%%Aufgabe 1

%Teil 1.1.1)

% Ticker Symbolder DB auf Yahoo
tickerSymbs = {'DBK.DE'};     

%% Beginn und Ende der Daten
dateBeg = '01012000';   
dateEnd = '01012015';

%% Daten durch die Funktion getPrices laden
DBData = getPrices(dateBeg, dateEnd, tickerSymbs);
DBData=flip(DBData);
%Teil 1.1.2)

%% Umwandeln der Preise in logaritmic Returns

DBPreise = price2retWithHolidays(DBData);
DBlogRet = DBPreise{:,:}*100;

%% Datum auf Länge der LogReturns kürzen

DBDatum=numDates(DBData);
%Teil 1.1.3
%%
ToEstMdl = garch(1,1);
EstMdl = estimate(ToEstMdl,DBlogRet);
mu=EstMdl.Constant
sigma = sqrt(EstMdl.UnconditionalVariance)
%Teil 1.1.4
%%
quants = [0.05];
varNorm = norminv(quants, mu, sigma);
%

figure('position', [50 50 1200 600]);

% show exceedances for normal distribution
subplot(1, 2, 1);

% indicate exceedances with logical vector
exceed = DBlogRet <= varNorm;

% show exceedances in red

scatter(DBDatum([logical(0); exceed]), DBlogRet(exceed), '.r')
 
hold on;


% show non-exceedances in blue
scatter(DBDatum([logical(0); ~exceed]), DBlogRet(~exceed), '.b')
datetick 'x'
%
set(gca, 'xLim', [DBDatum(end) DBDatum(2)]);

% include VaR estimation
line([DBDatum(2) DBDatum(end)], varNorm*[1 1], ...
    'Color', 'k')
title(['Exceedance frequency ' ...
    num2str(sum(exceed)/numel(DBlogRet), 2) ' instead of '...
    num2str(quants)])

xlabel('dates')
ylabel('logarithmic % returns')
title('DB returns and VaR exceedances')

%%
% calculate exceedance frequencies for normal distribution
normFrequ = sum((DBlogRet <= varNorm)/numel(DBlogRet));
   
% display table
fprintf('\nExceedance frequencies:\n')
fprintf('%1.5f     %1.5f     %1.5f\n', normFrequ);

%%
%Teil 1.1.5

% starting values
y0 = 0;     
sigma0 = 1;

% init params
sampSize = 40000;  
samples =1;  % path length

rng default; % For reproducibility

[Vw,Yw] = simulate(EstMdl,40000,'NumPaths',samples,'E0',y0,'V0',sigma0);


%%
autogarch = autocorr(Yw.^2);
autohist=autocorr(DBlogRet.^2);


%Teil 1.1.6
%%
samples =3;

[V3,Y3] = simulate(EstMdl,40000,'NumPaths',samples,'E0',y0,'V0',sigma0);

%%
subplot(4, 1, 1);
plot(DBlogRet)
title('logRet historic')
ylim1=get(gca,'YLim')

%%



for i = 2:4
subplot(4, 1, i);
plot(Y3(:,i -1))
title('simulated logRet Garch')
set(gca, 'yLim', ylim1);
end

% Teil 1.2.1
%%




