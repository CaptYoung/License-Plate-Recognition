function plate_image = LicPlateLoc(car_image)

% 本函数用来实现车牌定位 并输出透视矫正后的车牌
% 若定位失败，则返回 -1
% 先对输入图像按较宽松的参数进行定位，
% 如果没找到车牌，再用严格的参数再次定位

%% 待处理图像
I = car_image;
[a, b, ~] = size(I);

%% 变量 point4 储存各个待选车牌区域的外接矩形的四个顶点坐标
% lie ： 3*4 的矩阵 每行储存一个待选区域的四个顶点的列坐标
% hang ：3*4 的矩阵，每行储存一个待选区域的四个顶点的行坐标
point4 = struct('lie',zeros(3,4),'hang',zeros(3,4),'top',0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%第一次定位%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 预处理
H = rgb2hsi(I);     % HSI 空间的图像
minH = 170/360;     % H 参数的最小值
maxH = 245/360;     % H 参数的最大值
threshS = 0.2;      % S 参数的最小值
bw = findblue(H, minH, maxH,threshS);
bw = medfilt2(bw, [5, 5]); % 对二值图bw进行中值滤波

%% 寻找蓝色连通区
[L,number] = bwlabel(bw); 
total = number;     % 连通区总个数（0区域不算）

%% 连通区筛选 ： 筛选出待选车牌区域
for i3 = 1 : number
    [r, c] = find(L == i3);
    x = length(r);
    a1 = min(r);
    a2 = max(r);
    b1 = min(c);
    b2 = max(c);
    
    % 1：删除在边缘的连通区 
    if a1 < a/20 || a2 > a - a/20
        L = clean(L, r, c);
        total = total - 1;
        continue
    end
    if b1 < b/20 || b2 > b - b/20
        L = clean(L, r, c);
        total = total - 1;
        continue
    end
    
    % 2 ：删除面积太大或者太小的连通区
    if x < a*b/400 || x > a*b/10
        L = clean(L, r, c);
        total = total - 1;
        continue
    end
    
    % 3：对连通区求最小外界矩形，并删除不满足要求的连通区
    minbox = minBoundingBox([c'; r']); % 最小外接矩形的四个顶点
    [phibox, Lbox, Hbox] = BoxFeature(minbox); % 外接矩形的特征
    if phibox > 1 || Lbox < 2.68*Hbox || Lbox > 5*Hbox %外接矩形的倾斜角度和长宽比例不符合特征
        L = clean(L, r, c);
        total = total - 1;
        continue
    end
    if x < 0.5*Lbox*Hbox %外接矩形内 连通区面积太小
        L = clean(L, r, c);
        total = total - 1;
        continue
    end
    
    % 将外接矩形的四个顶点存入 point4
    point4.top = point4.top + 1;
    point4.lie(point4.top, :) = minbox(1, :);
    point4.hang(point4.top, :) = minbox(2, :);
end

%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 第二次定位 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if point4.top == 0
    % 预处理
    H = rgb2hsi(I);     % HSI 空间的图像
    minH = 210/360;     % H 参数的最小值
    maxH = 245/360;     % H 参数的最大值
    threshS = 0.4;      % S 参数的最小值

    bw = findblue(H, minH, maxH,threshS);
    bw = medfilt2(bw, [5, 5]); % 对二值图bw进行中值滤波
    
    %% 寻找蓝色连通区
    [L,number] = bwlabel(bw);
    total = number;     % 连通区总个数（0区域不算）
    
    %% 连通区筛选 ： 筛选出待选车牌区域
    for i3 = 1 : number
        [r, c] = find(L == i3);
        x = length(r);
        a1 = min(r);
        a2 = max(r);
        b1 = min(c);
        b2 = max(c);
        
        % 1：删除在边缘的连通区
        if a1 < a/20 || a2 > a - a/20
            L = clean(L, r, c);
            total = total - 1;
            continue
        end
        if b1 < b/20 || b2 > b - b/20
            L = clean(L, r, c);
            total = total - 1;
            continue
        end
        
        % 2 ：删除面积太大或者太小的连通区
        if x < a*b/400 || x > a*b/10
            L = clean(L, r, c);
            total = total - 1;
            continue
        end
        
        % 3：对连通区求最小外界矩形，并删除不满足要求的连通区
        minbox = minBoundingBox([c'; r']); % 最小外接矩形的四个顶点
        [phibox, Lbox, Hbox] = BoxFeature(minbox); % 外接矩形的特征
        if phibox > 1 || Lbox < 2.68*Hbox || Lbox > 5*Hbox %外接矩形的倾斜角度和长宽比例不符合特征
            L = clean(L, r, c);
            total = total - 1;
            continue
        end
        if x < 0.5*Lbox*Hbox %外接矩形内 连通区面积太小
            L = clean(L, r, c);
            total = total - 1;
            continue
        end
        
        % 将外接矩形的四个顶点存入 point4
        point4.top = point4.top + 1;
        point4.lie(point4.top, :) = minbox(1, :);
        point4.hang(point4.top, :) = minbox(2, :);
    end
end

%% 对待选区域做最后判断，并对判断结果做透视畸变矫正
if point4.top > 1
    temp = zeros(1, point4.top);
    for index = 1 : point4.top
        xx1 = round(point4.lie(index,:));
        yy1 = round(point4.hang(index,:));
        x0 = sum(xx1)/4;
        y0 = sum(yy1)/4;
        temp(1,index) = sqrt((x0-b/2)^2 + (y0 - a/2)^2);
    end
    tem = find(temp == min(temp));
    point4.lie(1,:) = point4.lie(tem,:);
    point4.hang(1,:) = point4.hang(tem,:);
    point4.top = 1;
end

%透视畸变矫正
if total > 0
    xx = round(point4.lie(1, :)); % 车牌区域最小外接矩形的四个点列坐标
    yy = round(point4.hang(1, :)); % 车牌区域最小外接矩形的四个点行坐标
    b1 = min(xx);
    b2 = max(xx);
    a1 = min(yy);
    a2 = max(yy);
    Ig = L(a1:a2, b1:b2); % 连通图中的车牌区域
    bwIg = bw(a1:a2, b1:b2); % 二值图中的车牌区域 
    
    %查找车牌的四个顶点 用45度的斜线
    
    % 左上：
    target = 0;
    for i = 1 : a2-a1+1
        temp_sum = i+1;
        for j = 1:i
            k = temp_sum - j;
            if Ig(j,k) > 0
                p1 = [k,j]; % [列, 行]
                target = 1;
                break
            end
        end
        if target ==1
            break
        end
    end
    
    % 右上：
    target = 0;
    for i = 1:a2-a1+1
        temp_sum = i+1;
        for j = 1:i
            k = temp_sum - j;
            k = b2 - b1 + 2 - k;
            if Ig(j,k) > 0
                p2 = [k,j]; % [列, 行]
                target = 1;
                break
            end
        end
        if target ==1
            break
        end
    end
    
    % 左下：
    target = 0;
    for i = 1:a2-a1+1
        temp_sum = i+1;
        for j = 1:i
            j1 = a2-a1+2 - j;
            k = temp_sum - j;
            if Ig(j1,k) > 0
                p3 = [k,j1]; % [列, 行]
                target = 1;
                break
            end
        end
        if target ==1
            break
        end
    end
    
    % 右下：
    target = 0;
    for i = 1:a2-a1+1
        temp_sum = i+1;
        for j = 1:i
            k = temp_sum - j;
            k = b2 - b1 + 2 - k;
            j1 = a2-a1+2 - j;
            if Ig(j1,k) > 0
                p4 = [k,j1]; % [列, 行]
                target = 1;
                break
            end
        end
        if target ==1
            break
        end
    end
    
    PP = [p1; p2; p3; p4]; %四个顶点，依次为： 左上 右上 左下 右下
    plate_image = adjust(bwIg, PP); % 透视畸变矫正
    
else
    plate_image = -1;
end

end