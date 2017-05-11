function bw = findblue(H, blue_minH, blue_maxH, threshS)
% bw = findblue(H, blue_minH, blue_maxH, threshS) 判断每个像素点是否为蓝色
% 像素点为蓝色，则二值图相应的位置为 1，反之为 0 

% bw 返回的二值图（蓝色为1）
% H hsi空间的图像
% blue_minH 最小蓝色阈值（归一化值）
% blue_maxH 最大蓝色阈值（归一化值）
% shreshS 最小饱和度值（归一化值）


[a,b,c] = size(H);
bw = zeros(a, b);
for i1 = 1:a
    for j1 = 1:b
        if H(i1,j1,1)>=blue_minH && H(i1,j1,1)<=blue_maxH
            bw(i1,j1) = 1;
        else
            bw(i1,j1) = 0;
        end
    end
end
for i2 = 1:a
    for j2 = 1:b
        if bw(i2,j2) == 1
            if H(i2,j2,2) >= threshS
                bw(i2,j2) = 1;
            else
                bw(i2,j2) = 0;
            end
        end
    end
end

end