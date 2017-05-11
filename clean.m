function I = clean(L, m, n)
% I = clean(L, m, n) 删除 L 中的由（m, n）指定连通区（置为0）
% m 行坐标向量
% n 列坐标向量

a = size(m);
for i = 1 : a
    L(m(i), n(i)) = 0;
end
I = L;
end