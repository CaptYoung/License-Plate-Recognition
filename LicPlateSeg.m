function character_image = LicPlateSeg(plate_image)

% 本函数用来实现车牌字符分割。
% 分割失败，返回1*1空胞元数组
% 成功分割的字符依次存在胞元数组 character_image 中
I = plate_image;
bw = im2bw(I); % 二值化
[a, b] = size(bw);
Ibw = ones(size(bw)) - bw; %白字黑底
%% 裁车牌上下多余边缘
h_sum = sum(Ibw,1); %对白字黑底的车牌做垂直投影
[r, c] = findpeaks(a - h_sum);%波谷: r 值  c 坐标
% r1 = [];
c1 = [];    % 记录车牌左边 1/5 区域内的波谷点
c2 = [];    % 记录车牌右边 1/5 区域内的波谷点
c3 = [];    % 记录车牌中间 3/5 区域内的波谷点
index = 1;
m = length(r);
for i = 1:m
    if r(i) > 0.93 * a && c(i) < b/5
        c1(index) = c(i);
        index = index + 1;
    end
end
index = 1;
for i = 1:m
    if r(i) > 0.93 * a && c(i) > 4 * b / 5
        c2(index) = c(i);
        index = index + 1;
    end
end
h = []; % 2*n 维，1， 2行分别存字符的上下行号
index = 1;
for i = 1 : length(c1) - 1
    Itemp = Ibw(:,c1(i):c1(i+1)); % 两个波谷中间的图像
    %连通区
    [L,number] = bwlabel(Itemp);
    for j = 1:number
        [rj, ~] = find(L == j);
        if max(rj) - min(rj) > 0.4 * a % 用高度判断该连通区是否是字符
            h(1,index) = min(rj);
            h(2,index) = max(rj);
            index = index + 1;
        end
    end
end

for i = 1 : length(c2) - 1
    Itemp = Ibw(:,c2(i):c2(i+1));
    %连通区
    [L,number] = bwlabel(Itemp);
    for j = 1:number
        [rj, ~] = find(L == j);
        if max(rj) - min(rj) > 0.4*a % 用高度判断该连通区是否是字符
            h(1,index) = min(rj);
            h(2,index) = max(rj);
            index = index + 1;
        end
    end
end

% 如果在车牌左右两边没有‘找到’字符，再对中间区域查找
if size(h,2) < 1
    index = 1;
    m = length(r);
    for i = 1:m
        if r(i) > 0.93 * a && c(i) > b/5 && c(i) < 4*b/5
            c3(index) = c(i);
            index = index + 1;
        end
    end
    index = 1;
    for i = 1 : length(c3) - 1
        Itemp = Ibw(:,c3(i):c3(i+1));
        %连通区
        [L,number] = bwlabel(Itemp);
        for j = 1:number
            [rj, ~] = find(L == j);
            if max(rj) - min(rj) > 0.4*a
                h(1,index) = min(rj);
                h(2,index) = max(rj);
                index = index + 1;
            end
        end
    end
end

a1 = min(h(1,:)); % 字符上边缘
a2 = max(h(2,:)); % 字符下边缘
I1 = Ibw(a1:a2,:); % 裁掉车牌上下多余边缘

%% 膨胀 腐蚀 （闭操作） 连接某些断开的字符
se = strel('line',6,90);
I2 = imclose(I1,se);

%% 找字符之间的空隙
hh_sum = sum(I2,1); % 对闭操作后的去掉上下边缘的车牌做垂直投影
less5 = zeros(1,b); % 垂直投影后，值小于 5 的地方，标记为1
for i = 1 : b
    if hh_sum(i) <= 5
        less5(i) = 1;
    end
end

[Ll,numl] = bwlabel(less5);
myindex = zeros(1,numl); %记录字符之间的空隙位置（取中点)
for i = 1 : numl
    [~,cl] = find(Ll == i);
    myindex(1,i) = round((max(cl) + min(cl))/2);
end
myindex = [1, myindex, b];
total = 2 + numl; %字符间隙个数

%% 字符剪切
cha{1} = [];
cha{2} = [];
cha{3} = [];
cha{4} = [];
cha{5} = [];
cha{6} = [];
cha{7} = [];
target = 7; % 字符总数

%车牌最右边有干扰
mj = myindex(total -1);
nj = myindex(total);
Itemp = I2(:, mj:nj);
[Ltemp,numtemp] = bwlabel(Itemp);
if numtemp ~= 0
    for iL = 1:numtemp
        [rtemp,ctemp] = find(Ltemp == iL);
        atemp1 = min(rtemp);
        atemp2 = max(rtemp);
        btemp1 = min(ctemp);
        btemp2 = max(ctemp);
        if atemp2 - atemp1 > 0.9*size(I2,1)
            if btemp2 - btemp1 < (atemp2 - atemp1)/3
                myindex = myindex(1,1:total - 1);
                total = total - 1;
            end
        end
    end
end

% 从车牌最右边开始，剪裁后6个字符
for i = 1: total - 1
    j = total - i + 1;
    mj = myindex(j-1);
    nj = myindex(j);
    Itemp = I2(:, mj:nj); % 字符区域
    [Ltemp,numtemp] = bwlabel(Itemp);
    if numtemp == 0
        continue
    end
    for iL = 1:numtemp
        [rtemp,ctemp] = find(Ltemp == iL);
        atemp1 = min(rtemp);
        atemp2 = max(rtemp);
        if atemp2 - atemp1 > 0.9*size(I2,1)
            cha{target} = I1(:,min(ctemp)+mj-1:max(ctemp)+mj-1);
            target = target - 1;
        end
    end
    if target == 1 % 已经有6个字符
        myindex = myindex(1,1:j-1);
        break
    end
end

% 车牌不完整，或字符分割失败
if target ~= 1 
    blank{1} = [];
    character_image = blank;
    return
end

%处理 ‘川’ 这样的没连在一起的汉字
Itemp = I2(:, 1:myindex(length(myindex)));
[Ltemp, ~] = bwlabel(Itemp);
for iL = 1:max(Ltemp(:,1))
    [rtemp,ctemp] = find(Ltemp == iL);
    atemp1 = min(rtemp);
    atemp2 = max(rtemp);
    if atemp2 - atemp1 < 0.5*size(I2,1)
        Ltemp = clean(Ltemp, rtemp, ctemp);
        I1 = clean(I1, rtemp, ctemp);
    end
end
[Ltemp, ~] = bwlabel(Ltemp);
judge = Ltemp(:, 1);%Itemp
[rjudge, ~] = find( judge == 1);
[rtemp,ctemp] = find(Ltemp == 1);
if length(rjudge) > 0.3*size(I2,1)
    Ltemp = clean(Ltemp, rtemp, ctemp);
end
[~, ctemp] = find(Ltemp > 0);
cha{1} = I1(:,min(ctemp):max(ctemp));

%% 字符规则化 32*16
for i = 1:7
   [a,b] = size(cha{i});
   if a > 3 * b
       tmp = round((a - b)/2);
       tmpI = cha{i};
       cha{i} = [zeros(a,tmp), tmpI, zeros(a,tmp)];
   end
   cha{i} = imresize(cha{i}, [32, 16]);
end

%% 返回
character_image = cha;
end