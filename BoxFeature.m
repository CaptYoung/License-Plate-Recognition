function [theta, L, H] = BoxFeature(X)
% [theta, L, H] = BoxFeature(X) 返回矩阵的特征，
% 长L，高H，以及L与水平线的夹角的正切值theta
% X 为矩阵四个顶点的坐标：第一行为水平坐标，第二行为垂直坐标
LH = zeros(1, 2);
for i = 1 : 2
    x1 = X(1, i);
    y1 = X(2, i);
    x2 = X(1, i+1);
    y2 = X(2, i+1);
    LH(1, i) = sqrt((x2-x1)^2+(y2-y1)^2);
end

if LH(1, 1) > LH(1, 2)
    L = LH(1, 1);
    H = LH(1, 2);
    theta = abs((X(2, 2)-X(2, 1))/(X(1, 2)-X(1, 1)));
else
    L = LH(1, 2);
    H = LH(1, 1);
    theta = abs((X(2, 3)-X(2, 2))/(X(1, 3)-X(1, 2)));
end

end