%%Aufgabe 1

%Teil 1.1.1)

% Ticker Symbol der DB auf Yahoo
tickerSymbs = {'DBK.DE'};     

%% Beginn und Ende der Daten
dateBeg = '01012000';   
dateEnd = '01012015';

%% Daten durch die Funktion getPrices laden
DBData = getPrices(dateBeg, dateEnd, tickerSymbs);

% prices already get "flipped" in getPrices, as they are sorted according
% to dates at the end
%DBData=flip(DBData);
%Teil 1.1.2)

%% Umwandeln der Preise in logaritmic Returns

% don't call them Preise if they are returns
DLogRets = price2retWithHolidays(DBData);
DBlogRet = DLogRets{:,:}*100;

%% Datum auf L�nge der LogReturns k�rzen

DBDatum=numDates(DBData);
%Teil 1.1.3
%%
% Garch Modell erstellen und dann sch�tzen
ToEstMdl = garch(1,1);

% ideally you estimate a GARCH model on zero mean returns - this was not
% required in the homework though
EstMdl = estimate(ToEstMdl,DBlogRet - mean(DBlogRet));
% mu is the constant in the variance equation, not the mean equation!
mu=EstMdl.Constant;

% you want to get the conditional variances, not the unconditional one
sigma = sqrt(infer(EstMdl,DBlogRet));
%Teil 1.1.4
%%
%Berechnen der VaR der zu 95% nicht �berschritten wird
quants = [0.05];
varNorm = norminv(quants, mean(DBlogRet), sigma);
%

figure('position', [50 50 1200 600]);

% 
subplot(1, 1, 1);

% Feststellen der hist. Werte, welche den VaR unterschreiten
exceed = DBlogRet <= varNorm;

% Anzeigen der Ausrei�er in rot

scatter(DBDatum([logical(0); exceed]), DBlogRet(exceed), '.r')
 
hold on;

% Anzeigen aller anderen Werte in blau
scatter(DBDatum([logical(0); ~exceed]), DBlogRet(~exceed), '.b')
datetick 'x'
%
set(gca, 'xLim', [DBDatum(2) DBDatum(end)]);

% plot conditional variances: they are different each day
plot(DBDatum(2:end), varNorm, 'Color', 'k')

xlabel('Datum')
ylabel('logarithmic returns in %')
title('DB returns and VaR exceedances')

%%
% Berechnung der H�ufigkeit von Ausrei�ern bei Normalverteilung
normFrequ = sum((DBlogRet <= varNorm)/numel(DBlogRet));
   
% there is no table, just a single value
fprintf('\nExceedance frequencies:\n')
fprintf('%1.5f\n', normFrequ);

%%
%Teil 1.1.5

% starting values
y0 = 0;     
sigma0 = 1;

% init params
sampSize = 40000;  
samples =1;  

rng default; 

[Vw,Yw] = simulate(EstMdl,40000,'NumPaths',samples,'E0',y0,'V0',sigma0);


%% Berechnung der Autocorrelation

% you can directly use the built-in function for a nicer plot

subplot(2, 1, 1);
autocorr(Yw.^2)
title('Garch Autokorrelation')
ylim([0 1])
subplot(2, 1, 2);
autocorr(DBlogRet.^2)
title('Historische Autokorrelation')
ylim([0 1])
% Die Autokorraltion ist im Garch-Modell h�her als in den historischen
% Daten
%Teil 1.1.6
%%
% Simulation von drei Pfaden
samples =3;

[V3,Y3] = simulate(EstMdl,40000,'NumPaths',samples,'E0',y0,'V0',sigma0);

%%
subplot(4, 1, 1);
plot(DBlogRet)
title('logRet historic')
ylim1=get(gca,'YLim')
ylim(ylim1)


for i = 2:4
subplot(4, 1, i);
plot(Y3(:,i -1))
title('simulated logRet Garch')
set(gca, 'yLim', ylim1);
end

% Es ist noch ein Unterschied zu erkennen. Bei den historischen Daten
% sind die Schwankungen nicht so gro� wie im Garch
% Teil 1.2.1
%%
% Erstellung eines Plots mit der Dichte der historischen log. Returns
rng default;
subplot(1, 1, 1)
ksdensity(DBlogRet);
hold on
%Teil 1.2.2
%%Hinzug�gen der Dichte einer Normalverteilung
[mu2, sigma2] = normfit(DBlogRet);

x = [-10:.001:10];
norm_pdf = normpdf(x,mu2,sigma2);
plot(x, norm_pdf, '-r')
hold on
%Teil 1.2.3
%Hinzuf�gen der Dichte eines simulierten Pfads mit Garch und
%Normalvertilung
[Vw2,Yw2] = simulate(EstMdl,40000,'NumPaths',1,'E0',y0,'V0',sigma0);

[f2,xi2] = ksdensity(Yw2);
plot(xi2,f2,'-g');

%Teil 1.2.4
%Fitten eines Gach-Modells mit T Verteilung

ToEstMdlT = garch('GARCHLags',1,'ARCHLags',1, 'Distribution', 'T');
EstMdlT = estimate(ToEstMdlT,DBlogRet);

%Teil 1.2.5
%Hinzuf�gen der Dichte eines simulierten Pfads mit Garch und
%T Verteilung

[Vw3, Yw3] = simulate(EstMdlT,40000,'NumPaths',1,'E0',y0,'V0',sigma0);

[f3,xi3] = ksdensity(Yw3);
plot(xi3,f3,'-k');
xlabel('Returns in %')
ylabel('Dichte')
legend('historische Daten', 'Normalverteilung','Normalverteilung GARCH ',...
'T Verteilung GARCH ')
 legend('boxoff')
% Teil 1.2.6
%%
% Das Garch-Modell mit T Verteilung trifft die Dichte der historischen
% Daten am besten. Die Normalverteilung untersch�tzt extreme Werte und
% Werte nahe an der Null. Die T Verteilung mit Garch trifft Werte
% nahe Null besser als die anderen Dichten. Zudem werden die Fat Tails
% besser nachgebildet.







