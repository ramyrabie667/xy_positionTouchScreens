x=[zeros(11,1), 6*ones(11,1) , 137*ones(11,1) ,84*ones(11,1) ,9*ones(11,1) ,4*ones(11,1)];
y=[ ones(1,6) ; 4*ones(1,6)  ; 45*ones(1,6) ; 25*ones(1,6) ; 2*ones(1,6) ; 2*ones(1,6) ; 13*ones(1,6) ; 52*ones(1,6)
    ; 58*ones(1,6) ; 15*ones(1,6) ; 4*ones(1,6)];

yy=transpose(y(:,1));
xx=x(1,:);

maxindexy=findmaxindex (yy);
ycoordinat =findlocation(maxindexy,yy)
maxindexx=findmaxindex (xx);
xcoordinat =findlocation(maxindexx,xx)

function maxs= findmaxindex(inputarry)
the=10;
sensorlength=length (inputarry);
a1=inputarry;
% a1(a1(:)<thrshold)=0)
for i= 1:sensorlength
    if(a1(i)<the)
        a1(i)=0;
    end
end
a1=[0 , a1 ,0];
a2=a1;
for n=1:sensorlength
    if(a1(n)==a1(n+1))
        a2(n)=0;
    else
    a2(n)=(a2(1+n)-a2(n))/abs(a2(1+n)-a2(n));
    end
end
a3=a2;
for v=1:sensorlength
    a3(v)=a2(v+1)-a2(v);
end
a4=a3(1,1:sensorlength);

maxs=find(a4==-2);
end


function  y0=findlocation(mxindex,inputdata)
wy=zeros(1,length(mxindex));
yc= zeros(1,length(mxindex));
if(sum(mxindex)~=0)
    j=length(mxindex);
    for d= 1:j
wy(d)=sum(inputdata(mxindex(d)-1:mxindex(d)+1));
    for bb= -1:1
yc(d)=yc(d) + (inputdata(mxindex(d)-bb)*(mxindex(d)-bb))/wy(d);
    end 
    end
    
    
    y0=(yc*10)/9;
end
end