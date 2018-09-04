Objective
    A hardware coprocessor for CNN acceleration based on RISC-V instructions set, which is linked with Hummingbird E200 MCU through extension accelerator interface (EAI).

    Hummingbird E200: https://github.com/SI-RISCV/e200_opensource

Features
    • Support Convolution layer and ReLU layer
    • Transform convolution into matrix multiplication (im2col on the fly)
    • Kernel size from 3×3 to 11×11
    • Support data type INT8，UINT8, EXP4 (4 bits of exponential scale) and Ternary
    • 16 dot-product operations of 64-bit operands (8 INT8, 16 EXP4 or 32 Ternary) per cycle
    • PE utilization is 100% for internal layers. For the input layers, the utilization is 82.5%(11×11×3),87.5%(7×7×3),93.75%(5×5×3),84.375%(3×3×3).

Please see ./spec/CNN-HWPE_SPEC_EN.pdf for more details

Author: Hao Chen , Qiang Chen
 Email: chenhaocxjtu@163.com
        chenqiang5233@hotmail.com
