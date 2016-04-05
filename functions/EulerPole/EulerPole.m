function EulerPole
%==========================================================================
%  
%   |===========================================|
%   |**     DIONYSOS SATELLITE OBSERVATORY    **|
%   |**        HIGHER GEODESY LABORATORY      **|
%   |** National Tecnical University of Athens**|
%   |===========================================|
%  
%   filename              : EulerPole.m
%                           NAME=EulerPole
%   version               : v-1.0
%                           VERSION=v-1.0
%                           RELEASE=beta
%   created               : APR-2012
%   usage                 :
%   exit code(s)          : 0 -> success
%                         : 1 -> error
%   discription           : 
%   uses                  : 
%   notes                 :
%   TODO                  :
%   detailed update list  : LAST_UPDATE=JAN-2014
%   contact               : Demitris Anastasiou (danast@mail.ntua.gr)
%                           Xanthos Papanikolaou (xanthos@mail.ntua.gr)
%==========================================================================
%--------------------------------------------------------------------------
% model for euler pole velocities
%--------------------------------------------------------------------------
%GRS80  a=6378137m b=6356752 f=1/298.257222101   e^2=0.006694380023
global input_dir
global output_dir
clc
format compact
format long
re=6378137; 
a=6378137; b=6356752;
file=fopen(fullfile(output_dir,'outne_w.txt'),'w');
fprintf(file,'Dionysos Satellite Observatory               %s\n',date);
fprintf(file,'Higher Geodesy Laboratory\n');
fprintf(file,'--------------------------------------------------------\n');
fprintf(file,'Estimation of euler pole and angular velocity\n');
file=fopen(fullfile(output_dir,'outne_w.txt'),'a');
%--------------------------------------------------------------------------
%arxeio coord format 'name,f,l'
crd=0;
while crd < 1 
    dir(input_dir)
   filename = input('Open input file coords in f,l velocities n,e,u: ', 's');
   [crd,message] = fopen(fullfile(input_dir,filename), 'r');
   if crd == -1
      disp(message)
   end
end
cor = textscan(crd,'%s %f %f %f %f %f %f %f %f','delimiter',',');
lat = cor{2};
long = cor{3};
[corx1 cory1] = wgs2ggrs(lat,long);

code = cor{1};
fe = cor{2}*pi/180;
%ellipsoid to sphere
fs = atan(((b/a)^2)*tan(fe));
l = cor{3}*pi/180;
veln = cor{4};
vele = cor{5};
%m = 0; k = -1;
%crd=fopen(fullfile(input_dir,filename), 'r');
arr_s=size(lat);
k=arr_s(1);
% while m~=-1
%     k=k+1;
%     m=fgetl(crd);
%     %m=feof(crd);
% end

fprintf(file,'Number of station velocities introduced: %.0f\n',k);

%epanalhptikh diadikasia gia na petaei ta residuals----------------

%matrix v=[vni;vei]
v = [veln(1);vele(1)];
for q=2:k
   v = [v;veln(q);vele(q)];
end
%matrix A
A = re*[sin(l(1)) -cos(l(1)) 0;-sin(fs(1))*cos(l(1)) -sin(fs(1))*sin(l(1)) cos(fs(1))];
for q=2:k
    A1 = re*[sin(l(q)) -cos(l(q)) 0;-sin(fs(q))*cos(l(q)) -sin(fs(q))*sin(l(q)) cos(fs(q))];
    A = [A;A1];
end
[w,se_w,mse,S] = lscov(A,v);
%w1=linsolve(A,v)
wr = sqrt((w(1)^2) + (w(2)^2) + (w(3)^2)); %|w| rad/y
sw = sqrt((abs(w(1))*se_w(1)^2+abs(w(2))*se_w(2)^2+abs(w(3))*se_w(3)^2)/wr);
swd = sw*180000000/pi;
wd = wr*180/pi; %|w| deg/y
wm = wd*1000000; %|w| deg/My
lr = atan(abs(w(2))/abs(w(1)));
if w(2)>= 0 && w(1) >= 0
    lr = lr;
elseif w(2)>= 0 && w(1) <= 0
    lr = pi - lr;
elseif w(2)<= 0 && w(1) <= 0
    lr = pi + lr;
elseif w(2)<= 0 && w(1) >= 0
    lr = 2*pi - lr;
end
fr=atan(abs(w(3))/sqrt(w(1)^2+w(2)^2));
if w(3)>= 0
    fr = fr;
