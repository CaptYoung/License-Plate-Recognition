function ch = recognise(Theta1, Theta2, X, lib)

% 利用已经训练好的神经网络的参数Theta1，Theta2，对X进行识别


m = size(X, 1);

h1 = sigmoid([ones(m, 1) X] * Theta1');
h2 = sigmoid([ones(m, 1) h1] * Theta2');
[~, p] = max(h2, [], 2);

ch = lib(p);
end
