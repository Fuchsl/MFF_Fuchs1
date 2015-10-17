function simw=simulateweights(sample)

mtemp=2;
xtemp=zeros(sample,3);

for i = 1:sample
while mtemp >= 1

xtemp(i,:)=unifrnd(0,1,1,3);
mtemp=sum(xtemp(i,:));
end
mtemp=2;
end

xtemp(:,4)=1-sum(xtemp,2);
simw=xtemp;

end