elseif w(3)<0
    fr = 2*pi - fr;
end
disp('(1) Direct Euler Pole : ')
fprintf(' Latitude = %+.4f deg\n',fr*180/pi)
fprintf(' Longtitude = %+.4f deg\n',lr*180/pi)
fprintf('(2) Opposed Euler Pole: ')
fprintf(' Latitude = %+.4f deg\n',-fr*180/pi)
fprintf(' Longtitude = %+.4f deg\n',(lr+pi)*180/pi)
p_select = input('Use this pole (1) or opposed (2) : ');
if p_select == 1
    wrad=(wm*pi/180)/1000000;
elseif p_select == 2
    fr = -fr;
    lr = lr + pi;
    wm = -wm;
    w(1) = -w(1);
    w(2) = -w(2);
    w(3) = -w(3);
    wrad = (wm*pi/180)/1000000;
end
if lr > 2*pi
    lr = lr - 2*pi;
elseif lr < 0
    lr = lr + 2*pi;
end
t1 = -((se_w(2))^2)/(abs(w(1))*(cos(w(2)/w(1))^2)*(tan(w(2)/w(1))^2));
t2 = ((se_w(1))^2)*abs(w(2))/((w(1)^2)*(cos(w(2)/w(1))^2)*(tan(w(2)/w(1))^2));
sl=sqrt(t1+t2);
sld=sl*180/pi;
lp=lr*180/pi;
h1=w(3)/sqrt(w(1)^2+w(2)^2);
h2=(cos(h1))^2*(tan(h1)^2);
w1=h1*w(1)/h2;
w2=h1*w(2)/h2;
w3=-(h1/w(3))/h2;
sf=sqrt(abs(w1*se_w(1)^2+w2*se_w(2)^2+w3*se_w(3)^2));
sfd=sf*180/pi;
%sphere to ellipsoid
fre=atan(tan(fr)/((b/a)^2));
fp=fre*180/pi;

fprintf(file,'\nEstimation of Euler pole \n');
fprintf(file,'\t latitude:  %.3f \t',fp);
fprintf(file,'+-%.3f deg\n',sfd);
fprintf(file,'\t longitude: %.3f \t',lp);
fprintf(file,'+-%.3f deg\n',sld);
fprintf(file,'\nparameter\t\tvalue\tst_er \t\t\tvalue\tst_er\n');
fprintf(file,'\t\t\t\t(deg/My)\t\t\t\t (rad/y)\n');
fprintf(file,'--------------------------------------------------------\n');
fprintf(file,'ang vel w\t\t%.3f',wm);
fprintf(file,'\t%.3f',swd);
fprintf(file,'\t\t%.3e',wrad);
fprintf(file,'\t%.3e\n',sw);
fprintf(file,'vel comp wx\t\t%.3f',w(1)*180*1000000/pi);
fprintf(file,'\t%.3f',se_w(1)*180000000/pi);
fprintf(file,'\t\t%.3e',w(1));
fprintf(file,'\t%.3e\n',se_w(1));
fprintf(file,'vel comp wy\t\t%.3f',w(2)*180*1000000/pi);
fprintf(file,'\t%.3f',se_w(2)*180000000/pi);
fprintf(file,'\t\t%.3e',w(2));
fprintf(file,'\t%.3e\n',se_w(2));
fprintf(file,'vel comp wz\t\t%.3f',w(3)*180*1000000/pi);
fprintf(file,'\t%.3f',se_w(3)*180000000/pi);
fprintf(file,'\t\t%.3e',w(3));
fprintf(file,'\t%.3e\n\n',se_w(3));
fprintf(file,'mean sigma: %.3f deg/My',sqrt(mse*180000000/pi));
fprintf(file,'\t%.3e rad/y\n',sqrt(mse));
fprintf(file,'Estimated covariance matrix of w: (rad/y)^2\n');
for q=1:3
    fprintf(file,'%.3e\t %.3e\t %.3e\n',S(1,q),S(2,q),S(3,q));
end

%-------------------------------------------------------------------------
%calculate for the points linear velocities and differences
R=6378137000;

%eisagwgh twn dedomenwn tou polou
fep=atan(((b/a)^2)*tan(fre));
lep=lr;
% direction=input('give direction of angular velocity 1:clockwise 2:counderclockwise : ');

