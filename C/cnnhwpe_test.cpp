#include <iostream>
#include <stdint.h>
#include <assert.h>
#include <stdio.h>
#include <memory.h>
#include <limits.h>
// choose one cfg file and run
//#include ".\\case_define\\inter_layer_3_8b.h"
//#include ".\\case_define\\inter_layer_3_4b.h"
//#include ".\\case_define\\inter_layer_3_2b.h"
#include ".\\case_define\\input_layer_3.h"
//#include ".\\case_define\\input_layer_5.h"
//#include ".\\case_define\\input_layer_7.h"
//#include ".\\case_define\\input_layer_9.h"
//#include ".\\case_define\\input_layer_11.h"

using namespace std;

#define R(v,H,L) ((uint64_t(v)<<(63-H))>>(63+L-H))//get bit H:L
#define B(v,X) ((uint64_t(v)>>X)&1)//git the bit v
#define RI(v,H,L) ((int64_t(v)<<(63-H))>>(63+L-H))//get bit H:L
//{i2,i1}={B15,...B1,B0}, T0(i1,i2)={B14,B12,...B2,B0}, T1(i1,i2)={B15,B13,...B3,B1}
#define T0(i1,i2) ((i1&0xff)|(i1>>16&0xff)<<8|(i1>>32&0xff)<<16|(i1>>48&0xff)<<24 |(i2&0xff)<<32|(i2>>16&0xff)<<40|(i2>>32&0xff)<<48|(i2>>48&0xff)<<56)
#define T1(i1,i2) ((i1>>8)&0xff|(i1>>24&0xff)<<8|(i1>>40&0xff)<<16|(i1>>56&0xff)<<24 |(i2>>8&0xff)<<32|(i2>>24&0xff)<<40|(i2>>40&0xff)<<48|(i2>>56&0xff)<<56)

union bits64_t {
    uint64_t i64;
    int8_t i8[8];
} pe_lm,pe_rm; // pe left matrix, right matrix

int32_t dot_8(bits64_t a, bits64_t b) {
    int32_t mac = int32_t(a.i8[0])*int32_t(b.i8[0])+
                  int32_t(a.i8[1])*int32_t(b.i8[1])+
                  int32_t(a.i8[2])*int32_t(b.i8[2])+
                  int32_t(a.i8[3])*int32_t(b.i8[3])+
                  int32_t(a.i8[4])*int32_t(b.i8[4])+
                  int32_t(a.i8[5])*int32_t(b.i8[5])+
                  int32_t(a.i8[6])*int32_t(b.i8[6])+
                  int32_t(a.i8[7])*int32_t(b.i8[7]);
    return mac;
}

int32_t dot_4(bits64_t a, bits64_t b) {
    uint8_t a_exp;
    uint8_t b_exp;
    uint8_t mul_exp;
    uint8_t sign_bit;
    int32_t mul_decode;
    int32_t mac=0;
    for(int i=0; i<16; i+=1) {
        a_exp = R(a.i64,2,0); // get the exponent
        b_exp = R(b.i64,2,0);
        if(a_exp==0 || b_exp==0)
            mul_decode = 0;  // exp=0, value=0
        else {
            mul_exp = a_exp + b_exp;
            mul_decode = 1 << (mul_exp-2); // one-hot decode
        }
        sign_bit = (B(a.i64,3)^B(b.i64,3));
        mac += sign_bit ? -1*mul_decode : mul_decode;
        a.i64 = a.i64 >> 4;
        b.i64 = b.i64 >> 4;
    }
    return mac;
}

int32_t dot_2(bits64_t a, bits64_t b) {
    int32_t a_i2;
    int32_t b_i2;
    int32_t mac=0;
    for(int i=0; i<32; i+=1) {
        assert( ~(B(a.i64,1)==1 && B(a.i64,0)==0));
        assert( ~(B(b.i64,1)==1 && B(b.i64,0)==0));
        a_i2 = int32_t((int64_t(a.i64)<<62)>>62);
        b_i2 = int32_t((int64_t(b.i64)<<62)>>62);
        mac += a_i2*b_i2;
        a.i64 = a.i64 >> 2;
        b.i64 = b.i64 >> 2;
    }
    return mac;
}
//get 64bit unaligned data from bit_addr of {pe_lm2,pe_lm1}
uint64_t get_non_aligned_64bit(uint64_t pe_lm1, uint64_t pe_lm2, uint32_t bit_addr) {
    uint64_t L_half = (pe_lm1>>bit_addr);
    uint64_t H_half = ((pe_lm2<<(64-bit_addr))&(~((uint64_t(1)<<(64-bit_addr))-1)));//note:int64 a<<64 ==> a<<0
    uint64_t aligned_64bit = (bit_addr==0)?pe_lm1:L_half|H_half;
    return aligned_64bit;
}

