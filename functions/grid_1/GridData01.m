%NATIONAL TACHNICAL UNIVESITY OF ATHENS
%DIONYSOS SATELLITE OBSERVATORY - HIGHER GEODESY LABORATORY
%==========================================================================
%Name : GridData.m
%       
%       Output files for ArcGIS

%==========================================================================
clc
format compact
format long
clear('all');
%--------------------------------------------------------------------------
%Input File format 'name,x,y,Vn,Ve,Vu'
%--------------------------------------------------------------------------
disp('GridData.m');
inp=0;
while inp < 1 
   filename=input('Open Input file: ', 's');
   [inp,message] = fopen(filename, 'r');
   if inp == -1
     disp(message)
   end
end
inp=textscan(inp,'%*s %f %f %f %f %f','delimiter',',');
x=inp{1};
y=inp{2};
n=inp{3};
e=inp{4};
u=inp{5};
m=0;k=-1;
inp=fopen(filename, 'r');
while m~=-1
    k=k+1;
    m=fgetl(inp);
    %m=feof(crd);
end
xmin=1000000;
xmax=0;
ymin=10000000;
ymax=0;
for i=1:k
    if x(i)<xmin
        xmin=x(i);
    end
    if x(i)>xmax
        xmax=x(i);
    end
    if y(i)<ymin
        ymin=y(i);
    end
    if y(i)>ymax
        ymax=y(i);
    end
end
grid_step=input('input the step of the grid: ');

