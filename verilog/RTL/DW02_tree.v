////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2000  - 2015 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Rick Kelly        07/28/2000
//
// VERSION:   Verilog Simulation Model for DW02_tree
//
// DesignWare_version: b8de2d39
// DesignWare_release: K-2015.06-DWBB_201506.3
//
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------
//
// ABSTRACT:  Wallace Tree Summer with Carry Save output
//
// MODIFIED:
//            Aamir Farooqui 7/11/02
//            Corrected parameter checking, simplied sim model, and X_processing
//
//------------------------------------------------------------------------------
//

`ifdef VCS
`include "vcs/DW02_tree.v"
`else

module DW02_tree( INPUT, OUT0, OUT1 );

// parameters
parameter num_inputs = 8;
parameter input_width = 8;
parameter verif_en = 1;

//-----------------------------------------------------------------------------
// ports
input [num_inputs*input_width-1 : 0]	INPUT;
output [input_width-1:0]		OUT0, OUT1;

//-----------------------------------------------------------------------------
// synopsys translate_off
reg    [input_width-1:0]		OII0OOOI, O001l0I0;

//-----------------------------------------------------------------------------
  
 
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
    
    if (num_inputs < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter num_inputs (lower bound: 1)",
	num_inputs );
    end
    
    if (input_width < 1) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter input_width (lower bound: 1)",
	input_width );
    end
    
    if ( (verif_en < 0) || (verif_en > 1) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter verif_en (legal range: 0 to 1)",
	verif_en );
    end
  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check 


  initial begin : verif_en_warning
    $display("The parameter verif_en is set to 0 for this simulator.\nOther values for verif_en are enabled only for VCS.");
  end // verif_en_warning

//-----------------------------------------------------------------------------



always @ (INPUT) begin : IIIIO1Ol
  reg [input_width-1 : 0] I0lII01I [0 : num_inputs-1];
  reg [input_width-1 : 0] l10III00 [0 : num_inputs-1];
  reg [input_width-1 : 0] IIIO00Ol, lI0OII0O;
  integer I1I1O00I, O1OIIOII, IlI01lIO;

  for (O1OIIOII=0 ; O1OIIOII < num_inputs ; O1OIIOII=O1OIIOII+1) begin
    for (IlI01lIO=0 ; IlI01lIO < input_width ; IlI01lIO=IlI01lIO+1) begin
      IIIO00Ol[IlI01lIO] = INPUT[O1OIIOII*input_width+IlI01lIO];
    end // for IlI01lIO
    I0lII01I[O1OIIOII] = IIIO00Ol;
  end // for O1OIIOII

  I1I1O00I = num_inputs;

  while (I1I1O00I > 2)
  begin
    for (O1OIIOII=0 ; O1OIIOII < (I1I1O00I/3) ; O1OIIOII = O1OIIOII+1) begin
      l10III00[O1OIIOII*2] = I0lII01I[O1OIIOII*3] ^ I0lII01I[O1OIIOII*3+1] ^ I0lII01I[O1OIIOII*3+2];

      lI0OII0O = (I0lII01I[O1OIIOII*3] & I0lII01I[O1OIIOII*3+1]) |
                     (I0lII01I[O1OIIOII*3+1] & I0lII01I[O1OIIOII*3+2]) |
                     (I0lII01I[O1OIIOII*3] & I0lII01I[O1OIIOII*3+2]);

      l10III00[O1OIIOII*2+1] = lI0OII0O << 1;
    end
    if ((I1I1O00I % 3) > 0) begin
      for (O1OIIOII=0 ; O1OIIOII < (I1I1O00I % 3) ; O1OIIOII = O1OIIOII + 1)
        l10III00[2 * (I1I1O00I/3) + O1OIIOII] = I0lII01I[3 * (I1I1O00I/3) + O1OIIOII];
    end

    for (O1OIIOII=0 ; O1OIIOII < num_inputs ; O1OIIOII = O1OIIOII + 1)
      I0lII01I[O1OIIOII] = l10III00[O1OIIOII];
    I1I1O00I = I1I1O00I - (I1I1O00I/3);
  end
  OII0OOOI <= I0lII01I[0];
  if (I1I1O00I > 1)
    O001l0I0 <= I0lII01I[1];
  else
    O001l0I0 <= {input_width{1'b0}};
end // IIIIO1Ol


assign OUT0 = (^(INPUT ^ INPUT) !== 1'b0) ? {input_width{1'bx}} : OII0OOOI;
assign OUT1 = (^(INPUT ^ INPUT) !== 1'b0) ? {input_width{1'bx}} : O001l0I0;

// synopsys translate_on

endmodule
`endif

