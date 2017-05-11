# License-Plate-Recognition
基于MATLAB实现的蓝白车牌识别系统

    这是一个实现简单，准确率较高的方法。
    一、本方法基于颜色特征实现车牌定位。
        在HSI空间实现蓝色查找，思路来自博客园 silenceer 的博客《车牌识别LPR（五）-- 一种车牌定位法》[1]。
        通过对疑似区域求外接矩形判断车牌区域，思路来自博客园 计算机的潜意识 的博客 《EasyPR--开发详解（4）》[2]。
    二、通过垂直投影和连通域分析实现字符分割。
    三、通过3层神经网络实现字符识别。
        参考 Andrew Ng 在 coursera 上的机器学习课程[3]。
    
    请先阅读 函数(程序)功能及文件说明.txt 

    参考资料链接：
    
        [1].http://www.cnblogs.com/silence-hust/p/4191821.html
        
        [2].http://www.cnblogs.com/subconscious/p/4047960.html
        
        [3].(1)https://www.coursera.org/learn/machine-learning
        
        [3].(2)https://www.coursera.org/learn/machine-learning/home/week/5 (注册登录可见)
        