xi=xmin:grid_step:xmax;
yi=ymin:grid_step:ymax;
yi=yi';
%--------------------------------------------------------------------------
%grid the data
%velocities in NS
zn=griddata(x,y,n,xi,yi,'cubic');
%velocities in EW
ze=griddata(x,y,e,xi,yi,'cubic');
%velocities in up
zu=griddata(x,y,u,xi,yi,'cubic');
%plot the valuew of the points
subplot(2,2,1);
plot3(x,y,n,'o'),hold on;
surfc(xi,yi,zn,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('Vnorth'); colorbar;view(2);
subplot(2,2,2);
plot3(x,y,e,'o'),hold on;
surfc(xi,yi,ze,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('Veast'); colorbar;view(2);
subplot(2,2,3);
plot3(x,y,u,'o'),hold on;
surfc(xi,yi,zu,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('Vup'); colorbar;view(2);
%--------------------------------------------------------------------------
%calculate and write velocities for plotting
%scale factor
sc=input('scale factor for velocities: ');
output=input('dwse to onoma tou output arxeiou for horizontal velocities: ', 's');
hfile=fopen(output,'w');
cfile=fopen('inp_dat.txt','w');
fprintf(hfile,'polyline\n');
hfile=fopen(output,'a');

jfin=fix((xmax-xmin)/grid_step);
ifin=fix((ymax-ymin)/grid_step);
q=0;
for i=1:(ifin+1)
    for j=1:(jfin+1) 
        sz(i,j)=ze(i,j);
        if ze(i,j)<=0
        q=q+1;
        x2=xi(j)+ze(i,j)*sc;
        y2=yi(i)+zn(i,j)*sc;
        s=sqrt(ze(i,j)^2+zn(i,j)^2);
        if s<0.01
            sq=1;
        elseif s>=0.01 && s<0.02
            sq=2;
        elseif s>=0.02 && s<3
            sq=3;
        elseif s>=3
            sq=4;
        end
        fprintf(hfile,'%1.0f 0\n',sq);
        fprintf(hfile,'0 %.3f',xi(j));
        fprintf(hfile,'% .3f 0.0 0.0\n',yi(i));
        fprintf(hfile,'1 %.3f',x2);
        fprintf(hfile,'% .3f 0.0 0.0\n',y2);
        sz(i,j)=sqrt(ze(i,j)^2+zn(i,j)^2);
            %output file for grid coords format 'code,x,y,vn,ve'
            fprintf(cfile,'%.0f,',q);
            fprintf(cfile,'%.3f,',xi(j));
            fprintf(cfile,'%.3f,',yi(i));
            fprintf(cfile,'%.4f,',zn(i,j));
            fprintf(cfile,'%.4f\n',ze(i,j));
        elseif ze(i,j)>0
            q=q+1;
        x2=xi(j)+ze(i,j)*sc;
        y2=yi(i)+zn(i,j)*sc;
        s=sqrt(ze(i,j)^2+zn(i,j)^2);
        if s<0.01
            sq=1;
        elseif s>=0.01 && s<0.02
            sq=2;
        elseif s>=0.02 && s<3
            sq=3;
        elseif s>=3
            sq=4;
        end
        fprintf(hfile,'%1.0f 0\n',sq);
        fprintf(hfile,'0 %.3f',xi(j));
        fprintf(hfile,'% .3f 0.0 0.0\n',yi(i));
        fprintf(hfile,'1 %.3f',x2);
        fprintf(hfile,'% .3f 0.0 0.0\n',y2);
        sz(i,j)=sqrt(ze(i,j)^2+zn(i,j)^2);
            %output file for grid coords format 'code,x,y'
            fprintf(cfile,'%.0f,',q);
            fprintf(cfile,'%.3f,',xi(j));
            fprintf(cfile,'%.3f,',yi(i));
            fprintf(cfile,'%.4f,',zn(i,j));
            fprintf(cfile,'%.4f\n',ze(i,j));
        end
        
    end
end
subplot(2,2,4);
surfc(xi,yi,sz,'FaceColor','interp',...
	'EdgeColor','none',...
	'FaceLighting','phong');
axis on; grid on; title('SV in horizontal comp'); colorbar;view(2);
fprintf(hfile,'END');
fclose all;
%clear ('all');
%==========================================================================
%GridStrainTensors.m
%==========================================================================
%input file format 'code,x,y,vn,ve'
inpst=0;
while inpst < 1 
   %filename='inp_dat.txt';
   [inpst,message] = fopen('inp_dat.txt', 'r');
   if inpst == -1
     disp(message)
   end
end
inpt=textscan(inpst,'%s %f %f %f %f ','delimiter',',');
codein=inpt{1};
xin=inpt{2};
yin=inpt{3};
vnin=inpt{4};
vein=inpt{5};
m=0;k=-1;
inpst=fopen('inp_dat.txt', 'r');
while m~=-1
    k=k+1;
    m=fgetl(inpst);
end
%find the grid
%grid=xin(2)-xin(1);
allp=k; %network points
fprintf('All insert network points are : %.0f\n',allp);
np=4; %input('Give the number of points used to calculate strain tensor at least 3 points: ');
%open files to print strain tensors in gis
fprintf('Grid distances : %.0f\n',grid_step);
sc=input('scale factor for strain tensors: ');
% cfile=fopen('cir.txt','w');
% fprintf(cfile,'polygon\n');
% efile=fopen('ell.txt','w');
% fprintf(efile,'polygon\n');
% afile=fopen('axx.txt','w');
% fprintf(afile,'polyline\n');
% blfile=fopen('blarea.txt','w');
% fprintf(blfile,'polyline\n');
deffile=fopen('deformation.txt','w');
fprintf(deffile,'polyline\n');
pfile=fopen('blockpar.txt','w');
fprintf(pfile,'\t\tNATIONAL TECHNICAL UNIVERSITY OF ATHENS\n');
fprintf(pfile,'DIONYSOS SATELLITE OBSERVATORY - HIGHER GEODESY LABORATORY\n');
fprintf(pfile,'*****************************************************************************\n');
fprintf(pfile,'Grid used : %.0f m\n',grid_step);
fprintf(pfile,'Scale Factor : %.0f \t Scale Strain : 10^6\n\n',sc);
fprintf(pfile,'block   xcen \t ycen \t Kmax \t Kmin \t Azimouth \t �max \n');
fprintf(pfile,'(a/a)   (m)  \t (m)  \t (ppm)\t (ppm)\t   (deg)  \t (ppm)\n');
fprintf(pfile,'*****************************************************************************\n');

%dialegma twn shmeiwn PWS???????????????????? mporei kai na to vrika!!
%--------------------------------------------------------------------------
for iall=1:allp
    vel_zero=1;
    x1(1) = xin(iall);
    y1(1) = yin(iall);
    vn(1) = vnin(iall);
    ve(1) = vein(iall);
    x1(2) = x1(1);
    y1(2) = y1(1)+grid_step;
    for i=1:allp
        if x1(2)==xin(i) && y1(2)==yin(i)
            vn(2)=vnin(i);
            ve(2)=vein(i);
            vel_zero=vel_zero+1;
        end
    end
    x1(3) = x1(1)+grid_step;
    y1(3) = y1(1)+grid_step;
    for i=1:allp
        if x1(3)==xin(i) && y1(3)==yin(i)
            vn(3)=vnin(i);
            ve(3)=vein(i);
            vel_zero=vel_zero+1;
        end
    end
    x1(4) = x1(1)+grid_step;
    y1(4) = y1(1);
    for i=1:allp
        if x1(4)==xin(i) && y1(4)==yin(i)
            vn(4)=vnin(i);
            ve(4)=vein(i);
            vel_zero=vel_zero+1;
        end
    end

%Main program for calculation of STP for each cell of grid
    if vel_zero==4
%==========================================================================    
%TRANSFORMATION WITH SIX PARAMETERS
xcen=0;
ycen=0;
for i=1:np
    xcen=xcen+x1(i);
    ycen=ycen+y1(i);
end
xcen=xcen/np;
ycen=ycen/np;

x2=x1-xcen;
y2=y1-ycen;
for i=1:np
    VelneMat(i,1)=ve(i);
    VelneMat(np+i,1)=vn(i);
end
%make the observation matrix
for i=1:np
    ObsMat(1,i)=1;
    ObsMat(2,i)=0;
    ObsMat(3,i)=x2(i);
    ObsMat(4,i)=y2(i);
    ObsMat(5,i)=0;
    ObsMat(6,i)=0;
    ObsMat(1,np+i)=0;
    ObsMat(2,np+i)=1;
    ObsMat(3,np+i)=0;
    ObsMat(4,np+i)=0;
    ObsMat(5,np+i)=x2(i);
    ObsMat(6,np+i)=y2(i);
end
ObsMatTrn=ObsMat';
%**********************************************************************
%least square solution with 6 parameters for strain tensor
%E=[Ex Ey Exx Exy Eyx Eyy]
%E = inv(A'*inv(V)*A)*A'*inv(V)*B
%mse = B'*(inv(V) - inv(V)*A*inv(A'*inv(V)*A)*A'*inv(V))*B./(m-n)
%S = inv(A'*inv(V)*A)*mse
%stdE = sqrt(diag(S))
%**********************************************************************
[E,stdE,mse,S] = lscov(ObsMatTrn,VelneMat);
StanDev=sqrt(mse);
Sx=E(1);
SxVar=stdE(1);
Sy=E(2);
SyVar=stdE(2);
ExxPyy=E(3)+E(6);
ExxMyy=E(3)-E(6);
ExyPyx=E(4)+E(5);
ExyMyx=E(4)-E(5);
Kx=E(3);
Ky=E(6);
KxVar=stdE(3);
KyVar=stdE(6);
Ex=-E(5);
Ey=E(4);
ExVar=stdE(5);
EyVar=stdE(4);
ETotal=ExyMyx/2;
ETotalVar=0.5 * sqrt( S(5,5) + S(4,4));
KDummy = ExxMyy^2 + ExyPyx^2;
KDummy1 = 0.5 * (ExxPyy + sqrt(KDummy));
KDummy2 = 0.5 * (ExxPyy - sqrt(KDummy));
KDumVar = ExxMyy^2 / (4 * KDummy);
KDumVar1 = 0.25 * (1 + ExxMyy / sqrt(KDummy)) ^ 2;
KDumVar2 = 0.25 * (1 - ExxMyy / sqrt(KDummy)) ^ 2;
if KDummy1 >= KDummy2
        Kmax = KDummy1;
        Kmin = KDummy2;
        KmaxVar = sqrt(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
        KminVar = sqrt(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
else
        Kmax = KDummy2;
        Kmin = KDummy1;
        KmaxVar = SQR(KDumVar2 * KxVar ^ 2 + KDumVar1 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
        KminVar = SQR(KDumVar1 * KxVar ^ 2 + KDumVar2 * KyVar ^ 2 + KDumVar * (ExVar ^ 2 + EyVar ^ 2));
end
KMean = ExxPyy / 2;
KMeanVar = 0.5 * sqrt(S(3, 3) + S(6, 6));
Az = 0.5 * (atan(ExyPyx / -ExxMyy));
Az = Az * 180/pi;
if ExxMyy > 0 
    Az = Az + 90;
end
AzVar = 0.5 * sqrt((S(3,3)+S(6,6))*ExyPyx^2 + (S(4,4)+S(5,5)) * ExxMyy^2) / (ExyPyx^2 + ExxMyy^2);
AzVar = AzVar * 180/pi;
Gmax = sqrt(ExxMyy ^ 2 + ExyPyx ^ 2);
GmaxVar = sqrt(KmaxVar ^ 2 + KminVar ^ 2);

%print output file of strain tensor parameters
blnum=iall;
%fprintf(pfile,'block \t xcen \t ycen \t Kmax \t Kmin \t Azimouth \t �max \n');
fprintf(pfile,'%.0f \t %.0f \t %.0f \t %+.3f \t %+.3f \t %+.3f \t %+.3f \n',blnum,xcen,ycen,Kmax*1000000,Kmin*1000000,Az,Gmax*1000000);
%--------------------------------------------------------------------------
%print output file for gis starin tensor
%sc=input('scale factor: ');
r=1;
a=1+Kmax*1000000;
b=1+Kmin*1000000;
f=(90-Az)*pi/180;
%--------------------------------------------------------------------------
%circle
    %cfile=fopen('cir.txt','w');
    %fprintf(cfile,'polygon\n');
    %cfile=fopen('cir.txt','a');
%     fprintf(cfile,'%.0f 0\n',blnum);
%     q=0;
%     for t=0.0: 0.01: 2*pi
%         xcir=xcen+r*cos(t)*sc;
%         ycir=ycen+r*sin(t)*sc;
%         fprintf(cfile,'%.0f',q);
%         fprintf(cfile,'% .3f',xcir);
%         fprintf(cfile,'% .3f 1.#QNAN 1.#QNAN\n',ycir);
%         q=q+1;
%     end
    %fprintf(cfile,'END');
%--------------------------------------------------------------------------
%ellipses
    %efile=fopen('ell.txt','w');
    %fprintf(efile,'polygon\n');
    %efile=fopen('ell.txt','a');
%     fprintf(efile,'%.0f 0\n',blnum);
%     q=0;
%         for t=0.0: 0.01: 2*pi
%             errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
%             erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
%             fprintf(efile,'%.0f',q);
%             fprintf(efile,'% .3f',errx);
%             fprintf(efile,'% .3f 1.#QNAN 1.#QNAN\n',erry);
%             q=q+1;
%         end    
    %fprintf(efile,'END');

%--------------------------------------------------------------------------
%axes of ellipses
%afile=fopen('axx.txt','w');
%fprintf(afile,'polyline\n');
%afile=fopen('axx.txt','a');
% q=0;
% for t=0: pi/2: 3*pi/2
%     fprintf(afile,'%.0f 0\n',q);
%     errx=xcen+a*cos(t)*cos(f)*sc-b*sin(t)*sin(f)*sc;
%     erry=ycen+a*cos(t)*sin(f)*sc+b*sin(t)*cos(f)*sc;
%     fprintf(afile,'0 %.3f',xcen);
%     fprintf(afile,'% .3f 0.0 0.0\n',ycen);
%     fprintf(afile,'0 %.3f',errx);
%     fprintf(afile,'% .3f 0.0 0.0\n',erry);
%     q=q+1;
% end
%fprintf(afile,'END');
%end

% else
%     xcen=xcenb;
%     ycen=ycenb;
% end   %for if line 142
%-------------------------------------------------------------------------
%compression and extension arrows
%id of compression : 0   id of extension : 1
q=0;
for t=0: pi/2: 3*pi/2
    fprintf(deffile,'%.0f 0\n',q);
    errx=xcen+Kmax*cos(t)*cos(f)*sc-Kmin*sin(t)*sin(f)*sc;
    erry=ycen+Kmax*cos(t)*sin(f)*sc+Kmin*sin(t)*cos(f)*sc;
    fprintf(deffile,'0 %.3f',xcen);
    fprintf(deffile,'% .3f 0.0 0.0\n',ycen);
    fprintf(deffile,'0 %.3f',errx);
    fprintf(deffile,'% .3f 0.0 0.0\n',erry);
    q=q+1;
end

 end %vel_zero==1
 
end %for the first FOR line 54 of the routin!!!!!!




fprintf(pfile,'*****************************************************************************\n');
% fprintf(cfile,'END');
% fprintf(efile,'END');
% fprintf(afile,'END');
fprintf(deffile,'END');
% fprintf(blfile,'END');
fclose all;











