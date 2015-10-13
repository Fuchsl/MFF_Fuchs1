%%Aufgabe 1

%Teil a)

% Ticker Symbolder DB auf Yahoo
tickerSymbs = {'DBK.DE'};     

%% Beginn und Ende der Daten
dateBeg = '01012000';   
dateEnd = '01012015';

%% Daten durch die Funktion getPrices laden
DBData = getPrices(dateBeg, dateEnd, tickerSymbs);

%Teil b)

