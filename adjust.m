function img2 = adjust(img,P)
% img2 = toushihanshu(img,P) 对 img 的矩形P（四个顶点）做透视畸变矫正
% 返回 img2 车牌区域

[M,N] = size(img);
%取四个点，依次是左上，右上，左下，右下
w=round(sqrt((P(1,1)-P(2,1))^2+(P(1,2)-P(2,2))^2));     %从原四边形获得新矩形宽
h=round(sqrt((P(1,1)-P(3,1))^2+(P(1,2)-P(3,2))^2));     %从原四边形获得新矩形高
%四个原顶点：
y=[P(1,1) P(2,1) P(3,1) P(4,1)];    %列坐标 横坐标   
x=[P(1,2) P(2,2) P(3,2) P(4,2)];    %行坐标 纵坐标

%这里是新矩形的顶点
Y=[P(1,1) P(1,1) P(1,1)+h P(1,1)+h]; %行坐标 纵坐标     
X=[P(1,2) P(1,2)+w P(1,2) P(1,2)+w]; %列坐标 横坐标

B=[X(1) Y(1) X(2) Y(2) X(3) Y(3) X(4) Y(4)]';   %变换后的四个顶点，方程右边的值
%联立解方程组，方程的系数
A=[x(1) y(1) 1 0 0 0 -X(1)*x(1) -X(1)*y(1);             
   0 0 0 x(1) y(1) 1 -Y(1)*x(1) -Y(1)*y(1);
   x(2) y(2) 1 0 0 0 -X(2)*x(2) -X(2)*y(2);
   0 0 0 x(2) y(2) 1 -Y(2)*x(2) -Y(2)*y(2);
   x(3) y(3) 1 0 0 0 -X(3)*x(3) -X(3)*y(3);
   0 0 0 x(3) y(3) 1 -Y(3)*x(3) -Y(3)*y(3);
   x(4) y(4) 1 0 0 0 -X(4)*x(4) -X(4)*y(4);
   0 0 0 x(4) y(4) 1 -Y(4)*x(4) -Y(4)*y(4)];

fa=inv(A)*B;        %用四点求得的方程的解，也是全局变换系数
a=fa(1);b=fa(2);c=fa(3);
d=fa(4);e=fa(5);f=fa(6);
g=fa(7);h=fa(8);

rot=[d e f;
     a b c;
     g h 1];        

inv_rot=inv(rot);

miny = min(Y);
maxy = max(Y);
minx = min(X);
maxx = max(X);
img2=zeros(maxy - miny + 1, maxx - minx +1); %要返回的变换后的车牌
for i = 1 : maxy - miny + 1                  %从变换图像中反向寻找原图像的点
    for j = 1:maxx - minx +1
        pix=inv_rot*[i+miny-1 j+minx-1 1]';       %求原图像中坐标，
        pix=inv([g*pix(1)-1 h*pix(1);g*pix(2) h*pix(2)-1])*[-pix(1) -pix(2)]'; %相当于解方程，求y和x，最后pix=[y x];
        
        if pix(1)>=0.5 && pix(2)>=0.5 && pix(1)<=M && pix(2)<=N
            img2(i,j)=img(round(pix(1)),round(pix(2)));     %最邻近插值
        end  
    end
end

end