%wrad=(wm*pi/180)/1000000;
fprintf(file,'\n\t(mm/yr)\t\tinput\t\t\toutput\t\tresiduals\n');
fprintf(file,'  code \tVn\t\tVe\t\t Vn\t\tVe\t\tdVn\t\tdVe\n');
fprintf(file,'--------------------------------------------------------\n');
resn=0;
rese=0;
for q=1:k

    if lep>0
        A=2*pi-lep+l(q);
    else
        A=l(q)-lep;
    end
    fsq=fs(q);

    Vn(q)=R*wrad*(sin(A)*cos(fep));  %mm/yr
    Ve(q)=R*wrad*cos(fsq)*(sin(fep)-tan(fsq)*cos(fep)*cos(A));         %mm/yr

%V=sqrt(Vn^2+Ve^2);
%azrad=(pi/2)-atan(Vn/Ve);
%az=azrad*180/pi;

    fprintf(file,'%.0f. ',q);
    fprintf(file,'%s',code{q});
    fprintf(file,' \t %+2.1f',veln(q)*1000);
    fprintf(file,' \t %+2.1f',vele(q)*1000);
    fprintf(file,' \t %+2.1f',Vn(q));
    fprintf(file,' \t %+2.1f',Ve(q));
    dvn(q)=veln(q)*1000-Vn(q);
    fprintf(file,' \t %+2.1f',dvn(q));
    dve(q)=vele(q)*1000-Ve(q);
    fprintf(file,' \t %+2.1f \n',dve(q));
    resn=resn+(Vn(q)-(veln(q)*1000))^2;
    rese=rese+(Ve(q)-(vele(q)*1000))^2;
    
end
s_vn=sqrt(resn/k);
s_ve=sqrt(rese/k);
fprintf(file,'s_vn= %.1f mm/y \n',s_vn);
fprintf(file,'s_ve= %.1f mm/y ',s_ve);
fclose all;
[h,p,ci,stats] = ttest(dvn,0,0.3)
mu = 0
sigma = ci(2)
[n,p] = size(dvn)
outliers = abs(dvn -- mu(ones(n, 1),:)) > 3*sigma(ones(n, 1),:)
nout = sum(outliers)
[h,p,ci,stats] = ttest(dve,0,0.3)
mu = 0
sigma = ci(2)
[n,p] = size(dve)
outliers = abs(dve -- mu(ones(n, 1),:)) > 3*sigma(ones(n, 1),:)
nout = sum(outliers)
%[h,p,ci,stats] = ttest2(Vn,veln,[],[],'unequal')
% PROGRAM TO PLOT VELOCITIES----------------------------
%e=resid(dvn,Vn)
%scale factor
sc=input('scale factor for plot in GIS: ');
%calculate horizontal component of velocities
corx2=corx1+vele*sc;
cory2=cory1+veln*sc;
obs_name='obs_vel';
ExtShpEP(obs_name,k,code,corx1,cory1,corx2,cory2,veln,vele)
corx3=corx1+Ve'*sc/1000;
cory3=cory1+Vn'*sc/1000;
mod_name='mod_vel';
ExtShpEP(mod_name,k,code,corx1,cory1,corx3,cory3,Vn,Ve)
ExtShpEPole(fp,lp,wm)


fclose all;


