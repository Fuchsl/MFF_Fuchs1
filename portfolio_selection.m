%Teil 2.1.1

% Start und Enddatum festlegen
dateBeg = '01012000';
dateEnd = '01012015';

% Symbole aller Dax-Unternehmen
daxComp = {'ADS.DE', 'ALV.DE',...
    'BAS.DE', 'BAYN.DE', 'BEI.DE', 'BMW.DE', 'CBK.DE', 'DAI.DE', ...
    'DB1.DE',...
    'DBK.DE', 'DPW.DE', 'DTE.DE', 'EOAN.DE', 'FME.DE', 'FRE.DE',...
    'HEI.DE', 'HEN3.DE', 'IFX.DE', 'LHA.DE', 'LIN.DE', 'MAN.DE',...
    'MEO.DE', 'MRK.DE', 'MUV2.DE', 'RWE.DE', 'SAP', 'SDF.DE',...
    'SIE.DE', 'TKA.DE', 'VOW.DE'};


% Download der Daten mit der Funktion getPrices

daxCompPrices = getPrices(dateBeg, dateEnd, daxComp);

%Teil 2.1.2
%%
%Berechnen der diskreten Returns mit einer abgeänderten Funktion von
%price2retWithHolidays
daxCompRetstemp = price2retWithHolidaysdisc(daxCompPrices);
daxCompRets=daxCompRetstemp{:,:};

%Berechnen der Mittelwerte und Standardabweichungen

mudax=mean(daxCompRets,1, 'omitnan');
sigmadax=sqrt(var(daxCompRets,1, 'omitnan'));

Valuesdax=table(mudax(:),sigmadax(:),'VariableNames',{'Mittelwert'; 'Sigma'},'RowNames',...
    daxCompRetstemp.Properties.VariableNames);
%%
%Teil 2.1.3
%%
%Berechnen der Korrelationsmatrix der 30 Dax-Unternehmen

CorDax=corrcoef(daxCompRets,'rows','pairwise');
CorDax=array2table(CorDax,'VariableNames',daxCompRetstemp.Properties.VariableNames,'RowNames',...
    daxCompRetstemp.Properties.VariableNames);

%%
%Teil 2.1.4
% Erstellen eines Histogramm für die Korrelationswerte
CorDaxtemp = triu(CorDax{:,:});
CorDax2=CorDaxtemp(CorDaxtemp~=1 & CorDaxtemp~=0);

hist(CorDax2, 20)
xlabel('Korrelation')
ylabel('Häufigkeit')
title('Korrelation der 30 Dax-Unternehmen')
hold on
%%
%Teil 2.1.5
%Finden der Unternehmen mit der höchsten Korrelation

[row,col]=find(CorDax{:,:} == max(CorDax2));
TickerSymb=CorDax.Properties.VariableNames(row);

%Anzeigen der Unternehmen mit der höchsten Korrelation
% display table
fprintf('\nDie Tickersymbole mit der höchsten Korrelation sind:\n')
celldisp(TickerSymb)
fprintf('\nIhre Korrelation beträgt:\n')
fprintf('%1.5f     %1.5f     %1.5f\n',  max(CorDax2))

%%
%Teil 2.1.6
% Erstellen eines Scatterplots mit Mittelwert und Sigma von allen
% Dax-Unternehmen

figure
plot(Valuesdax{:,2}, Valuesdax{:,1}, 'r.','MarkerSize',15)
xlabel('Standardabweichung')
ylabel('Mittelwert')
title('Returns und Standardabweichung aller Dax-Werte')
hold on

%%
%Teil 2.1.7 

%Simulieren von Gewichten für das Portfolio
weights=rand(200,1);
weights(:,2)=1-weights(:,1);

%%
%Berechnen des erwarteten Returns
weightsret=Valuesdax{10,1}.*weights(:,1)+Valuesdax{11,1}.*weights(:,2);

%%Test ob alle Werte realistisch sind
sum(logical(weightsret>Valuesdax{10,1}|weightsret<Valuesdax{10,1}|weightsret>Valuesdax{11,1}|weightsret<Valuesdax{11,1}))

