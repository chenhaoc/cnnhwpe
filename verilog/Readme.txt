2018/5/30 14:59:51 中国标准时间
./RTL
    包含HWPE的RTL代码，hwpe_tb.v和rv_mcu.v是用来仿真的。

./instr_gen
    包含instr_gen.v，生成协处理器的指令，指令格式96位，{指令、rs1_data、rs2_data},供后续tb读取。针对每一个testcase，都要单独唯一生成，更改`include的vh文件即可。

./testcase
    包含了输入层和中间层的tsetcase，每个testcase里output目录下是模块仿真结果，以及与原始结果的对比错误日志。16个case的仿真均已通过。每个testcase目录下也保留了当前case的instr_gen.v/instr.txt/hwpe_tb.v。
    testcase如下：
    中间层：
             fmap        kernel      stride     out_conv     N_type
           10*10*32    3*3*32*32        1        8*8*32       INT8
           10*10*32    3*3*32*32        1        8*8*32       EXP4
           10*10*32    3*3*32*32        1        8*8*32      Ternary
           17*17*32    3*3*32*32        2        8*8*32       INT8
           17*17*32    3*3*32*32        2        8*8*32       EXP4
           17*17*32    3*3*32*32        2        8*8*32      Ternary
    输入层：
            input        kernel      stride    out_conv      N_type
            18*18*3    11*11*3*32       1       8*8*32        INT8
            16*16*3     9*9*3*32        1       8*8*32        INT8
            14*14*3     7*7*3*32        1       8*8*32        INT8
            12*12*3     5*5*3*32        1       8*8*32        INT8
            10*10*3     3*3*3*32        1       8*8*32        INT8
            25*25*3    11*11*3*32       2       8*8*32        INT8
            23*23*3     9*9*3*32        2       8*8*32        INT8
            21*21*3     7*7*3*32        2       8*8*32        INT8
            19*19*3     5*5*3*32        2       8*8*32        INT8
            17*17*3     3*3*3*32        2       8*8*32        INT8
