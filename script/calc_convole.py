################################
# @ filename    : calc_convole.py
# @ author      : yyrwkk
# @ create time : 2024/10/18 13:54:15
# @ version     : v1.0.0
################################
import numpy as np
from scipy import signal
# 二维图像
kernel_origin = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
kernel = np.zeros(kernel_origin.shape)
r,c = kernel_origin.shape
for i in range(r):
    for j in range(c):
        kernel[i,j] = kernel_origin[3-i-1,3-j-1]

# 二维卷积核
feature = np.zeros((10, 10))
for i in range(10):
    for j in range(10):
        feature[i,j] = i*10 + j + 1
# 计算二维卷积
conv_result = signal.convolve2d(feature, kernel, mode='valid')
# 'full'（默认）：返回信号和卷积核的全卷积结果。
# 'same'：输出长度与输入信号相同。
# 'valid'：仅返回完全重叠的部分。

print("二维卷积结果:\n", conv_result)