%%
% Berechnen der Kovarianz beider Unternehmen
cov1=cov(daxCompRets(:, 10) ,daxCompRets(:, 11) , 'omitrows');
%Berechnung der Portfoliovarianz
weightsvar=sqrt((Valuesdax{10,2}.^2).*(weights(:,1).^2)+(Valuesdax{11,2}.^2).*(weights(:,2).^2)...
    +2*(weights(:,1).*weights(:,2)).*cov1(1,2));

%Erstellen eine Plots mit beiden Unternehmen und aller simulierten Gewichte

plot(weightsvar, weightsret, '.b')
hold on
plot(Valuesdax{10,2}, Valuesdax{10,1}, '.g','MarkerSize',28)
plot(Valuesdax{11,2}, Valuesdax{11,1}, '.g','MarkerSize',28)
xlabel('Standardabweichung')
ylabel('Mittelwert')
title('Returns und Standardabweichung aller simulierten Gewichte')
text(Valuesdax{10,2}, Valuesdax{10,1},'   DBK.DE')
text(Valuesdax{11,2}, Valuesdax{11,1},'   DPW.DE')

%%
%Teil 2.1.8
%


% Simulieren von 50000 Portfoliogewichtungen mit Hilfe einer geschriebenen Funktion
simw=simulateweights(50000);

%Berechnung der Portfolio Returns bei den simulierten Gewichten

weightsret1=Valuesdax{'DBK_DE','Mittelwert'}.*simw(:,1)+Valuesdax{'DPW_DE','Mittelwert'}.*simw(:,2)...
    +Valuesdax{'TKA_DE','Mittelwert'}.*simw(:,3)+Valuesdax{'CBK_DE','Mittelwert'}.*simw(:,4);

% Berechnung der Kovarianz zwischen den vier Unternehmen
cov1=cov([daxCompRetstemp{:,'DBK_DE'} ,daxCompRetstemp{:,'DPW_DE'},daxCompRetstemp{:,'TKA_DE'},...
    daxCompRetstemp{:,'CBK_DE'}] , 'omitrows');

%Aufbereitung der Kovarianzen um Matrixmultiplikation machen zu können
xtemp = triu(cov1,1);
ztemp=xtemp(xtemp~=0);
%Multikplikation der Gewichte
weightspro=[simw(:,[1,1]).*simw(:,2:3),simw(:,2).*simw(:,3),simw(:,1).*simw(:,4),...
    simw(:,2).*simw(:,4),simw(:,3).*simw(:,4)];

%Berechnung der Standardabweichung der diversen Gewichtungen
weightsvar1=sqrt((simw.^2)*diag(cov1)+2*(weightspro*ztemp));

% Erstellung eines Scatterplots mit verschiedenen Gewichtungen
figure

plot(weightsvar1, weightsret1, '.r')
xlabel('Standardabweichung')
ylabel('Mittelwert')
title('Returns und Standardabweichung aller simulierten Gewichte')
text(Valuesdax{'DBK_DE',2}, Valuesdax{'DBK_DE',1},'   DBK.DE')
text(Valuesdax{'DPW_DE',2}, Valuesdax{'DPW_DE',1},'   DPW.DE')
text(Valuesdax{'TKA_DE',2}, Valuesdax{'TKA_DE',1},'   TKA.DE')
text(Valuesdax{'CBK_DE',2}, Valuesdax{'CBK_DE',1},'   CBK.DE')
hold on
plot(Valuesdax{'DBK_DE',2}, Valuesdax{'DBK_DE',1}, '.g','MarkerSize',28)
plot(Valuesdax{'DPW_DE',2}, Valuesdax{'DPW_DE',1}, '.g','MarkerSize',28)
plot(Valuesdax{'TKA_DE',2}, Valuesdax{'TKA_DE',1}, '.g','MarkerSize',28)
plot(Valuesdax{'CBK_DE',2}, Valuesdax{'CBK_DE',1}, '.g','MarkerSize',28)


%% Teil 2.1.9

%Ein Punkt ist dann optimal, wenn es keinen anderen Punkt gibt, welcher
%einen höheren erwarteten Return bei gleichzeitig nicht größerer
%Standardabweichung besitzt, oder eine niedriger Standardabweichung bei
%mindestens gleichen Return besitzt. Somit st ein Punkt möglichst weit oben
%links(hoher Return niedriges Risiko) zu bevorzugen. 
% Bei einer linearen Optimierung ist damit zu rechnen, dass der optimale
% Punkt an der Hülle des Polyeders liegt. 