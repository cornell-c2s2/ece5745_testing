
//------> /opt/MentorGraphics/catapult/pkgs/siflibs/ccs_in_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module ccs_in_wait_v1 (idat, rdy, ivld, dat, irdy, vld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  output             rdy;
  output             ivld;
  input  [width-1:0] dat;
  input              irdy;
  input              vld;

  wire   [width-1:0] idat;
  wire               rdy;
  wire               ivld;

  localparam stallOff = 0; 
  wire                  stall_ctrl;
  assign stall_ctrl = stallOff;

  assign idat = dat;
  assign rdy = irdy && !stall_ctrl;
  assign ivld = vld && !stall_ctrl;

endmodule


//------> /opt/MentorGraphics/catapult/pkgs/siflibs/ccs_out_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module ccs_out_wait_v1 (dat, irdy, vld, idat, rdy, ivld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] dat;
  output             irdy;
  output             vld;
  input  [width-1:0] idat;
  input              rdy;
  input              ivld;

  wire   [width-1:0] dat;
  wire               irdy;
  wire               vld;

  localparam stallOff = 0; 
  wire stall_ctrl;
  assign stall_ctrl = stallOff;

  assign dat = idat;
  assign irdy = rdy && !stall_ctrl;
  assign vld = ivld && !stall_ctrl;

endmodule



