目标
    用于CNN硬件加速的协处理器，挂在RISCV指令集的蜂鸟E200 MCU的EAI接口上。
    蜂鸟E200: https://github.com/SI-RISCV/e200_opensource

特点
    支持Kernel的RS维度大小最大11×11
    输入层卷积kernel：C=3
    中间层卷积kernel：Int8 C=8N，Exp4 C=16N，Ter2 C=32N
    每周期完成16个乘积操作，乘积的操作数是64bit
    支持INT8，EXP4（指数scale的4bit），Ter2(Ternary2)
    CNN的卷积运算通过im2col+矩阵乘积实现

    注:N指代整数1,2,3…

详情见./spec/CNN-HWPE_spec_v1.1.6.pdf

Author: Hao Chen , Qiang Chen
 Email: chenhaocxjtu@163.com
        chenqiang5233@hotmail.com
