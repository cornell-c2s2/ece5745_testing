`ifndef TOP_WRAPPERVRTL_V
`define TOP_WRAPPERVRTL_V

`include "systolic_accelerator/top/Wrapper.v"
`include "systolic_accelerator/msg_structs/wrapper_msg.v"

module systolic_accelerator_top_Wrapper2DLineTracingVRTL
(
  input clk,
  input reset,

  input logic send_rdy, // TODO, need halt
  output logic send_val,
  output wrapper_send_msg send_msg,

  input logic recv_val,
  output logic recv_rdy,
  input wrapper_recv_msg recv_msg // share by 4
);

Wrapper #
(
  DATA_ENTRIES,
  DATA_LAT,

  INT_WIDTH,
	FRAC_WIDTH,
  SYSTOLIC_SIZE,
  SYSTOLIC_STEP_SIZE
) wrapper
(
  .clk(clk),
  .reset(reset),
  .send_rdy(send_rdy),
  .send_val(send_val),
  .send_msg(send_msg),
  .recv_val(recv_val),
  .recv_rdy(recv_rdy),
  .recv_msg(recv_msg)
);

// 2D
`ifndef SYNTHESIS

logic [`VC_TRACE_NBITS-1:0] str;
`VC_TRACE_BEGIN
begin

  // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
  // Define line trace here
  // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/
  $sformat( str, "------------------------------------------\n"  );
  vc_trace.append_str( trace_str, str );
  
  $sformat( str, "       data     addr val\n");
  vc_trace.append_str( trace_str, str );
  $sformat( str, "  me0: %x  %x    %x\n", wrapper.memoryEngine_a.dpath.regFile.write_data, wrapper.memoryEngine_a.dpath.regFile.write_addr, wrapper.memoryEngine_a.dpath.regFile.write_en);
  vc_trace.append_str( trace_str, str );
  $sformat( str, "  me1: %x  %x    %x\n", wrapper.memoryEngineLat_a.dpath.regFile.write_data, wrapper.memoryEngineLat_a.dpath.regFile.write_addr,  wrapper.memoryEngineLat_a.dpath.regFile.write_en);
  vc_trace.append_str( trace_str, str );
  $sformat( str, "  me2: %x  %x    %x\n", wrapper.memoryEngine_b.dpath.regFile.write_data, wrapper.memoryEngine_b.dpath.regFile.write_addr, wrapper.memoryEngine_b.dpath.regFile.write_en);
  vc_trace.append_str( trace_str, str );
  $sformat( str, "  me3: %x  %x    %x\n", wrapper.memoryEngineLat_b.dpath.regFile.write_data, wrapper.memoryEngineLat_b.dpath.regFile.write_addr, wrapper.memoryEngineLat_b.dpath.regFile.write_en);
  vc_trace.append_str( trace_str, str );

  $sformat( str, "\n");
  vc_trace.append_str( trace_str, str );
  $sformat( str, "               %x               %x\n", wrapper.systolicMult.pe0.a, wrapper.systolicMult.pe1.a  );
  vc_trace.append_str( trace_str, str );
  // $sformat( str, "           |              |\n"  );
  // vc_trace.append_str( trace_str, str );
//   $sformat( str, "             -----+-----         -----+-----\n"  );
  $sformat( str, "\n"  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "     %x | %x |   %x | %x |\n", wrapper.systolicMult.pe0.b, wrapper.systolicMult.pe0.sum_result, wrapper.systolicMult.pe1.b, wrapper.systolicMult.pe1.sum_result  );
  vc_trace.append_str( trace_str, str );
//   $sformat( str, "             -----+-----         -----+-----\n\n"  );
  $sformat( str, "\n\n"  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "               %x               %x\n", wrapper.systolicMult.pe2.a, wrapper.systolicMult.pe3.a    );
  vc_trace.append_str( trace_str, str );
  // $sformat( str, "           |              |\n"  );
  // vc_trace.append_str( trace_str, str );
//   $sformat( str, "             -----+-----         -----+-----\n"  );
  $sformat( str, "\n"  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "     %x | %x |   %x | %x |\n", wrapper.systolicMult.pe2.b, wrapper.systolicMult.pe2.sum_result, wrapper.systolicMult.pe3.b, wrapper.systolicMult.pe3.sum_result  );
  vc_trace.append_str( trace_str, str );
//   $sformat( str, "             -----+-----         -----+-----\n"  );
  $sformat( str, "\n"  );
  vc_trace.append_str( trace_str, str );
  $sformat( str, "       out_0   out_1   val\n");
  vc_trace.append_str( trace_str, str );
  $sformat( str, "  out: %x %x %x\n", wrapper.send_msg.result_0, wrapper.send_msg.result_1, wrapper.send_val);
  vc_trace.append_str( trace_str, str );
  //$sformat( str, "       ----+----       ----+----\n"  );
  //vc_trace.append_str( trace_str, str );

end
`VC_TRACE_END

`endif /* SYNTHESIS */

// // 1D
// `ifndef SYNTHESIS

// logic [`VC_TRACE_NBITS-1:0] str;
// `VC_TRACE_BEGIN
// begin

//   // ''' LAB TASK ''''''''''''''''''''''''''''''''''''''''''''''''''''''
//   // Define line trace here
//   // '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''\/
//   $sformat( str, "wr:%b:%x:%x:%x:%x", recv_msg.chip_select, recv_msg.data, recv_msg.mode, recv_msg.run, recv_msg.final_run);
//   vc_trace.append_val_rdy_str( trace_str, recv_val, recv_rdy, str );
//   $sformat( str, " > " );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, "(" );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, "PE00:%x:%x:%x", wrapper.systolicMult.pe0.a, wrapper.systolicMult.pe0.b, wrapper.systolicMult.pe0.sum_result  );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, "|PE01:%x:%x:%x", wrapper.systolicMult.pe1.a, wrapper.systolicMult.pe1.b, wrapper.systolicMult.pe1.sum_result  );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, "|PE10:%x:%x:%x", wrapper.systolicMult.pe2.a, wrapper.systolicMult.pe2.b, wrapper.systolicMult.pe2.sum_result  );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, "|PE11:%x:%x:%x", wrapper.systolicMult.pe3.a, wrapper.systolicMult.pe3.b, wrapper.systolicMult.pe3.sum_result  );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, ") > " );
//   vc_trace.append_str( trace_str, str );
//   $sformat( str, "rd:%x:%x", send_msg.result_0, send_msg.result_1);
//   vc_trace.append_val_rdy_str( trace_str, send_val, send_rdy, str );

// end
// `VC_TRACE_END

// `endif /* SYNTHESIS */
endmodule

`endif /* TOP_WRAPPERVRTL_V */