int main() {

// Layer Config
    const uint8_t  Kernel_size=   D_Kernel_size  ; //4 bit used, S=R=Kernel_size
    const uint8_t  Data_type  =   D_Data_type  ; //2 bit used, 1/2/3=2bit/4bit/8bit
    const bool     Layer_type =   D_Layer_type  ; // 1 input layer
    const bool     Kernel_333 =   D_Kernel_333  ; // 1 kernel=3*3*3
    const uint8_t  AccReg_shift=  D_AccReg_shift ; //5 bit used, <24
// Conv Config
    const uint16_t H = D_H;
    const uint16_t W = D_W;
    const uint16_t C = D_C;
    const uint16_t K = D_K;
    const uint16_t STRIDE = D_STRIDE;
    char fmap_file_path[]  = D_fmap_file_path;
    char kernel_file_path[]= D_kernel_file_path;
    char conv_file_path[]  = D_conv_file_path;

    assert(Data_type>=1 && Data_type<=3);
    assert(AccReg_shift<=24);

    // In this test, fmap(input) is divided into 8 parts according to HW plane
    // FmapAddrBase[8] are the first address of each part.
    //        kernel_333=0         kernel_333=1, just 4 addr are needed
    //   -----------------------       -----------------------
    //   |0         |4         |       |0         |1         |
    //   |          |          |       |          |          |
    //   -----------------------       -----------------------
    //   |1         |5         |       |2         |3         |
    //   |          |          |       |          |          |
    //   -----------------------       -----------------------
    //   |2         |6         |       |          |          |
    //   |          |          |       |          |          |
    //   -----------------------       -----------------------
    //   |3         |7         |       |          |          |
    //   |          |          |       |          |          |
    //   -----------------------       -----------------------

// Variable
    uint32_t *FmapAddrBase;    //initial address FmapAddrBase[8]
    uint32_t FmapConvAddr[8];  //address of convolution window
    uint32_t FmapSramAddr[8];  //left matrix address, fmap sram address
    uint32_t KernelSramAddr;   //right matrix address, kernel sram address

    uint16_t countH;
    uint16_t countW;
    uint16_t countK;
    uint32_t offsetH;
    uint32_t offsetW;
    uint32_t conv_countCH;
    uint32_t conv_countW;
    uint32_t conv_offsetCH;
    uint32_t conv_offsetW;

    const uint8_t  N = Data_type==1?2:Data_type==2?4:Data_type==3?8:8;
    const uint16_t K_count  = K/16 ; //10bit used
    const uint16_t H_count  = ((H-Kernel_size)/STRIDE+1)/4 ;
    const uint16_t W_count  = ((W-Kernel_size)/STRIDE+1)/2 ;
    const uint16_t H_stride = Kernel_333 ? 2*STRIDE*C*N/8 : STRIDE*C*N/8;
    const uint16_t W_stride = Kernel_333 ? (H+1)*C*STRIDE*N/8 : H*C*STRIDE*N/8 ;
    const uint16_t Conv_CH_count = Kernel_333 ? 3 : Layer_type ? uint16_t(C*Kernel_size*N/64)+1 : C*Kernel_size*N/64;
    const uint16_t Conv_W_offset = Kernel_333 ? 2*C*H*N/8 : C*H*N/8;

    uint64_t *MemFmap;  //input feature map
    uint64_t *MemKernel;//input weight kernel
    int32_t  *OutFmap;  //output feature map

    static int32_t AccReg[8][16];
    static int32_t outfmap_w[2*W_count][4*H_count][16*K_count];//1 dimension output from AccReg
    static int32_t AccReg_round[H_count*W_count*K_count][8][16];
    static int32_t outfmap_r[2*W_count][4*H_count][16*K_count];//1 dimension output from AccReg_round,
    static int32_t outfmap_cmp[uint32_t(H_count*W_count*K_count*8*16)];

    // Read in feature map memory file
    FILE *MemFmap_file;
    if ((MemFmap_file = fopen(fmap_file_path,"rb")) == NULL) {
        cout << "file open failed!: fmap_dat" << endl;
        return 0;
    }
    fseek(MemFmap_file, 0L, SEEK_END); //set cursor to ending of file
    uint32_t fmap_len = ftell(MemFmap_file);
    if(Kernel_333==0)
        assert(fmap_len==H*W*C*N/8);
    else
        assert(fmap_len==(H+1)*W*C*N/8);
    rewind(MemFmap_file); //set cursor to beginning of file
    MemFmap = new uint64_t[fmap_len/8];
    int x=fread(MemFmap,8,fmap_len/8,MemFmap_file);
    assert(x==fmap_len/8);
    cout << " From file : " << fmap_file_path << endl;
    cout << "\t" << x << " 64-bit FeatureMap data read in..." << endl;

    // Read in kernel memory file
    FILE  *MemKernel_file;
    if ((MemKernel_file = fopen(kernel_file_path,"rb")) == NULL) {
        cout << "file open failed!: kernel_dat" << endl;
        return 0;
    }
    fseek(MemKernel_file, 0L, SEEK_END);
    uint32_t kernel_len = ftell(MemKernel_file);
    if(Layer_type==0)
        assert(kernel_len/8 == Kernel_size*Kernel_size*C*K*N/64);
    else if(Kernel_333==0)
        assert(kernel_len/8 == Kernel_size*(int(Kernel_size*C*N/64)+1)*K);
    else //3*3*3, int(27/8)+1=4
        assert(kernel_len/8 == 4*K);
    MemKernel = new uint64_t[kernel_len/8];
    rewind(MemKernel_file);
    x=fread(MemKernel,8,kernel_len/8,MemKernel_file);
    assert(x==kernel_len/8);
    cout << " From file : " << kernel_file_path << endl;
    cout << "\t" << x << " 64-bit Kernel data read in..." << endl;

    // Read in output data memory file
    FILE *Matlab_OutFmap_file;
    if ((Matlab_OutFmap_file = fopen(conv_file_path,"rb")) == NULL) {
        cout << "file open failed!: matlab_fmap_dat" << endl;
        return 0;
    }
    fseek(Matlab_OutFmap_file, 0L, SEEK_END);
    uint32_t outfmap_len = ftell(Matlab_OutFmap_file);
    assert(outfmap_len/4==H_count*W_count*K_count*8*16);
    OutFmap = new int32_t[outfmap_len/4];
    rewind(Matlab_OutFmap_file);
    x=fread(OutFmap,4,outfmap_len/4,Matlab_OutFmap_file);
    assert(x==outfmap_len/4);
    cout << " From file : " << conv_file_path << endl;
    cout << "\t" << x << " 32-bit Output FeatureMap data read in..." << endl;


    uint32_t FmapAddrBase_333[8]= {
        0, uint32_t(W_count*W_stride), uint32_t(H_count*H_stride),
        uint32_t(W_count*W_stride+H_count*H_stride), 0,0,0,0
    };
    uint32_t FmapAddrBase_n333[8] = {
        0, uint32_t(H_count*H_stride),
        uint32_t(2*H_count*H_stride), uint32_t(3*H_count*H_stride),
        uint32_t(W_count*W_stride), uint32_t(W_count*W_stride+H_count*H_stride),
        uint32_t(W_count*W_stride+2*H_count*H_stride), uint32_t(W_count*W_stride+3*H_count*H_stride)
    };
    if(Kernel_333)
        FmapAddrBase = FmapAddrBase_333;
    else
        FmapAddrBase = FmapAddrBase_n333;

    KernelSramAddr=0;
    uint32_t round_cnt = Kernel_333 ? 4 : Conv_CH_count*Kernel_size;//round cnt when completing 128 output point
    for(countK=0; countK<K_count; countK++, KernelSramAddr+=round_cnt*16*8) {
        for(countW=0, offsetW=0; countW<W_count; countW++, offsetW+=W_stride) {
            for(countH=0, offsetH=0; countH<H_count; countH++,offsetH+=H_stride,KernelSramAddr-=round_cnt*16*8) {
                for(int i=0; i<8; i++) {
                    FmapConvAddr[i] = FmapAddrBase[i] + offsetW + offsetH;
                    for(int j=0; j<16; j++) {
                        AccReg[i][j]=0;
                    }
                }
                uint64_t pe_lm_i[8];//8 row left matrix
                if(Kernel_333) { //input layer, kernel=3*3*3
                    for(int round=0; round<4; round++,KernelSramAddr+=16*8) {
                        switch(round) {
                        case 0:  //round1, W0H0C0 W0H0C1 W0H0C2 W0H1C0 W0H1C1 W0H1C2 W0H2C0 W0H2C1
                            for(int i=0; i<4; i++) {
                                FmapSramAddr[i] = FmapConvAddr[i];
                                uint64_t pe_lm1 = MemFmap[FmapSramAddr[i]>>3];
                                uint64_t pe_lm2 = MemFmap[(FmapSramAddr[i]>>3)+1];
                                uint64_t pe_lm3 = MemFmap[(FmapSramAddr[i]>>3)+2];
                                uint32_t bit_addr = 8*(FmapSramAddr[i] % 8);
                                uint64_t i1 = get_non_aligned_64bit(pe_lm1,pe_lm2,bit_addr);
                                uint64_t i2 = get_non_aligned_64bit(pe_lm2,pe_lm3,bit_addr);
                                pe_lm_i[2*i] = T0(i1,i2);
                                pe_lm_i[2*i+1] = T1(i1,i2);
                                FmapSramAddr[i] += 16;
                            }
                            break;
                        case 1:  //round2, W0H2C2 W1H0C0 W1H0C1 W1H0C2 W1H1C0 W1H1C1 W1H1C2 W1H2C0
                            for(int i=0; i<4; i++) {
                                uint64_t pe_lm1 = MemFmap[FmapSramAddr[i]>>3];
                                uint64_t tmp0 = (pe_lm1 >> (FmapSramAddr[i]%8)*8) &0xFFFF; //get 2bytes from sramaddr
                                FmapSramAddr[i] = FmapConvAddr[i]+3*(H+1);//1row was overlaped
                                uint64_t pe_lm2 = MemFmap[(FmapSramAddr[i]>>3)];
                                uint64_t pe_lm3 = MemFmap[(FmapSramAddr[i]>>3)+1];
                                uint64_t pe_lm4 = MemFmap[(FmapSramAddr[i]>>3)+2];
                                uint32_t bit_addr = 8*(FmapSramAddr[i] % 8);//from bit_addr, get 14Bytes
                                uint64_t tmp1 = get_non_aligned_64bit(pe_lm2,pe_lm3,bit_addr);
                                uint64_t tmp2 = get_non_aligned_64bit(pe_lm3,pe_lm4,bit_addr);
                                uint64_t i1 = tmp0 | tmp1<<16;
                                uint64_t i2 = tmp1>>(64-16) | tmp2<<16;
                                pe_lm_i[2*i] = T0(i1,i2);
                                pe_lm_i[2*i+1] = T1(i1,i2);
                                FmapSramAddr[i] += 14;
                            }
                            break;
                        case 2:  //round3, W1H2C1 W1H2C2 W2H0C0 W2H0C1 W2H0C2 W2H1C0 0 0
                            for(int i=0; i<4; i++) {
                                uint64_t pe_lm1 = MemFmap[FmapSramAddr[i]>>3];
                                uint64_t pe_lm2 = MemFmap[(FmapSramAddr[i]>>3)+1];
                                uint32_t bit_addr = 8*(FmapSramAddr[i] % 8);//from bit_addr, get 4bytes
                                uint64_t tmp0 = get_non_aligned_64bit(pe_lm1,pe_lm2,bit_addr) &0xFFFFFFFF;
                                FmapSramAddr[i] = FmapConvAddr[i]+3*(H+1)*2;
                                uint64_t pe_lm3 = MemFmap[FmapSramAddr[i]>>3];
                                uint64_t pe_lm4 = MemFmap[(FmapSramAddr[i]>>3)+1];
                                bit_addr = 8*(FmapSramAddr[i] % 8);//from bit_addr, get 8bytes
                                uint64_t tmp1 = get_non_aligned_64bit(pe_lm3,pe_lm4,bit_addr);
                                uint64_t i1 = tmp0 | tmp1<<32;
                                uint64_t i2 = tmp1>>32;
                                pe_lm_i[2*i] = T0(i1,i2);
                                pe_lm_i[2*i+1] = T1(i1,i2);
                                FmapSramAddr[i] += 8;
                            }
                            break;
                        case 3: //round4, W2H1C1 W2H1C2 W2H2C0 W2H2C1 W2H2C2  0  0  0
                            for(int i=0; i<4; i++) {
                                uint64_t pe_lm1 = MemFmap[FmapSramAddr[i]>>3];
                                uint64_t pe_lm2 = MemFmap[(FmapSramAddr[i]>>3)+1];
                                uint32_t bit_addr = 8*(FmapSramAddr[i] % 8);//from bit_addr, get 10bytes
                                uint64_t i1 = get_non_aligned_64bit(pe_lm1,pe_lm2,bit_addr);
                                uint64_t i2 = pe_lm2>>bit_addr & 0xffff;
                                pe_lm_i[2*i] = T0(i1,i2);
                                pe_lm_i[2*i+1] = T1(i1,i2);
                            }
                            break;
                        }

                        // 8x16 mac
                        for(int i=0; i<8; i++) {
                            pe_lm.i64 = pe_lm_i[i];
                            for(int pe=0; pe<16; pe++) {
                                int32_t mac,acc_mac;
                                pe_rm.i64 = MemKernel[(KernelSramAddr>>3)+pe];
                                switch(Data_type) {
                                case  1:
                                    mac = dot_2(pe_lm,pe_rm); //2bit
                                    break;
                                case  2:
                                    mac = dot_4(pe_lm,pe_rm); //4bit
                                    break;
                                case  3:
                                    mac = dot_8(pe_lm,pe_rm); //8bit
                                    break;
                                }
                                acc_mac = AccReg[i][pe] + mac;
                                if((~B(AccReg[i][pe],31))&(~B(mac,31))&B(acc_mac,31)) //upwardly overflow
                                    AccReg[i][pe] = INT_MAX;
                                else if(B(AccReg[i][pe],31)&B(mac,31)&(~B(acc_mac,31))) //downwardly overflow
                                    AccReg[i][pe] = INT_MIN;
                                else
                                    AccReg[i][pe] += mac;
                            }
                        }
                    }
                } else { //input layer(kernel!=3*3*3) and inter layer
                    for(conv_countW=0, conv_offsetW=0; conv_countW<Kernel_size; conv_countW++, conv_offsetW+=Conv_W_offset) {
                        for(conv_countCH=0, conv_offsetCH=0; conv_countCH<Conv_CH_count; conv_countCH++, conv_offsetCH+=8,KernelSramAddr+=16*8) {
                            for(int i=0; i<8; i++) {
                                FmapSramAddr[i] = FmapConvAddr[i] + conv_offsetW + conv_offsetCH;
                                if(Layer_type) { //input layer(kernel!=3*3*3), Non aligned 64bit
                                    uint64_t pe_lm1 = MemFmap[FmapSramAddr[i]>>3];
                                    uint64_t pe_lm2 = MemFmap[(FmapSramAddr[i]>>3)+1];
                                    uint32_t bit_addr = 8*(FmapSramAddr[i] % 8);
                                    pe_lm_i[i] = get_non_aligned_64bit(pe_lm1,pe_lm2,bit_addr);
                                } else { //inter layer, aligned 64bit
                                    pe_lm_i[i] = MemFmap[FmapSramAddr[i]>>3];
                                }
                            }
                            // 8x16 mac
                            for(int i=0; i<8; i++) {
                                pe_lm.i64 = pe_lm_i[i];
                                for(int pe=0; pe<16; pe++) {
                                    int32_t mac,acc_mac;
                                    pe_rm.i64 = MemKernel[(KernelSramAddr>>3)+pe];
                                    switch(Data_type) {
                                    case  1:
                                        mac = dot_2(pe_lm,pe_rm); //2bit
                                        break;
                                    case  2:
                                        mac = dot_4(pe_lm,pe_rm); //4bit
                                        break;
                                    case  3:
                                        mac = dot_8(pe_lm,pe_rm); //8bit
                                        break;
                                    }
                                    acc_mac = AccReg[i][pe] + mac;
                                    if((~B(AccReg[i][pe],31))&(~B(mac,31))&B(acc_mac,31)) //upwardly overflow
                                        AccReg[i][pe] = INT_MAX;
                                    else if(B(AccReg[i][pe],31)&B(mac,31)&(~B(acc_mac,31))) //downwardly overflow
                                        AccReg[i][pe] = INT_MIN;
                                    else
                                        AccReg[i][pe] += mac;
                                }
                            }
                        }
                    }
                }

                // when kernel is 3*3*3, 4 addr -> 8 row, Location Transform:
                //          -----------------------
                //          |0         |2         |
                //          |          |          |
                //          -----------------------
                //          |4         |6         |
                //          |          |          |
                //          -----------------------
                //          |1         |3         |
                //          |          |          |
                //          -----------------------
                //          |5         |7         |
                //          |          |          |
                //          -----------------------
                //write outfmap according to C->H->W dimension, accreg index -> output index
                if(Kernel_333) { // when intput kernel is 3*3*3
                    for(int row=0; row<8; row++) {
                        for(int pe=0; pe<16; pe++) {
                            uint32_t out_w;
                            uint32_t out_h;
                            switch(row) {
                            case(0):
                                out_w = countW;
                                out_h = countH;
                                break;
                            case(1):
                                out_w = countW;
                                out_h = countH + 2*H_count;
                                break;
                            case(2):
                                out_w = countW + W_count;
                                out_h = countH;
                                break;
                            case(3):
                                out_w = countW + W_count;
                                out_h = countH + 2*H_count;
                                break;
                            case(4):
                                out_w = countW;
                                out_h = countH + H_count;
                                break;
                            case(5):
                                out_w = countW;
                                out_h = countH + 3*H_count;
                                break;
                            case(6):
                                out_w = countW + W_count;
                                out_h = countH + H_count;
                                break;
                            case(7):
                                out_w = countW + W_count;
                                out_h = countH + 3*H_count;
                                break;
                            }
                            uint32_t out_k = 16*countK + pe;
                            outfmap_w[out_w][out_h][out_k] = AccReg[row][pe];
                            uint32_t idx = out_w*H_count*K_count*4*16+out_h*K_count*16+out_k;//k->h->w
                            outfmap_cmp[idx] = AccReg[row][pe];
                        }
                    }
                } else { // when intput kernel isn't 3*3*3
                    for(int row=0; row<8; row++) {
                        for(int pe=0; pe<16; pe++) {
                            uint32_t out_w = row>3 ? countW + W_count : countW;
                            uint32_t out_h = countH + (row%4)*H_count;
                            uint32_t out_k = 16*countK + pe;
                            outfmap_w[out_w][out_h][out_k] = AccReg[row][pe];
                            uint32_t idx = out_w*H_count*K_count*4*16+out_h*K_count*16+out_k;//k->h->w
                            outfmap_cmp[idx] = AccReg[row][pe];
                        }
                    }

                }
                //collect output and reform it to be outfmap
                for(int i=0; i<8; i++) {
                    for(int j=0; j<16; j++) {
                        AccReg_round[countK*W_count*H_count+countW*H_count+countH][i][j] = AccReg[i][j];
                    }
                }
            }
        }
    }

    //reshape AccReg_round, output outfmap_r, accreg index <= output index
    //not necessary, just check out outfmap_w
    if(!Kernel_333) {
        for(int wi=0; wi<2*W_count; wi++) {
            for(int hi=0; hi<4*H_count ; hi++) {
                for(int ki=0; ki<16*K_count; ki++) {
                    uint32_t part_idx = uint32_t(hi/H_count) + 4*uint32_t(wi/W_count); //which part of 8part
                    uint32_t pe_idx = ki%16;              //which pe
                    uint32_t h_part_count = hi - (part_idx%4)*H_count;    //countH in its part
                    uint32_t w_part_count = part_idx>3 ? wi-W_count : wi; //countW in its part
                    uint32_t round_idx = uint32_t(ki/16)*H_count*W_count + w_part_count*H_count + h_part_count;
                    outfmap_r[wi][hi][ki] = AccReg_round[round_idx][part_idx][pe_idx];
                }
            }
        }
        int cmp1 = memcmp(outfmap_w,outfmap_r,H_count*W_count*K_count*8*16*4);
        if(cmp1!=0) {
            cout << "Attention! the two output feature map are not consistent!!!" << endl;
        } else {
            cout << "the two form of output feature map are consistent, continue..." <<endl;
        }
    };

    int cmp2 = memcmp(outfmap_cmp,OutFmap,outfmap_len/4); //should be 0 if a==b
    cout << "\n-----------------------------------------------------" << endl;
    if(cmp2!=0) {
        cout << "Attention! the output feature map are not right!!!" << endl;
        int error_cnt=0;
        for(int i=0; i<outfmap_len/4; i++) {
            if(OutFmap[i]!=outfmap_cmp[i]) {
                error_cnt++;
            }
        }
        cout <<"error_cnt=" << error_cnt << endl;
    } else {
        cout << "----------- Correct!    Congratulations! ------------" << endl;
    }
    cout << "-----------------------------------------------------" << endl;
}