%OLD PROGRAM TO PLOT VELOCITIES----------------------------
%--------------------------------------------------------------------------
%plot vectors of model in arcGIS
% c1=input('do you want to plot model of vectors?? 1:yes 2:no \n');
% if c1==1
%     disp('give the region in f,l WGS 84')
%     fmin=input('give fmin: ');
%     fmax=input('give fmax: ');
%     lmin=input('give lmin: ');
%     lmax=input('give lmax: ');
%     D=[1 fmin lmin];
%     vele=0;
%     veln=0;
%     q=1;    
%     for fcount=fmin:0.25:fmax
%         for lcount=lmin:0.25:lmax
%             %make point of the grid plotting
%             q=q+1;
%             D=[D;q fcount lcount];
%             %calculate linear velocities for the grid
%             if lep>0
%                 ah=2*pi-lep+(lcount*pi/180);
%             else
%                 ah=(lcount*pi/180)-lep;
%             end
%             
%             fcount1=atan(((b/a)^2)*tan(fcount*pi/180));
%             Vn=(R*wrad*(sin(ah)*cos(fep)))/1000;        %m/yr
%             Ve=(R*wrad*cos(fcount1)*(sin(fep)-tan(fcount1)*cos(fep)*cos(ah)))/1000; %m/yr
%             vele=[vele;Ve];
%             veln=[veln;Vn];        
%         end
%     end
%     
%     
% %from GRS80 to GGRS87 project cordinates-----------------------------------
% %square first eccecintry %
% e1=0.006694380;
% %square second eccecintry %
% e2=0.006739497;
% pp=size(D);
% n=pp(1);
% for i=1:n
% Rad_f(i)=D(i,2)*pi/180;
% Rad_lon(i)=D(i,3)*pi/180;
% end
% Rad_f=Rad_f';
% Rad_lon=Rad_lon';
% for i=1:n
%     W(i)=1/(sqrt(1-e1*(sin(Rad_f(i))^2)));
% end
% W=W';
% for i=1:n
%     N(i)=a*W(i);
% end
% N=N';
% 
% m0=0.9996;
% l0=24*pi/180;
% 
% % finding Sf %
% Sf=zeros(n,1);
% m0=0.9996;
% for i=1:n
%     Sf(i)=6367408.748*(1.000006345*Rad_f(i)-(0.0025188441)*sin(2*Rad_f(i))+((0.0000052871167)/2)*sin(4*Rad_f(i))-((0.000000010357890)/3)*sin(6*Rad_f(i)));
% end
% 
% for i=1:n
%     t(i)=tan(Rad_f(i));
%     h2(i)=e2*((cos(Rad_f(i)))^2);
%     dl(i)=Rad_lon(i)-l0;
% end
% 
% t=t';
% h2=h2';
% dl=dl';
% 
% % approximate projection's coordinates %
% Northing=ones(n,1);
% Easting=ones(n,1);
% for i=1:n
%     Northing(i)=m0*Sf(i)+m0*N(i)*(((dl(i)^2)/2)*sin(Rad_f(i))*cos(Rad_f(i))+(((dl(i)^4)/24)*sin(Rad_f(i))*((cos(Rad_f(i)))^3))*(5-(t(i)^2)+9*h2(i)+4*(h2(i)^2)))+((dl(i)^6)/720)*sin(Rad_f(i))*((cos(Rad_f(i))^5))*(61-58*(t(i)^2)+(t(i)^4)+270*h2(i)-(330*(t(i)^2)*h2(i))+(445*(h2(i)^2))+(324*(h2(i)^3))-(680*(t(i)^2)*(h2(i)^2))+(88*(h2(i)^4))-(600*(t(i)^2)*(h2(i)^3))-(192*(t(i)^2)*(h2(i)^4)))+(((dl(i)^8)/40320)*sin(Rad_f(i))*((cos(Rad_f(i))^7))*(1385-(3111*(t(i))^2)+(543*(t(i)^4))-(t(i)^6)));
% end
% 
% for i=1:n
%     Easting(i)=m0*N(i)*(dl(i)*cos(Rad_f(i))+(((dl(i)^3)*(cos(Rad_f(i))^3))/6)*(1-(t(i)^2)+h2(i))+(((dl(i)^5)*(cos(Rad_f(i))^5))/120)*(5-18*(t(i)^2)+(t(i)^4)+14*h2(i)-58*(t(i)^2)*h2(i)+(13*h2(i)^2)+4*(h2(i)^3)-64*((t(i)*h2(i))^2)-24*(t(i)^2)*(h2(i)^3))+(((dl(i)^7)*(cos(Rad_f(i))^7))/5040)*(61-479*(t(i)^2)+179*(t(i)^4)-(t(i)^6)));
% end
% 
% Easting=Easting+500000;
% 
% %final coordinates%
% %TM=[Easting Northing];
% corx1=Easting;
% cory1=Northing;
% 
% %--------------------------------------------------------------------------
% % plot velocities TM=[E N] GGRS87  lvel=[Ve Vn]
% %scale factor
% sc=input('scale factor for plot in GIS: ');
% %calculate horizontal component of velocities
% corx2=corx1+vele*sc;
% cory2=cory1+veln*sc;
% %write output file for horizontal component
% pfile=fopen('plot.txt','w');
% fprintf(pfile,'polyline\n');
% pfile=fopen('plot.txt','a');
% for l=1:q
%     fprintf(pfile,'%1.0f 0\n',l-1);
%     fprintf(pfile,'0 %.3f',corx1(l));
%     fprintf(pfile,'% .3f 0.0 0.0\n',cory1(l));
%     fprintf(pfile,'1 %.3f',corx2(l));
%     fprintf(pfile,'% .3f 0.0 0.0\n',cory2(l));
% end
% fprintf(pfile,'END');
% close all;
% 
%     
% end