//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2021.1/950854 Production Release
//  HLS Date:       Mon Aug  2 21:36:02 PDT 2021
// 
//  Generated by:   afp65@en-ec-ecelinux-14.coecis.cornell.edu
//  Generated date: Tue May 17 17:50:47 2022
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module fletcher32_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [11:0] fsm_output;
  reg [11:0] fsm_output;


  // FSM State Type Declaration for fletcher32_core_core_fsm_1
  parameter
    core_rlp_C_0 = 4'd0,
    main_C_0 = 4'd1,
    main_C_1 = 4'd2,
    main_C_2 = 4'd3,
    main_C_3 = 4'd4,
    main_C_4 = 4'd5,
    main_C_5 = 4'd6,
    main_C_6 = 4'd7,
    main_C_7 = 4'd8,
    main_C_8 = 4'd9,
    main_C_9 = 4'd10,
    main_C_10 = 4'd11;

  reg [3:0] state_var;
  reg [3:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : fletcher32_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 12'b000000000010;
        state_var_NS = main_C_1;
      end
      main_C_1 : begin
        fsm_output = 12'b000000000100;
        state_var_NS = main_C_2;
      end
      main_C_2 : begin
        fsm_output = 12'b000000001000;
        state_var_NS = main_C_3;
      end
      main_C_3 : begin
        fsm_output = 12'b000000010000;
        state_var_NS = main_C_4;
      end
      main_C_4 : begin
        fsm_output = 12'b000000100000;
        state_var_NS = main_C_5;
      end
      main_C_5 : begin
        fsm_output = 12'b000001000000;
        state_var_NS = main_C_6;
      end
      main_C_6 : begin
        fsm_output = 12'b000010000000;
        state_var_NS = main_C_7;
      end
      main_C_7 : begin
        fsm_output = 12'b000100000000;
        state_var_NS = main_C_8;
      end
      main_C_8 : begin
        fsm_output = 12'b001000000000;
        state_var_NS = main_C_9;
      end
      main_C_9 : begin
        fsm_output = 12'b010000000000;
        state_var_NS = main_C_10;
      end
      main_C_10 : begin
        fsm_output = 12'b100000000000;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 12'b000000000001;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core_staller
// ------------------------------------------------------------------


module fletcher32_core_staller (
  core_wen, in_rsci_wen_comp, out_rsci_wen_comp
);
  output core_wen;
  input in_rsci_wen_comp;
  input out_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = in_rsci_wen_comp & out_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core_out_rsci_out_wait_ctrl
// ------------------------------------------------------------------


module fletcher32_core_out_rsci_out_wait_ctrl (
  out_rsci_iswt0, out_rsci_biwt, out_rsci_irdy
);
  input out_rsci_iswt0;
  output out_rsci_biwt;
  input out_rsci_irdy;



  // Interconnect Declarations for Component Instantiations 
  assign out_rsci_biwt = out_rsci_iswt0 & out_rsci_irdy;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core_in_rsci_in_wait_ctrl
// ------------------------------------------------------------------


module fletcher32_core_in_rsci_in_wait_ctrl (
  in_rsci_iswt0, in_rsci_biwt, in_rsci_ivld
);
  input in_rsci_iswt0;
  output in_rsci_biwt;
  input in_rsci_ivld;



  // Interconnect Declarations for Component Instantiations 
  assign in_rsci_biwt = in_rsci_iswt0 & in_rsci_ivld;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core_out_rsci
// ------------------------------------------------------------------


module fletcher32_core_out_rsci (
  out_rsc_dat, out_rsc_vld, out_rsc_rdy, out_rsci_oswt, out_rsci_wen_comp, out_rsci_idat
);
  output [31:0] out_rsc_dat;
  output out_rsc_vld;
  input out_rsc_rdy;
  input out_rsci_oswt;
  output out_rsci_wen_comp;
  input [31:0] out_rsci_idat;


  // Interconnect Declarations
  wire out_rsci_biwt;
  wire out_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  ccs_out_wait_v1 #(.rscid(32'sd2),
  .width(32'sd32)) out_rsci (
      .irdy(out_rsci_irdy),
      .ivld(out_rsci_oswt),
      .idat(out_rsci_idat),
      .rdy(out_rsc_rdy),
      .vld(out_rsc_vld),
      .dat(out_rsc_dat)
    );
  fletcher32_core_out_rsci_out_wait_ctrl fletcher32_core_out_rsci_out_wait_ctrl_inst
      (
      .out_rsci_iswt0(out_rsci_oswt),
      .out_rsci_biwt(out_rsci_biwt),
      .out_rsci_irdy(out_rsci_irdy)
    );
  assign out_rsci_wen_comp = (~ out_rsci_oswt) | out_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core_in_rsci
// ------------------------------------------------------------------


module fletcher32_core_in_rsci (
  in_rsc_dat, in_rsc_vld, in_rsc_rdy, in_rsci_oswt, in_rsci_wen_comp, in_rsci_idat_mxwt
);
  input [15:0] in_rsc_dat;
  input in_rsc_vld;
  output in_rsc_rdy;
  input in_rsci_oswt;
  output in_rsci_wen_comp;
  output [15:0] in_rsci_idat_mxwt;


  // Interconnect Declarations
  wire in_rsci_biwt;
  wire in_rsci_ivld;
  wire [15:0] in_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  ccs_in_wait_v1 #(.rscid(32'sd1),
  .width(32'sd16)) in_rsci (
      .rdy(in_rsc_rdy),
      .vld(in_rsc_vld),
      .dat(in_rsc_dat),
      .irdy(in_rsci_oswt),
      .ivld(in_rsci_ivld),
      .idat(in_rsci_idat)
    );
  fletcher32_core_in_rsci_in_wait_ctrl fletcher32_core_in_rsci_in_wait_ctrl_inst
      (
      .in_rsci_iswt0(in_rsci_oswt),
      .in_rsci_biwt(in_rsci_biwt),
      .in_rsci_ivld(in_rsci_ivld)
    );
  assign in_rsci_idat_mxwt = in_rsci_idat;
  assign in_rsci_wen_comp = (~ in_rsci_oswt) | in_rsci_biwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32_core
// ------------------------------------------------------------------


module fletcher32_core (
  clk, rst, in_rsc_dat, in_rsc_vld, in_rsc_rdy, out_rsc_dat, out_rsc_vld, out_rsc_rdy
);
  input clk;
  input rst;
  input [15:0] in_rsc_dat;
  input in_rsc_vld;
  output in_rsc_rdy;
  output [31:0] out_rsc_dat;
  output out_rsc_vld;
  input out_rsc_rdy;


  // Interconnect Declarations
  wire core_wen;
  wire in_rsci_wen_comp;
  wire [15:0] in_rsci_idat_mxwt;
  wire out_rsci_wen_comp;
  reg [15:0] out_rsci_idat_31_16;
  reg [15:0] out_rsci_idat_15_0;
  wire [11:0] fsm_output;
  wire or_dcpl_3;
  reg for_2_or_itm;
  reg [17:0] for_acc_1_psp_3_sva;
  wire and_42_cse;
  reg reg_out_rsci_iswt0_cse;
  reg reg_in_rsci_iswt0_cse;
  wire [15:0] z_out;
  wire [16:0] nl_z_out;
  reg [15:0] for_acc_7_itm;
  reg [15:0] for_acc_4_itm;
  reg [15:0] for_acc_8_itm;
  wire [15:0] for_acc_5_itm_mx0w1;
  wire [16:0] nl_for_acc_5_itm_mx0w1;
  wire [16:0] for_2_acc_1_psp_sva_1;
  wire [17:0] nl_for_2_acc_1_psp_sva_1;
  wire for_4_or_mx0w3;
  wire [17:0] for_acc_1_psp_3_sva_mx0w1;
  wire [18:0] nl_for_acc_1_psp_3_sva_mx0w1;
  wire [17:0] for_acc_1_psp_4_sva_mx0w2;
  wire [18:0] nl_for_acc_1_psp_4_sva_mx0w2;
  wire for_acc_1_psp_3_sva_mx0c2;

  wire for_8_xor_nl;
  wire[15:0] for_acc_8_nl;
  wire[16:0] nl_for_acc_8_nl;
  wire[15:0] for_acc_4_nl;
  wire[16:0] nl_for_acc_4_nl;
  wire for_2_or_nl;
  wire for_3_xor_nl;
  wire for_4_xor_nl;
  wire for_8_and_1_nl;
  wire or_24_nl;
  wire for_2_xor_nl;
  wire[15:0] for_mux_2_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [31:0] nl_fletcher32_core_out_rsci_inst_out_rsci_idat;
  assign nl_fletcher32_core_out_rsci_inst_out_rsci_idat = {out_rsci_idat_31_16 ,
      out_rsci_idat_15_0};
  fletcher32_core_in_rsci fletcher32_core_in_rsci_inst (
      .in_rsc_dat(in_rsc_dat),
      .in_rsc_vld(in_rsc_vld),
      .in_rsc_rdy(in_rsc_rdy),
      .in_rsci_oswt(reg_in_rsci_iswt0_cse),
      .in_rsci_wen_comp(in_rsci_wen_comp),
      .in_rsci_idat_mxwt(in_rsci_idat_mxwt)
    );
  fletcher32_core_out_rsci fletcher32_core_out_rsci_inst (
      .out_rsc_dat(out_rsc_dat),
      .out_rsc_vld(out_rsc_vld),
      .out_rsc_rdy(out_rsc_rdy),
      .out_rsci_oswt(reg_out_rsci_iswt0_cse),
      .out_rsci_wen_comp(out_rsci_wen_comp),
      .out_rsci_idat(nl_fletcher32_core_out_rsci_inst_out_rsci_idat[31:0])
    );
  fletcher32_core_staller fletcher32_core_staller_inst (
      .core_wen(core_wen),
      .in_rsci_wen_comp(in_rsci_wen_comp),
      .out_rsci_wen_comp(out_rsci_wen_comp)
    );
  fletcher32_core_core_fsm fletcher32_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign and_42_cse = core_wen & (fsm_output[10]);
  assign nl_for_acc_5_itm_mx0w1 = (for_acc_1_psp_4_sva_mx0w2[15:0]) + (for_acc_1_psp_3_sva[15:0]);
  assign for_acc_5_itm_mx0w1 = nl_for_acc_5_itm_mx0w1[15:0];
  assign nl_for_2_acc_1_psp_sva_1 = ({(for_acc_8_itm[15]) , for_acc_8_itm}) + conv_s2s_16_17(in_rsci_idat_mxwt);
  assign for_2_acc_1_psp_sva_1 = nl_for_2_acc_1_psp_sva_1[16:0];
  assign for_4_or_mx0w3 = (for_acc_1_psp_4_sva_mx0w2[14:0]!=15'b000000000000000);
  assign for_2_xor_nl = (for_acc_1_psp_3_sva[15]) ^ ((for_acc_1_psp_3_sva[16:15]==2'b01))
      ^ ((for_acc_1_psp_3_sva[16:15]==2'b10) & for_2_or_itm);
  assign nl_for_acc_1_psp_3_sva_mx0w1 = conv_s2s_17_18({for_2_xor_nl , (for_acc_1_psp_3_sva[15:0])})
      + conv_s2s_16_18(in_rsci_idat_mxwt);
  assign for_acc_1_psp_3_sva_mx0w1 = nl_for_acc_1_psp_3_sva_mx0w1[17:0];
  assign nl_for_acc_1_psp_4_sva_mx0w2 = conv_s2s_17_18({for_2_or_itm , (for_acc_1_psp_3_sva[15:0])})
      + conv_s2s_16_18(in_rsci_idat_mxwt);
  assign for_acc_1_psp_4_sva_mx0w2 = nl_for_acc_1_psp_4_sva_mx0w2[17:0];
  assign or_dcpl_3 = (fsm_output[7]) | (fsm_output[4]);
  assign for_acc_1_psp_3_sva_mx0c2 = or_dcpl_3 | (fsm_output[6]) | (fsm_output[8])
      | (fsm_output[5]);
  always @(posedge clk) begin
    if ( rst ) begin
      out_rsci_idat_15_0 <= 16'b0000000000000000;
      out_rsci_idat_31_16 <= 16'b0000000000000000;
    end
    else if ( and_42_cse ) begin
      out_rsci_idat_15_0 <= for_acc_1_psp_3_sva[15:0];
      out_rsci_idat_31_16 <= MUX_v_16_2_2(z_out, 16'b1111111111111111, for_8_xor_nl);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_out_rsci_iswt0_cse <= 1'b0;
      reg_in_rsci_iswt0_cse <= 1'b0;
      for_2_or_itm <= 1'b0;
      for_acc_7_itm <= 16'b0000000000000000;
    end
    else if ( core_wen ) begin
      reg_out_rsci_iswt0_cse <= fsm_output[10];
      reg_in_rsci_iswt0_cse <= ~((fsm_output[10:8]!=3'b000));
      for_2_or_itm <= MUX1HOT_s_1_5_2(for_2_or_nl, for_3_xor_nl, for_4_xor_nl, for_4_or_mx0w3,
          for_8_and_1_nl, {(fsm_output[2]) , (fsm_output[3]) , or_24_nl , (fsm_output[8])
          , (fsm_output[9])});
      for_acc_7_itm <= MUX_v_16_2_2(for_acc_5_itm_mx0w1, z_out, fsm_output[9]);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_acc_8_itm <= 16'b0000000000000000;
    end
    else if ( core_wen & ((fsm_output[1]) | (fsm_output[5])) ) begin
      for_acc_8_itm <= MUX_v_16_2_2(in_rsci_idat_mxwt, for_acc_8_nl, fsm_output[5]);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_acc_4_itm <= 16'b0000000000000000;
    end
    else if ( core_wen & ((fsm_output[6]) | (fsm_output[2])) ) begin
      for_acc_4_itm <= MUX_v_16_2_2(for_acc_4_nl, for_acc_5_itm_mx0w1, fsm_output[6]);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      for_acc_1_psp_3_sva <= 18'b000000000000000000;
    end
    else if ( core_wen & ((fsm_output[3:2]!=2'b00) | for_acc_1_psp_3_sva_mx0c2) )
        begin
      for_acc_1_psp_3_sva <= MUX1HOT_v_18_3_2(({1'b0 , for_2_acc_1_psp_sva_1}), for_acc_1_psp_3_sva_mx0w1,
          for_acc_1_psp_4_sva_mx0w2, {(fsm_output[2]) , (fsm_output[3]) , for_acc_1_psp_3_sva_mx0c2});
    end
  end
  assign for_8_xor_nl = (for_acc_1_psp_3_sva[15]) ^ ((for_acc_1_psp_3_sva[15]) &
      (~ (for_acc_1_psp_3_sva[17]))) ^ for_2_or_itm;
  assign for_2_or_nl = (for_2_acc_1_psp_sva_1[14:0]!=15'b000000000000000);
  assign for_3_xor_nl = (for_acc_1_psp_3_sva_mx0w1[15]) ^ ((for_acc_1_psp_3_sva_mx0w1[15])
      & (~ (for_acc_1_psp_3_sva_mx0w1[17]))) ^ ((for_acc_1_psp_3_sva_mx0w1[17]) &
      (~ (for_acc_1_psp_3_sva_mx0w1[15])) & ((for_acc_1_psp_3_sva_mx0w1[14:0]!=15'b000000000000000)));
  assign for_4_xor_nl = (for_acc_1_psp_4_sva_mx0w2[15]) ^ ((for_acc_1_psp_4_sva_mx0w2[15])
      & (~ (for_acc_1_psp_4_sva_mx0w2[17]))) ^ ((for_acc_1_psp_4_sva_mx0w2[17]) &
      (~ (for_acc_1_psp_4_sva_mx0w2[15])) & for_4_or_mx0w3);
  assign for_8_and_1_nl = (for_acc_1_psp_3_sva[17]) & (~ (for_acc_1_psp_3_sva[15]))
      & for_2_or_itm;
  assign or_24_nl = or_dcpl_3 | (fsm_output[6:5]!=2'b00);
  assign nl_for_acc_8_nl = for_acc_7_itm + for_acc_4_itm;
  assign for_acc_8_nl = nl_for_acc_8_nl[15:0];
  assign nl_for_acc_4_nl = (for_2_acc_1_psp_sva_1[15:0]) + for_acc_8_itm;
  assign for_acc_4_nl = nl_for_acc_4_nl[15:0];
  assign for_mux_2_nl = MUX_v_16_2_2(for_acc_8_itm, for_acc_4_itm, fsm_output[9]);
  assign nl_z_out = for_acc_7_itm + for_mux_2_nl;
  assign z_out = nl_z_out[15:0];

  function automatic  MUX1HOT_s_1_5_2;
    input  input_4;
    input  input_3;
    input  input_2;
    input  input_1;
    input  input_0;
    input [4:0] sel;
    reg  result;
  begin
    result = input_0 & sel[0];
    result = result | (input_1 & sel[1]);
    result = result | (input_2 & sel[2]);
    result = result | (input_3 & sel[3]);
    result = result | (input_4 & sel[4]);
    MUX1HOT_s_1_5_2 = result;
  end
  endfunction


  function automatic [17:0] MUX1HOT_v_18_3_2;
    input [17:0] input_2;
    input [17:0] input_1;
    input [17:0] input_0;
    input [2:0] sel;
    reg [17:0] result;
  begin
    result = input_0 & {18{sel[0]}};
    result = result | (input_1 & {18{sel[1]}});
    result = result | (input_2 & {18{sel[2]}});
    MUX1HOT_v_18_3_2 = result;
  end
  endfunction


  function automatic [15:0] MUX_v_16_2_2;
    input [15:0] input_0;
    input [15:0] input_1;
    input  sel;
    reg [15:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_16_2_2 = result;
  end
  endfunction


  function automatic [16:0] conv_s2s_16_17 ;
    input [15:0]  vector ;
  begin
    conv_s2s_16_17 = {vector[15], vector};
  end
  endfunction


  function automatic [17:0] conv_s2s_16_18 ;
    input [15:0]  vector ;
  begin
    conv_s2s_16_18 = {{2{vector[15]}}, vector};
  end
  endfunction


  function automatic [17:0] conv_s2s_17_18 ;
    input [16:0]  vector ;
  begin
    conv_s2s_17_18 = {vector[16], vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    fletcher32
// ------------------------------------------------------------------


module fletcher32 (
  clk, rst, in_rsc_dat, in_rsc_vld, in_rsc_rdy, out_rsc_dat, out_rsc_vld, out_rsc_rdy
);
  input clk;
  input rst;
  input [15:0] in_rsc_dat;
  input in_rsc_vld;
  output in_rsc_rdy;
  output [31:0] out_rsc_dat;
  output out_rsc_vld;
  input out_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  fletcher32_core fletcher32_core_inst (
      .clk(clk),
      .rst(rst),
      .in_rsc_dat(in_rsc_dat),
      .in_rsc_vld(in_rsc_vld),
      .in_rsc_rdy(in_rsc_rdy),
      .out_rsc_dat(out_rsc_dat),
      .out_rsc_vld(out_rsc_vld),
      .out_rsc_rdy(out_rsc_rdy)
    );
endmodule



