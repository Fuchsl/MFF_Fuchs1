function retsTable = price2retWithHolidaysdisc(prices)
%
% Input:
%   prices  nxm matrix or table of prices
%
% Output:
%   retsTable    (n-1)xm table of discrete returns

% get missing values
missingValues = isnan(prices{:,:});

% get log prices
pricesImputed = imputeWithLastDay(prices{:,:});


% calculate discrete returns
Pricesflip=flip(pricesImputed);
rets = (Pricesflip(1:end-1,:)./Pricesflip(2:end,:)-1)*100;

% fill in NaNs again
rets(missingValues(2:end, :)) = NaN;

% embed returns in table meta-data
retsTable = embed(rets, prices(2:end, :));
retsTable.Properties.RowNames=flip(retsTable.Properties.RowNames);
end