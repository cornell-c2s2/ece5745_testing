module SPI_v3_components_LoopThroughVRTL (
	clk,
	reset,
	sel,
	upstream_req_val,
	upstream_req_msg,
	upstream_req_rdy,
	upstream_resp_val,
	upstream_resp_msg,
	upstream_resp_rdy,
	downstream_req_val,
	downstream_req_msg,
	downstream_req_rdy,
	downstream_resp_val,
	downstream_resp_msg,
	downstream_resp_rdy
);
	parameter nbits = 32;
	input wire clk;
	input wire reset;
	input wire sel;
	input wire upstream_req_val;
	input wire [nbits - 1:0] upstream_req_msg;
	output wire upstream_req_rdy;
	output wire upstream_resp_val;
	output wire [nbits - 1:0] upstream_resp_msg;
	input wire upstream_resp_rdy;
	output wire downstream_req_val;
	output wire [nbits - 1:0] downstream_req_msg;
	input wire downstream_req_rdy;
	input wire downstream_resp_val;
	input wire [nbits - 1:0] downstream_resp_msg;
	output wire downstream_resp_rdy;
	assign upstream_resp_val = (sel ? upstream_req_val : downstream_resp_val);
	assign upstream_resp_msg = (sel ? upstream_req_msg : downstream_resp_msg);
	assign downstream_req_val = (sel ? 0 : upstream_req_val);
	assign downstream_req_msg = upstream_req_msg;
	assign upstream_req_rdy = (sel ? upstream_resp_rdy : downstream_req_rdy);
	assign downstream_resp_rdy = (sel ? 0 : upstream_resp_rdy);
endmodule
module ShiftReg (
	clk,
	in_,
	load_data,
	load_en,
	out,
	reset,
	shift_en
);
	parameter nbits = 8;
	input wire clk;
	input wire in_;
	input wire [nbits - 1:0] load_data;
	input wire load_en;
	output reg [nbits - 1:0] out;
	input wire reset;
	input wire shift_en;
	always @(posedge clk)
		if (reset)
			out <= {nbits {1'b0}};
		else if (load_en)
			out <= load_data;
		else if (~load_en & shift_en)
			out <= {out[nbits - 2:0], in_};
endmodule
module Synchronizer (
	clk,
	in_,
	negedge_,
	out,
	posedge_,
	reset
);
	parameter reset_value = 1'b0;
	input wire clk;
	input wire in_;
	output reg negedge_;
	output wire out;
	output reg posedge_;
	input wire reset;
	reg [2:0] shreg;
	always @(*) begin
		negedge_ = shreg[2] & ~shreg[1];
		posedge_ = ~shreg[2] & shreg[1];
	end
	always @(posedge clk)
		if (reset)
			shreg <= {3 {reset_value}};
		else
			shreg <= {shreg[1:0], in_};
	assign out = shreg[1];
endmodule
module SPI_v3_components_SPIMinionVRTL (
	clk,
	cs,
	miso,
	mosi,
	reset,
	sclk,
	pull_en,
	pull_msg,
	push_en,
	push_msg,
	parity
);
	parameter nbits = 8;
	input wire clk;
	input wire cs;
	output wire miso;
	input wire mosi;
	input wire reset;
	input wire sclk;
	output wire pull_en;
	input wire [nbits - 1:0] pull_msg;
	output wire push_en;
	output wire [nbits - 1:0] push_msg;
	output wire parity;
	wire cs_sync_clk;
	wire cs_sync_in_;
	wire cs_sync_negedge_;
	wire cs_sync_out;
	wire cs_sync_posedge_;
	wire cs_sync_reset;
	Synchronizer #(.reset_value(1'b1)) cs_sync(
		.clk(cs_sync_clk),
		.in_(cs_sync_in_),
		.negedge_(cs_sync_negedge_),
		.out(cs_sync_out),
		.posedge_(cs_sync_posedge_),
		.reset(cs_sync_reset)
	);
	wire mosi_sync_clk;
	wire mosi_sync_in_;
	wire mosi_sync_negedge_;
	wire mosi_sync_out;
	wire mosi_sync_posedge_;
	wire mosi_sync_reset;
	Synchronizer #(.reset_value(1'b0)) mosi_sync(
		.clk(mosi_sync_clk),
		.in_(mosi_sync_in_),
		.negedge_(mosi_sync_negedge_),
		.out(mosi_sync_out),
		.posedge_(mosi_sync_posedge_),
		.reset(mosi_sync_reset)
	);
	wire sclk_sync_clk;
	wire sclk_sync_in_;
	wire sclk_sync_negedge_;
	wire sclk_sync_out;
	wire sclk_sync_posedge_;
	wire sclk_sync_reset;
	Synchronizer #(.reset_value(1'b0)) sclk_sync(
		.clk(sclk_sync_clk),
		.in_(sclk_sync_in_),
		.negedge_(sclk_sync_negedge_),
		.out(sclk_sync_out),
		.posedge_(sclk_sync_posedge_),
		.reset(sclk_sync_reset)
	);
	wire shreg_in_clk;
	wire shreg_in_in_;
	wire [nbits - 1:0] shreg_in_load_data;
	wire shreg_in_load_en;
	wire [nbits - 1:0] shreg_in_out;
	wire shreg_in_reset;
	reg shreg_in_shift_en;
	ShiftReg #(.nbits(nbits)) shreg_in(
		.clk(shreg_in_clk),
		.in_(shreg_in_in_),
		.load_data(shreg_in_load_data),
		.load_en(shreg_in_load_en),
		.out(shreg_in_out),
		.reset(shreg_in_reset),
		.shift_en(shreg_in_shift_en)
	);
	wire shreg_out_clk;
	wire shreg_out_in_;
	wire [nbits - 1:0] shreg_out_load_data;
	wire shreg_out_load_en;
	wire [nbits - 1:0] shreg_out_out;
	wire shreg_out_reset;
	reg shreg_out_shift_en;
	ShiftReg #(.nbits(nbits)) shreg_out(
		.clk(shreg_out_clk),
		.in_(shreg_out_in_),
		.load_data(shreg_out_load_data),
		.load_en(shreg_out_load_en),
		.out(shreg_out_out),
		.reset(shreg_out_reset),
		.shift_en(shreg_out_shift_en)
	);
	always @(*) begin
		shreg_in_shift_en = ~cs_sync_out & sclk_sync_posedge_;
		shreg_out_shift_en = ~cs_sync_out & sclk_sync_negedge_;
	end
	assign cs_sync_clk = clk;
	assign cs_sync_reset = reset;
	assign cs_sync_in_ = cs;
	assign sclk_sync_clk = clk;
	assign sclk_sync_reset = reset;
	assign sclk_sync_in_ = sclk;
	assign mosi_sync_clk = clk;
	assign mosi_sync_reset = reset;
	assign mosi_sync_in_ = mosi;
	assign shreg_in_clk = clk;
	assign shreg_in_reset = reset;
	assign shreg_in_in_ = mosi_sync_out;
	assign shreg_in_load_en = 1'b0;
	assign shreg_in_load_data = {nbits {1'b0}};
	assign shreg_out_clk = clk;
	assign shreg_out_reset = reset;
	assign shreg_out_in_ = 1'b0;
	assign shreg_out_load_en = pull_en;
	assign shreg_out_load_data = pull_msg;
	assign miso = shreg_out_out[nbits - 1];
	assign pull_en = cs_sync_negedge_;
	assign push_en = cs_sync_posedge_;
	assign push_msg = shreg_in_out;
	assign parity = ^push_msg[nbits - 3:0] & push_en;
endmodule
module vc_Reg (
	clk,
	q,
	d
);
	parameter p_nbits = 1;
	input wire clk;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	always @(posedge clk) q <= d;
endmodule
module vc_ResetReg (
	clk,
	reset,
	q,
	d
);
	parameter p_nbits = 1;
	parameter p_reset_value = 0;
	input wire clk;
	input wire reset;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	always @(posedge clk) q <= (reset ? p_reset_value : d);
endmodule
module vc_EnReg (
	clk,
	reset,
	q,
	d,
	en
);
	parameter p_nbits = 1;
	input wire clk;
	input wire reset;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	input wire en;
	always @(posedge clk)
		if (en)
			q <= d;
endmodule
module vc_EnResetReg (
	clk,
	reset,
	q,
	d,
	en
);
	parameter p_nbits = 1;
	parameter p_reset_value = 0;
	input wire clk;
	input wire reset;
	output reg [p_nbits - 1:0] q;
	input wire [p_nbits - 1:0] d;
	input wire en;
	always @(posedge clk)
		if (reset || en)
			q <= (reset ? p_reset_value : d);
endmodule
module vc_Mux2 (
	in0,
	in1,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			1'd0: out = in0;
			1'd1: out = in1;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux3 (
	in0,
	in1,
	in2,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [1:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			2'd0: out = in0;
			2'd1: out = in1;
			2'd2: out = in2;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux4 (
	in0,
	in1,
	in2,
	in3,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [1:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			2'd0: out = in0;
			2'd1: out = in1;
			2'd2: out = in2;
			2'd3: out = in3;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux5 (
	in0,
	in1,
	in2,
	in3,
	in4,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux6 (
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [p_nbits - 1:0] in5;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			3'd5: out = in5;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux7 (
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [p_nbits - 1:0] in5;
	input wire [p_nbits - 1:0] in6;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			3'd5: out = in5;
			3'd6: out = in6;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Mux8 (
	in0,
	in1,
	in2,
	in3,
	in4,
	in5,
	in6,
	in7,
	sel,
	out
);
	parameter p_nbits = 1;
	input wire [p_nbits - 1:0] in0;
	input wire [p_nbits - 1:0] in1;
	input wire [p_nbits - 1:0] in2;
	input wire [p_nbits - 1:0] in3;
	input wire [p_nbits - 1:0] in4;
	input wire [p_nbits - 1:0] in5;
	input wire [p_nbits - 1:0] in6;
	input wire [p_nbits - 1:0] in7;
	input wire [2:0] sel;
	output reg [p_nbits - 1:0] out;
	always @(*)
		case (sel)
			3'd0: out = in0;
			3'd1: out = in1;
			3'd2: out = in2;
			3'd3: out = in3;
			3'd4: out = in4;
			3'd5: out = in5;
			3'd6: out = in6;
			3'd7: out = in7;
			default: out = {p_nbits {1'bx}};
		endcase
endmodule
module vc_Regfile_1r1w (
	clk,
	reset,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr;
	output wire [p_data_nbits - 1:0] read_data;
	input wire write_en;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [p_data_nbits - 1:0] write_data;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data = rfile[read_addr];
	always @(posedge clk)
		if (write_en)
			rfile[write_addr] <= write_data;
endmodule
module vc_ResetRegfile_1r1w (
	clk,
	reset,
	read_addr,
	read_data,
	write_en,
	write_addr,
	write_data
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter p_reset_value = 0;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr;
	output wire [p_data_nbits - 1:0] read_data;
	input wire write_en;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [p_data_nbits - 1:0] write_data;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data = rfile[read_addr];
	genvar i;
	generate
		for (i = 0; i < p_num_entries; i = i + 1) begin : wport
			always @(posedge clk)
				if (reset)
					rfile[i] <= p_reset_value;
				else if (write_en && (i[c_addr_nbits - 1:0] == write_addr))
					rfile[i] <= write_data;
		end
	endgenerate
endmodule
module vc_Regfile_2r1w (
	clk,
	reset,
	read_addr0,
	read_data0,
	read_addr1,
	read_data1,
	write_en,
	write_addr,
	write_data
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr0;
	output wire [p_data_nbits - 1:0] read_data0;
	input wire [c_addr_nbits - 1:0] read_addr1;
	output wire [p_data_nbits - 1:0] read_data1;
	input wire write_en;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [p_data_nbits - 1:0] write_data;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data0 = rfile[read_addr0];
	assign read_data1 = rfile[read_addr1];
	always @(posedge clk)
		if (write_en)
			rfile[write_addr] <= write_data;
endmodule
module vc_Regfile_2r2w (
	clk,
	reset,
	read_addr0,
	read_data0,
	read_addr1,
	read_data1,
	write_en0,
	write_addr0,
	write_data0,
	write_en1,
	write_addr1,
	write_data1
);
	parameter p_data_nbits = 1;
	parameter p_num_entries = 2;
	parameter c_addr_nbits = $clog2(p_num_entries);
	input wire clk;
	input wire reset;
	input wire [c_addr_nbits - 1:0] read_addr0;
	output wire [p_data_nbits - 1:0] read_data0;
	input wire [c_addr_nbits - 1:0] read_addr1;
	output wire [p_data_nbits - 1:0] read_data1;
	input wire write_en0;
	input wire [c_addr_nbits - 1:0] write_addr0;
	input wire [p_data_nbits - 1:0] write_data0;
	input wire write_en1;
	input wire [c_addr_nbits - 1:0] write_addr1;
	input wire [p_data_nbits - 1:0] write_data1;
	reg [p_data_nbits - 1:0] rfile [p_num_entries - 1:0];
	assign read_data0 = rfile[read_addr0];
	assign read_data1 = rfile[read_addr1];
	always @(posedge clk) begin
		if (write_en0)
			rfile[write_addr0] <= write_data0;
		if (write_en1)
			rfile[write_addr1] <= write_data1;
	end
endmodule
module vc_Regfile_2r1w_zero (
	clk,
	reset,
	rd_addr0,
	rd_data0,
	rd_addr1,
	rd_data1,
	wr_en,
	wr_addr,
	wr_data
);
	input wire clk;
	input wire reset;
	input wire [4:0] rd_addr0;
	output wire [31:0] rd_data0;
	input wire [4:0] rd_addr1;
	output wire [31:0] rd_data1;
	input wire wr_en;
	input wire [4:0] wr_addr;
	input wire [31:0] wr_data;
	wire [31:0] rf_read_data0;
	wire [31:0] rf_read_data1;
	vc_Regfile_2r1w #(
		.p_data_nbits(32),
		.p_num_entries(32)
	) rfile(
		.clk(clk),
		.reset(reset),
		.read_addr0(rd_addr0),
		.read_data0(rf_read_data0),
		.read_addr1(rd_addr1),
		.read_data1(rf_read_data1),
		.write_en(wr_en),
		.write_addr(wr_addr),
		.write_data(wr_data)
	);
	assign rd_data0 = (rd_addr0 == 5'd0 ? 32'd0 : rf_read_data0);
	assign rd_data1 = (rd_addr1 == 5'd0 ? 32'd0 : rf_read_data1);
endmodule
module vc_Trace (
	clk,
	reset
);
	input wire clk;
	input wire reset;
	integer len0;
	integer len1;
	integer idx0;
	integer idx1;
	localparam nchars = 512;
	localparam nbits = 4096;
	wire [4095:0] storage;
	integer cycles_next = 0;
	integer cycles = 0;
	reg [3:0] level;
	initial if (!$value$plusargs("trace=%d", level))
		level = 0;
	always @(posedge clk) cycles <= (reset ? 0 : cycles_next);
	task append_str;
		output reg [4095:0] trace;
		input reg [4095:0] str;
		begin
			len0 = 1;
			while (str[len0 * 8+:8] != 0) len0 = len0 + 1;
			idx0 = trace[31:0];
			for (idx1 = len0 - 1; idx1 >= 0; idx1 = idx1 - 1)
				begin
					trace[idx0 * 8+:8] = str[idx1 * 8+:8];
					idx0 = idx0 - 1;
				end
			trace[31:0] = idx0;
		end
	endtask
	task append_str_ljust;
		output reg [4095:0] trace;
		input reg [4095:0] str;
		begin
			idx0 = trace[31:0];
			idx1 = nchars;
			while (str[(idx1 * 8) - 1-:8] != 0) begin
				trace[idx0 * 8+:8] = str[(idx1 * 8) - 1-:8];
				idx0 = idx0 - 1;
				idx1 = idx1 - 1;
			end
			trace[31:0] = idx0;
		end
	endtask
	task append_chars;
		output reg [4095:0] trace;
		input reg [7:0] char;
		input integer num;
		begin
			idx0 = trace[31:0];
			for (idx1 = 0; idx1 < num; idx1 = idx1 + 1)
				begin
					trace[idx0 * 8+:8] = char;
					idx0 = idx0 - 1;
				end
			trace[31:0] = idx0;
		end
	endtask
	task append_val_str;
		output reg [4095:0] trace;
		input reg val;
		input reg [4095:0] str;
		begin
			len1 = 0;
			while (str[len1 * 8+:8] != 0) len1 = len1 + 1;
			if (val)
				append_str(trace, str);
			else if (!val)
				append_chars(trace, " ", len1);
			else begin
				append_str(trace, "x");
				append_chars(trace, " ", len1 - 1);
			end
		end
	endtask
	task append_val_rdy_str;
		output reg [4095:0] trace;
		input reg val;
		input reg rdy;
		input reg [4095:0] str;
		begin
			len1 = 0;
			while (str[len1 * 8+:8] != 0) len1 = len1 + 1;
			if (val & rdy)
				append_str(trace, str);
			else if (rdy && !val)
				append_chars(trace, " ", len1);
			else if (!rdy && !val) begin
				append_str(trace, ".");
				append_chars(trace, " ", len1 - 1);
			end
			else if (!rdy && val) begin
				append_str(trace, "#");
				append_chars(trace, " ", len1 - 1);
			end
			else begin
				append_str(trace, "x");
				append_chars(trace, " ", len1 - 1);
			end
		end
	endtask
endmodule
module vc_QueueCtrl1 (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	write_en,
	bypass_mux_sel,
	num_free_entries
);
	parameter p_type = 4'b0000;
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	output wire send_val;
	input wire send_rdy;
	output wire write_en;
	output wire bypass_mux_sel;
	output wire num_free_entries;
	reg full;
	wire full_next;
	always @(posedge clk) full <= (reset ? 1'b0 : full_next);
	assign num_free_entries = (full ? 1'b0 : 1'b1);
	localparam c_pipe_en = |(p_type & 4'b0001);
	localparam c_bypass_en = |(p_type & 4'b0010);
	wire do_enq;
	assign do_enq = recv_rdy && recv_val;
	wire do_deq;
	assign do_deq = send_rdy && send_val;
	wire empty;
	assign empty = ~full;
	wire do_pipe;
	assign do_pipe = ((c_pipe_en && full) && do_enq) && do_deq;
	wire do_bypass;
	assign do_bypass = ((c_bypass_en && empty) && do_enq) && do_deq;
	assign write_en = do_enq && ~do_bypass;
	assign bypass_mux_sel = empty;
	assign recv_rdy = ~full || ((c_pipe_en && full) && send_rdy);
	assign send_val = ~empty || ((c_bypass_en && empty) && recv_val);
	assign full_next = (do_deq && ~do_pipe ? 1'b0 : (do_enq && ~do_bypass ? 1'b1 : full));
endmodule
module vc_QueueDpath1 (
	clk,
	reset,
	write_en,
	bypass_mux_sel,
	recv_msg,
	send_msg
);
	parameter p_type = 4'b0000;
	parameter p_msg_nbits = 1;
	input wire clk;
	input wire reset;
	input wire write_en;
	input wire bypass_mux_sel;
	input wire [p_msg_nbits - 1:0] recv_msg;
	output wire [p_msg_nbits - 1:0] send_msg;
	wire [p_msg_nbits - 1:0] qstore;
	vc_EnReg #(.p_nbits(p_msg_nbits)) qstore_reg(
		.clk(clk),
		.reset(reset),
		.en(write_en),
		.d(recv_msg),
		.q(qstore)
	);
	generate
		if (|(p_type & 4'b0010)) begin : genblk1
			vc_Mux2 #(.p_nbits(p_msg_nbits)) bypass_mux(
				.in0(qstore),
				.in1(recv_msg),
				.sel(bypass_mux_sel),
				.out(send_msg)
			);
		end
		else begin : genblk1
			assign send_msg = qstore;
		end
	endgenerate
endmodule
module vc_QueueCtrl (
	clk,
	reset,
	recv_val,
	recv_rdy,
	send_val,
	send_rdy,
	write_en,
	write_addr,
	read_addr,
	bypass_mux_sel,
	num_free_entries
);
	parameter p_type = 4'b0000;
	parameter p_num_msgs = 2;
	parameter c_addr_nbits = $clog2(p_num_msgs);
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	output wire send_val;
	input wire send_rdy;
	output wire write_en;
	output wire [c_addr_nbits - 1:0] write_addr;
	output wire [c_addr_nbits - 1:0] read_addr;
	output wire bypass_mux_sel;
	output wire [c_addr_nbits:0] num_free_entries;
	wire [c_addr_nbits - 1:0] enq_ptr;
	wire [c_addr_nbits - 1:0] enq_ptr_next;
	vc_ResetReg #(.p_nbits(c_addr_nbits)) enq_ptr_reg(
		.clk(clk),
		.reset(reset),
		.d(enq_ptr_next),
		.q(enq_ptr)
	);
	wire [c_addr_nbits - 1:0] deq_ptr;
	wire [c_addr_nbits - 1:0] deq_ptr_next;
	vc_ResetReg #(.p_nbits(c_addr_nbits)) deq_ptr_reg(
		.clk(clk),
		.reset(reset),
		.d(deq_ptr_next),
		.q(deq_ptr)
	);
	assign write_addr = enq_ptr;
	assign read_addr = deq_ptr;
	wire full;
	wire full_next;
	vc_ResetReg #(.p_nbits(1)) full_reg(
		.clk(clk),
		.reset(reset),
		.d(full_next),
		.q(full)
	);
	localparam c_pipe_en = |(p_type & 4'b0001);
	localparam c_bypass_en = |(p_type & 4'b0010);
	wire do_enq;
	assign do_enq = recv_rdy && recv_val;
	wire do_deq;
	assign do_deq = send_rdy && send_val;
	wire empty;
	assign empty = ~full && (enq_ptr == deq_ptr);
	wire do_pipe;
	assign do_pipe = ((c_pipe_en && full) && do_enq) && do_deq;
	wire do_bypass;
	assign do_bypass = ((c_bypass_en && empty) && do_enq) && do_deq;
	assign write_en = do_enq && ~do_bypass;
	assign bypass_mux_sel = empty;
	assign recv_rdy = ~full || ((c_pipe_en && full) && send_rdy);
	assign send_val = ~empty || ((c_bypass_en && empty) && recv_val);
	wire [c_addr_nbits - 1:0] deq_ptr_plus1;
	assign deq_ptr_plus1 = deq_ptr + 1'b1;
	wire [c_addr_nbits - 1:0] deq_ptr_inc;
	assign deq_ptr_inc = (deq_ptr_plus1 == p_num_msgs ? {c_addr_nbits {1'b0}} : deq_ptr_plus1);
	wire [c_addr_nbits - 1:0] enq_ptr_plus1;
	assign enq_ptr_plus1 = enq_ptr + 1'b1;
	wire [c_addr_nbits - 1:0] enq_ptr_inc;
	assign enq_ptr_inc = (enq_ptr_plus1 == p_num_msgs ? {c_addr_nbits {1'b0}} : enq_ptr_plus1);
	assign deq_ptr_next = (do_deq && ~do_bypass ? deq_ptr_inc : deq_ptr);
	assign enq_ptr_next = (do_enq && ~do_bypass ? enq_ptr_inc : enq_ptr);
	assign full_next = ((do_enq && ~do_deq) && (enq_ptr_inc == deq_ptr) ? 1'b1 : ((do_deq && full) && ~do_pipe ? 1'b0 : full));
	assign num_free_entries = (full ? {c_addr_nbits + 1 {1'b0}} : (empty ? p_num_msgs[c_addr_nbits:0] : (enq_ptr > deq_ptr ? p_num_msgs[c_addr_nbits:0] - (enq_ptr - deq_ptr) : (deq_ptr > enq_ptr ? deq_ptr - enq_ptr : {c_addr_nbits + 1 {1'bx}}))));
endmodule
module vc_QueueDpath (
	clk,
	reset,
	write_en,
	bypass_mux_sel,
	write_addr,
	read_addr,
	recv_msg,
	send_msg
);
	parameter p_type = 4'b0000;
	parameter p_msg_nbits = 4;
	parameter p_num_msgs = 2;
	parameter c_addr_nbits = $clog2(p_num_msgs);
	input wire clk;
	input wire reset;
	input wire write_en;
	input wire bypass_mux_sel;
	input wire [c_addr_nbits - 1:0] write_addr;
	input wire [c_addr_nbits - 1:0] read_addr;
	input wire [p_msg_nbits - 1:0] recv_msg;
	output wire [p_msg_nbits - 1:0] send_msg;
	wire [p_msg_nbits - 1:0] read_data;
	vc_Regfile_1r1w #(
		.p_data_nbits(p_msg_nbits),
		.p_num_entries(p_num_msgs)
	) qstore(
		.clk(clk),
		.reset(reset),
		.read_addr(read_addr),
		.read_data(read_data),
		.write_en(write_en),
		.write_addr(write_addr),
		.write_data(recv_msg)
	);
	generate
		if (|(p_type & 4'b0010)) begin : genblk1
			vc_Mux2 #(.p_nbits(p_msg_nbits)) bypass_mux(
				.in0(read_data),
				.in1(recv_msg),
				.sel(bypass_mux_sel),
				.out(send_msg)
			);
		end
		else begin : genblk1
			assign send_msg = read_data;
		end
	endgenerate
endmodule
module vc_Queue (
	clk,
	reset,
	recv_val,
	recv_rdy,
	recv_msg,
	send_val,
	send_rdy,
	send_msg,
	num_free_entries
);
	parameter p_type = 4'b0000;
	parameter p_msg_nbits = 1;
	parameter p_num_msgs = 2;
	parameter c_addr_nbits = $clog2(p_num_msgs);
	input wire clk;
	input wire reset;
	input wire recv_val;
	output wire recv_rdy;
	input wire [p_msg_nbits - 1:0] recv_msg;
	output wire send_val;
	input wire send_rdy;
	output wire [p_msg_nbits - 1:0] send_msg;
	output wire [c_addr_nbits:0] num_free_entries;
	generate
		if (p_num_msgs == 1) begin : genblk1
			wire write_en;
			wire bypass_mux_sel;
			vc_QueueCtrl1 #(.p_type(p_type)) ctrl(
				.clk(clk),
				.reset(reset),
				.recv_val(recv_val),
				.recv_rdy(recv_rdy),
				.send_val(send_val),
				.send_rdy(send_rdy),
				.write_en(write_en),
				.bypass_mux_sel(bypass_mux_sel),
				.num_free_entries(num_free_entries)
			);
			vc_QueueDpath1 #(
				.p_type(p_type),
				.p_msg_nbits(p_msg_nbits)
			) dpath(
				.clk(clk),
				.reset(reset),
				.write_en(write_en),
				.bypass_mux_sel(bypass_mux_sel),
				.recv_msg(recv_msg),
				.send_msg(send_msg)
			);
		end
		else begin : genblk1
			wire write_en;
			wire bypass_mux_sel;
			wire [c_addr_nbits - 1:0] write_addr;
			wire [c_addr_nbits - 1:0] read_addr;
			vc_QueueCtrl #(
				.p_type(p_type),
				.p_num_msgs(p_num_msgs)
			) ctrl(
				.clk(clk),
				.reset(reset),
				.recv_val(recv_val),
				.recv_rdy(recv_rdy),
				.send_val(send_val),
				.send_rdy(send_rdy),
				.write_en(write_en),
				.write_addr(write_addr),
				.read_addr(read_addr),
				.bypass_mux_sel(bypass_mux_sel),
				.num_free_entries(num_free_entries)
			);
			vc_QueueDpath #(
				.p_type(p_type),
				.p_msg_nbits(p_msg_nbits),
				.p_num_msgs(p_num_msgs)
			) dpath(
				.clk(clk),
				.reset(reset),
				.write_en(write_en),
				.bypass_mux_sel(bypass_mux_sel),
				.write_addr(write_addr),
				.read_addr(read_addr),
				.recv_msg(recv_msg),
				.send_msg(send_msg)
			);
		end
	endgenerate
endmodule
module SPI_v3_components_SPIMinionAdapterVRTL (
	clk,
	reset,
	pull_en,
	pull_msg_val,
	pull_msg_spc,
	pull_msg_data,
	push_en,
	push_msg_val_wrt,
	push_msg_val_rd,
	push_msg_data,
	recv_msg,
	recv_rdy,
	recv_val,
	send_msg,
	send_rdy,
	send_val,
	parity
);
	parameter nbits = 8;
	parameter num_entries = 1;
	input wire clk;
	input wire reset;
	input wire pull_en;
	output reg pull_msg_val;
	output reg pull_msg_spc;
	output reg [nbits - 3:0] pull_msg_data;
	input wire push_en;
	input wire push_msg_val_wrt;
	input wire push_msg_val_rd;
	input wire [nbits - 3:0] push_msg_data;
	input wire [nbits - 3:0] recv_msg;
	output wire recv_rdy;
	input wire recv_val;
	output wire [nbits - 3:0] send_msg;
	input wire send_rdy;
	output wire send_val;
	output wire parity;
	reg open_entries;
	wire [$clog2(num_entries):0] cm_q_num_free;
	wire [nbits - 3:0] cm_q_send_msg;
	reg cm_q_send_rdy;
	wire cm_q_send_val;
	vc_Queue #(
		.p_type(4'b0000),
		.p_msg_nbits(nbits - 2),
		.p_num_msgs(num_entries)
	) cm_q(
		.clk(clk),
		.num_free_entries(cm_q_num_free),
		.reset(reset),
		.recv_msg(recv_msg),
		.recv_rdy(recv_rdy),
		.recv_val(recv_val),
		.send_msg(cm_q_send_msg),
		.send_rdy(cm_q_send_rdy),
		.send_val(cm_q_send_val)
	);
	wire [$clog2(num_entries):0] mc_q_num_free;
	wire mc_q_recv_rdy;
	reg mc_q_recv_val;
	vc_Queue #(
		.p_type(4'b0000),
		.p_msg_nbits(nbits - 2),
		.p_num_msgs(num_entries)
	) mc_q(
		.clk(clk),
		.num_free_entries(mc_q_num_free),
		.reset(reset),
		.recv_msg(push_msg_data),
		.recv_rdy(mc_q_recv_rdy),
		.recv_val(mc_q_recv_val),
		.send_msg(send_msg),
		.send_rdy(send_rdy),
		.send_val(send_val)
	);
	assign parity = ^send_msg & send_val;
	always @(*) begin : comb_block
		open_entries = mc_q_num_free > 1;
		mc_q_recv_val = push_msg_val_wrt & push_en;
		pull_msg_spc = mc_q_recv_rdy & (~mc_q_recv_val | open_entries);
		cm_q_send_rdy = push_msg_val_rd & pull_en;
		pull_msg_val = cm_q_send_rdy & cm_q_send_val;
		pull_msg_data = cm_q_send_msg & {nbits - 2 {pull_msg_val}};
	end
endmodule
module SPI_v3_components_SPIMinionAdapterCompositeVRTL (
	clk,
	cs,
	miso,
	mosi,
	reset,
	sclk,
	recv_msg,
	recv_rdy,
	recv_val,
	send_msg,
	send_rdy,
	send_val,
	minion_parity,
	adapter_parity
);
	parameter nbits = 8;
	parameter num_entries = 1;
	input wire clk;
	input wire cs;
	output wire miso;
	input wire mosi;
	input wire reset;
	input wire sclk;
	input wire [nbits - 3:0] recv_msg;
	output wire recv_rdy;
	input wire recv_val;
	output wire [nbits - 3:0] send_msg;
	input wire send_rdy;
	output wire send_val;
	output wire minion_parity;
	output wire adapter_parity;
	wire pull_en;
	wire pull_msg_val;
	wire pull_msg_spc;
	wire [nbits - 3:0] pull_msg_data;
	wire push_en;
	wire push_msg_val_wrt;
	wire push_msg_val_rd;
	wire [nbits - 3:0] push_msg_data;
	wire [nbits - 1:0] pull_msg;
	wire [nbits - 1:0] push_msg;
	SPI_v3_components_SPIMinionAdapterVRTL #(
		.nbits(nbits),
		.num_entries(num_entries)
	) adapter(
		.clk(clk),
		.reset(reset),
		.pull_en(pull_en),
		.pull_msg_val(pull_msg_val),
		.pull_msg_spc(pull_msg_spc),
		.pull_msg_data(pull_msg_data),
		.push_en(push_en),
		.push_msg_val_wrt(push_msg_val_wrt),
		.push_msg_val_rd(push_msg_val_rd),
		.push_msg_data(push_msg_data),
		.recv_msg(recv_msg),
		.recv_rdy(recv_rdy),
		.recv_val(recv_val),
		.send_msg(send_msg),
		.send_rdy(send_rdy),
		.send_val(send_val),
		.parity(adapter_parity)
	);
	SPI_v3_components_SPIMinionVRTL #(.nbits(nbits)) minion(
		.clk(clk),
		.cs(cs),
		.miso(miso),
		.mosi(mosi),
		.reset(reset),
		.sclk(sclk),
		.pull_en(pull_en),
		.pull_msg(pull_msg),
		.push_en(push_en),
		.push_msg(push_msg),
		.parity(minion_parity)
	);
	assign pull_msg[nbits - 1] = pull_msg_val;
	assign pull_msg[nbits - 2] = pull_msg_spc;
	assign pull_msg[nbits - 3:0] = pull_msg_data;
	assign push_msg_val_wrt = push_msg[nbits - 1];
	assign push_msg_val_rd = push_msg[nbits - 2];
	assign push_msg_data = push_msg[nbits - 3:0];
endmodule
module SPI_v3_components_SPIstackVRTL (
	clk,
	reset,
	loopthrough_sel,
	minion_parity,
	adapter_parity,
	sclk,
	cs,
	mosi,
	miso,
	send_val,
	send_msg,
	send_rdy,
	recv_val,
	recv_msg,
	recv_rdy
);
	parameter nbits = 34;
	parameter num_entries = 1;
	input wire clk;
	input wire reset;
	input wire loopthrough_sel;
	output wire minion_parity;
	output wire adapter_parity;
	input wire sclk;
	input wire cs;
	input wire mosi;
	output wire miso;
	output wire send_val;
	output wire [nbits - 3:0] send_msg;
	input wire send_rdy;
	input wire recv_val;
	input wire [nbits - 3:0] recv_msg;
	output wire recv_rdy;
	wire minion_out_val;
	wire [nbits - 3:0] minion_out_msg;
	wire minion_out_rdy;
	wire minion_in_val;
	wire [nbits - 3:0] minion_in_msg;
	wire minion_in_rdy;
	SPI_v3_components_SPIMinionAdapterCompositeVRTL #(
		.nbits(nbits),
		.num_entries(num_entries)
	) minion(
		.clk(clk),
		.reset(reset),
		.cs(cs),
		.miso(miso),
		.mosi(mosi),
		.sclk(sclk),
		.minion_parity(minion_parity),
		.adapter_parity(adapter_parity),
		.recv_val(minion_in_val),
		.recv_msg(minion_in_msg),
		.recv_rdy(minion_in_rdy),
		.send_val(minion_out_val),
		.send_msg(minion_out_msg),
		.send_rdy(minion_out_rdy)
	);
	SPI_v3_components_LoopThroughVRTL #(.nbits(nbits - 2)) loopthrough(
		.clk(clk),
		.reset(reset),
		.sel(loopthrough_sel),
		.upstream_req_val(minion_out_val),
		.upstream_req_msg(minion_out_msg),
		.upstream_req_rdy(minion_out_rdy),
		.upstream_resp_val(minion_in_val),
		.upstream_resp_msg(minion_in_msg),
		.upstream_resp_rdy(minion_in_rdy),
		.downstream_req_val(send_val),
		.downstream_req_msg(send_msg),
		.downstream_req_rdy(send_rdy),
		.downstream_resp_val(recv_val),
		.downstream_resp_msg(recv_msg),
		.downstream_resp_rdy(recv_rdy)
	);
endmodule
module MemoryEngine (
	clk,
	reset,
	recv_rdy,
	recv_val,
	recv_msg,
	send_rdy,
	send_val,
	send_msg
);
	parameter DATA_ENTRIES = 0;
	input clk;
	input reset;
	output wire recv_rdy;
	input wire recv_val;
	localparam FRAC_WIDTH = 8;
	localparam INT_WIDTH = 8;
	input [17:0] recv_msg;
	input wire send_rdy;
	output wire send_val;
	output wire [15:0] send_msg;
	wire [15:0] recv_msg_wrt_data;
	wire recv_msg_run;
	parameter MODE = 1;
	parameter RUN = 0;
	assign recv_msg_wrt_data = recv_msg[17:2];
	assign recv_msg_run = (recv_msg[1] && recv_msg[0]) && recv_val;
	reg [$clog2(DATA_ENTRIES) - 1:0] wrt_addr;
	always @(posedge clk)
		if (reset)
			wrt_addr <= 'b0;
		else if (recv_val && recv_rdy) begin
			if (recv_msg_run)
				wrt_addr <= 'b0;
			else
				wrt_addr <= wrt_addr + 1;
		end
		else
			wrt_addr <= wrt_addr;
	wire stop_output;
	wire counter_full;
	wire [15:0] data_temp;
	wire send_val_temp;
	assign send_msg = (send_val ? data_temp : 'b0);
	assign send_val = ~counter_full && send_val_temp;
	regfile_ReadRegfileDpath #(
		.DATA_WIDTH(16),
		.DATA_ENTRIES(DATA_ENTRIES)
	) dpath(
		.clk(clk),
		.reset(reset),
		.wrt_en(recv_val && ~recv_msg[1]),
		.stop_output(stop_output),
		.send_rdy(send_rdy),
		.wrt_addr(wrt_addr),
		.wrt_data(recv_msg_wrt_data),
		.data(data_temp),
		.counter_full(counter_full)
	);
	read_regfile_Cpath #(
		.DATA_WIDTH(16),
		.DATA_ENTRIES(DATA_ENTRIES)
	) cpath(
		.clk(clk),
		.reset(reset),
		.run(recv_msg_run),
		.counter_full(counter_full),
		.stop_output(stop_output),
		.send_val(send_val_temp),
		.recv_rdy(recv_rdy)
	);
endmodule
module regfile_ReadRegfileDpath (
	clk,
	reset,
	wrt_en,
	stop_output,
	send_rdy,
	wrt_addr,
	wrt_data,
	data,
	counter_full
);
	parameter DATA_WIDTH = 0;
	parameter DATA_ENTRIES = 0;
	input wire clk;
	input wire reset;
	input wire wrt_en;
	input wire stop_output;
	input wire send_rdy;
	input wire [$clog2(DATA_ENTRIES) - 1:0] wrt_addr;
	input wire [DATA_WIDTH - 1:0] wrt_data;
	output wire [DATA_WIDTH - 1:0] data;
	output wire counter_full;
	reg [$clog2(DATA_ENTRIES):0] counter;
	vc_Regfile_1r1w #(
		.p_data_nbits(DATA_WIDTH),
		.p_num_entries(DATA_ENTRIES)
	) regFile(
		.clk(clk),
		.reset(reset),
		.read_addr(counter[$clog2(DATA_ENTRIES) - 1:0]),
		.read_data(data),
		.write_en(wrt_en),
		.write_addr(wrt_addr),
		.write_data(wrt_data)
	);
	assign counter_full = counter == DATA_ENTRIES;
	always @(posedge clk)
		if (reset)
			counter <= 0;
		else if (send_rdy)
			counter <= (stop_output ? 'b0 : counter + 1);
		else
			counter <= (stop_output ? 'b0 : counter);
endmodule
module read_regfile_Cpath (
	clk,
	reset,
	run,
	counter_full,
	stop_output,
	send_val,
	recv_rdy
);
	parameter DATA_WIDTH = 0;
	parameter DATA_ENTRIES = 0;
	input wire clk;
	input wire reset;
	input wire run;
	input wire counter_full;
	output reg stop_output;
	output reg send_val;
	output reg recv_rdy;
	reg [31:0] state_reg;
	reg [31:0] state_next;
	always @(posedge clk)
		if (reset)
			state_reg <= 32'd0;
		else
			state_reg <= state_next;
	always @(*) begin
		state_next = state_reg;
		stop_output = 'b1;
		send_val = 'b0;
		recv_rdy = 'b0;
		case (state_reg)
			32'd0: begin
				recv_rdy = 1'b1;
				if (run)
					state_next = 32'd1;
			end
			32'd1: begin
				send_val = 'b1;
				if (counter_full)
					state_next = 32'd0;
				else
					stop_output = 'b0;
			end
			default: state_next = 32'd0;
		endcase
	end
endmodule
module MemoryEngineLat (
	clk,
	reset,
	recv_rdy,
	recv_val,
	recv_msg,
	send_rdy,
	send_val,
	send_msg
);
	parameter DATA_ENTRIES = 0;
	parameter DATA_LAT = 0;
	input clk;
	input reset;
	output wire recv_rdy;
	input wire recv_val;
	localparam FRAC_WIDTH = 8;
	localparam INT_WIDTH = 8;
	input [17:0] recv_msg;
	input wire send_rdy;
	output wire send_val;
	output wire [15:0] send_msg;
	wire [15:0] recv_msg_wrt_data;
	wire recv_msg_run;
	parameter MODE = 1;
	parameter RUN = 0;
	assign recv_msg_wrt_data = recv_msg[17:2];
	assign recv_msg_run = (recv_msg[1] && recv_msg[0]) && recv_val;
	reg [$clog2(DATA_ENTRIES) - 1:0] wrt_addr;
	wire stop_output;
	wire lat_en;
	wire counter_full;
	wire counter_lat_finish;
	always @(posedge clk)
		if (reset)
			wrt_addr <= 'b0;
		else if (recv_val && recv_rdy) begin
			if (recv_msg_run)
				wrt_addr <= 'b0;
			else
				wrt_addr <= wrt_addr + 1;
		end
		else
			wrt_addr <= wrt_addr;
	wire [15:0] data_temp;
	assign send_msg = (send_val ? data_temp : 'b0);
	regfile_ReadRegfileLatDpath #(
		.DATA_WIDTH(16),
		.DATA_ENTRIES(DATA_ENTRIES),
		.DATA_LAT(DATA_LAT)
	) dpath(
		.clk(clk),
		.reset(reset),
		.wrt_en(recv_val && ~recv_msg[1]),
		.stop_output(stop_output),
		.send_rdy(send_rdy),
		.wrt_addr(wrt_addr),
		.wrt_data(recv_msg_wrt_data),
		.data(data_temp),
		.counter_full(counter_full),
		.counter_lat_finish(counter_lat_finish),
		.lat_en(lat_en)
	);
	read_regfileLat_Cpath #(
		.DATA_WIDTH(16),
		.DATA_ENTRIES(DATA_ENTRIES)
	) cpath(
		.clk(clk),
		.reset(reset),
		.run(recv_msg_run),
		.counter_full(counter_full),
		.stop_output(stop_output),
		.counter_lat_finish(counter_lat_finish),
		.lat_en(lat_en),
		.send_val(send_val),
		.recv_rdy(recv_rdy)
	);
endmodule
module regfile_ReadRegfileLatDpath (
	clk,
	reset,
	wrt_en,
	lat_en,
	stop_output,
	send_rdy,
	wrt_addr,
	wrt_data,
	data,
	counter_full,
	counter_lat_finish
);
	parameter DATA_WIDTH = 0;
	parameter DATA_ENTRIES = 0;
	parameter DATA_LAT = 0;
	input wire clk;
	input wire reset;
	input wire wrt_en;
	input wire lat_en;
	input wire stop_output;
	input wire send_rdy;
	input wire [$clog2(DATA_ENTRIES) - 1:0] wrt_addr;
	input wire [DATA_WIDTH - 1:0] wrt_data;
	output wire [DATA_WIDTH - 1:0] data;
	output wire counter_full;
	output wire counter_lat_finish;
	reg [$clog2(DATA_ENTRIES) - 1:0] counter;
	reg [$clog2(DATA_ENTRIES) - 1:0] counter_lat;
	vc_Regfile_1r1w #(
		.p_data_nbits(DATA_WIDTH),
		.p_num_entries(DATA_ENTRIES)
	) regFile(
		.clk(clk),
		.reset(reset),
		.read_addr(counter),
		.read_data(data),
		.write_en(wrt_en),
		.write_addr(wrt_addr),
		.write_data(wrt_data)
	);
	assign counter_full = counter == (DATA_ENTRIES - 1);
	assign counter_lat_finish = counter_lat == DATA_LAT;
	always @(posedge clk)
		if (reset) begin
			counter <= 0;
			counter_lat <= 0;
		end
		else begin
			if (send_rdy)
				counter <= (stop_output ? 'b0 : counter + 1);
			else
				counter <= (stop_output ? 'b0 : counter);
			counter_lat <= (lat_en ? counter_lat + 1 : 'b0);
		end
endmodule
module read_regfileLat_Cpath (
	clk,
	reset,
	run,
	counter_full,
	counter_lat_finish,
	lat_en,
	stop_output,
	send_val,
	recv_rdy
);
	parameter DATA_WIDTH = 0;
	parameter DATA_ENTRIES = 0;
	input wire clk;
	input wire reset;
	input wire run;
	input wire counter_full;
	input wire counter_lat_finish;
	output reg lat_en;
	output reg stop_output;
	output reg send_val;
	output reg recv_rdy;
	reg [31:0] state_reg;
	reg [31:0] state_next;
	always @(posedge clk)
		if (reset)
			state_reg <= 32'd0;
		else
			state_reg <= state_next;
	always @(*) begin
		state_next = state_reg;
		stop_output = 'b1;
		lat_en = 'b0;
		send_val = 'b0;
		recv_rdy = 'b0;
		case (state_reg)
			32'd0: begin
				recv_rdy = 'b1;
				if (run)
					state_next = 32'd2;
			end
			32'd2: begin
				lat_en = 'b1;
				if (counter_lat_finish)
					state_next = 32'd1;
			end
			32'd1: begin
				send_val = 'b1;
				if (counter_full)
					state_next = 32'd0;
				else
					stop_output = 'b0;
			end
			default: state_next = 32'd0;
		endcase
	end
endmodule
module FixedMult (
	a,
	b,
	result
);
	parameter INT_WIDTH = 0;
	parameter FRAC_WIDTH = 0;
	input wire signed [(INT_WIDTH + FRAC_WIDTH) - 1:0] a;
	input wire signed [(INT_WIDTH + FRAC_WIDTH) - 1:0] b;
	output wire signed [(INT_WIDTH + FRAC_WIDTH) - 1:0] result;
	wire signed [(2 * (INT_WIDTH + FRAC_WIDTH)) - 1:0] partial;
	assign partial = a * b;
	assign result = partial[(INT_WIDTH + (2 * FRAC_WIDTH)) - 1:FRAC_WIDTH];
endmodule
module Pe (
	reset,
	clk,
	a,
	b,
	shift_result,
	finished,
	pass_shift_result,
	reg_finished,
	reg_pass_down,
	reg_pass_right
);
	parameter INT_WIDTH = 0;
	parameter FRAC_WIDTH = 0;
	input wire reset;
	input wire clk;
	input wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] a;
	input wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] b;
	input wire shift_result;
	input wire finished;
	output wire pass_shift_result;
	output reg reg_finished;
	output reg [(INT_WIDTH + FRAC_WIDTH) - 1:0] reg_pass_down;
	output reg [(INT_WIDTH + FRAC_WIDTH) - 1:0] reg_pass_right;
	assign pass_shift_result = shift_result;
	reg [(INT_WIDTH + FRAC_WIDTH) - 1:0] reg_output;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] fixed_mult_result;
	FixedMult #(
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH)
	) fixed_mult(
		.a(a),
		.b(b),
		.result(fixed_mult_result)
	);
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] sum_result;
	assign sum_result = reg_output + fixed_mult_result;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] reg_pass_down_in;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] reg_pass_right_in;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] reg_output_in;
	assign reg_pass_down_in = (shift_result ? reg_output : a);
	assign reg_pass_right_in = (shift_result ? reg_pass_right : b);
	assign reg_output_in = (shift_result ? 0 : (reg_finished ? reg_output : sum_result));
	always @(posedge clk)
		if (reset) begin
			reg_pass_down <= 0;
			reg_pass_right <= 0;
			reg_output <= 0;
			reg_finished <= 0;
		end
		else begin
			reg_finished <= finished;
			reg_output <= reg_output_in;
			reg_pass_down <= reg_pass_down_in;
			reg_pass_right <= reg_pass_right_in;
		end
endmodule
module SystolicMultControl (
	clk,
	reset,
	run,
	final_run,
	shift_result,
	finished,
	val,
	ready,
	produce_run
);
	parameter SYSTOLIC_SIZE = 0;
	parameter SYSTOLIC_STEP_SIZE = 0;
	input wire clk;
	input wire reset;
	input wire run;
	input wire final_run;
	output reg shift_result;
	output reg finished;
	output reg val;
	output reg ready;
	output reg produce_run;
	reg [$clog2(SYSTOLIC_STEP_SIZE * 2) - 1:0] count;
	reg count_start;
	always @(posedge clk)
		if (reset)
			count <= 'b0;
		else
			count <= (count_start ? count + 1'b1 : 0);
	reg [31:0] current_state;
	reg [31:0] next_state;
	wire run_done;
	assign run_done = (count == (SYSTOLIC_STEP_SIZE - 2)) && (current_state == 32'd1);
	wire finish_done;
	assign finish_done = (count == ((SYSTOLIC_STEP_SIZE - 2) + SYSTOLIC_SIZE)) && (current_state == 32'd3);
	always @(posedge clk)
		if (reset)
			current_state <= 32'd0;
		else
			current_state <= next_state;
	always @(*) begin
		next_state = current_state;
		shift_result = 'b0;
		finished = 'b0;
		count_start = 'b0;
		ready = 'b0;
		val = 'b0;
		produce_run = 'b0;
		case (current_state)
			32'd0: begin
				if (run)
					if (final_run)
						next_state = 32'd1;
					else
						next_state = 32'd2;
				ready = 'b1;
				shift_result = 'b1;
			end
			32'd2: begin
				ready = 'b1;
				if (final_run)
					next_state = 32'd1;
			end
			32'd1: begin
				if (run_done)
					next_state = 32'd3;
				count_start = 'b1;
			end
			32'd3: begin
				if (finish_done)
					next_state = 32'd4;
				finished = 'b1;
				count_start = 'b1;
			end
			32'd4: next_state = 32'd5;
			32'd5: begin
				next_state = 32'd6;
				shift_result = 1'b1;
			end
			32'd6: begin
				next_state = 32'd7;
				val = 'b1;
			end
			32'd7: begin
				next_state = 32'd8;
				val = 'b1;
			end
			32'd8: begin
				next_state = 32'd0;
				produce_run = 'b1;
			end
			default: next_state = 32'd0;
		endcase
	end
endmodule
module SystolicMult (
	reset,
	clk,
	recv_msg,
	recv_val,
	recv_rdy,
	send_msg,
	send_val,
	send_rdy,
	produce_run
);
	parameter INT_WIDTH = 0;
	parameter FRAC_WIDTH = 0;
	parameter SYSTOLIC_SIZE = 0;
	parameter SYSTOLIC_STEP_SIZE = 0;
	input wire reset;
	input wire clk;
	input wire [((INT_WIDTH + FRAC_WIDTH) * 4) + 2:0] recv_msg;
	input wire recv_val;
	output wire recv_rdy;
	output wire [((INT_WIDTH + FRAC_WIDTH) * 2) - 1:0] send_msg;
	output wire send_val;
	input wire send_rdy;
	output wire produce_run;
	wire finished;
	wire shift_result;
	SystolicMultControl #(
		.SYSTOLIC_SIZE(SYSTOLIC_SIZE),
		.SYSTOLIC_STEP_SIZE(SYSTOLIC_STEP_SIZE)
	) systolicMultControl(
		.clk(clk),
		.reset(reset),
		.run(recv_msg[1]),
		.final_run(recv_msg[0]),
		.shift_result(shift_result),
		.finished(finished),
		.val(send_val),
		.ready(recv_rdy),
		.produce_run(produce_run)
	);
	parameter NUM_INTERCONNECT_1D = (SYSTOLIC_SIZE - 1) * SYSTOLIC_SIZE;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] pass_a_0;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] pass_b_0;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] pass_a_1;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] pass_b_1;
	wire [SYSTOLIC_SIZE - 1:0] pass_shift_result;
	wire [SYSTOLIC_SIZE - 1:0] reg_finished;
	Pe #(
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH)
	) pe0(
		.clk(clk),
		.reset(reset),
		.a(recv_msg[((INT_WIDTH + FRAC_WIDTH) * 2) + 2:((INT_WIDTH + FRAC_WIDTH) * 1) + 3]),
		.b(recv_msg[((INT_WIDTH + FRAC_WIDTH) * 4) + 2:((INT_WIDTH + FRAC_WIDTH) * 3) + 3]),
		.shift_result(shift_result),
		.finished(finished),
		.pass_shift_result(pass_shift_result[0]),
		.reg_finished(reg_finished[0]),
		.reg_pass_down(pass_a_0),
		.reg_pass_right(pass_b_0)
	);
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] pe1_reg_pass_right;
	Pe #(
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH)
	) pe1(
		.clk(clk),
		.reset(reset),
		.a(recv_msg[((INT_WIDTH + FRAC_WIDTH) * 1) + 2:3]),
		.b(pass_b_0),
		.shift_result(pass_shift_result[0]),
		.finished(reg_finished[0]),
		.pass_shift_result(pass_shift_result[1]),
		.reg_finished(reg_finished[1]),
		.reg_pass_down(pass_a_1),
		.reg_pass_right(pe1_reg_pass_right)
	);
	wire pe2_pass_shift_result;
	wire pe2_reg_finished;
	Pe #(
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH)
	) pe2(
		.clk(clk),
		.reset(reset),
		.a(pass_a_0),
		.b(recv_msg[((INT_WIDTH + FRAC_WIDTH) * 3) + 2:((INT_WIDTH + FRAC_WIDTH) * 2) + 3]),
		.shift_result(pass_shift_result[0]),
		.finished(reg_finished[0]),
		.pass_shift_result(pe2_pass_shift_result),
		.reg_finished(pe2_reg_finished),
		.reg_pass_down(send_msg[((INT_WIDTH + FRAC_WIDTH) * 2) - 1:INT_WIDTH + FRAC_WIDTH]),
		.reg_pass_right(pass_b_1)
	);
	wire pe3_pass_shift_result;
	wire pe3_reg_finished;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] pe3_reg_pass_right;
	Pe #(
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH)
	) pe3(
		.clk(clk),
		.reset(reset),
		.a(pass_a_1),
		.b(pass_b_1),
		.shift_result(pass_shift_result[1]),
		.finished(reg_finished[1]),
		.pass_shift_result(pe3_pass_shift_result),
		.reg_finished(pe3_reg_finished),
		.reg_pass_down(send_msg[(INT_WIDTH + FRAC_WIDTH) - 1:0]),
		.reg_pass_right(pe3_reg_pass_right)
	);
endmodule
module Wrapper (
	clk,
	reset,
	send_rdy,
	send_val,
	send_msg,
	recv_val,
	recv_rdy,
	recv_msg
);
	parameter DATA_ENTRIES = 0;
	parameter DATA_LAT = 0;
	parameter INT_WIDTH = 0;
	parameter FRAC_WIDTH = 0;
	parameter SYSTOLIC_SIZE = 0;
	parameter SYSTOLIC_STEP_SIZE = 0;
	input clk;
	input reset;
	input wire send_rdy;
	output wire send_val;
	output wire [((INT_WIDTH + FRAC_WIDTH) * 2) - 1:0] send_msg;
	input wire recv_val;
	output wire recv_rdy;
	input [(INT_WIDTH + FRAC_WIDTH) + 6:0] recv_msg;
	wire [((INT_WIDTH + FRAC_WIDTH) * 4) + 2:0] systolic_mult_0_recv_msg;
	wire [((INT_WIDTH + FRAC_WIDTH) * 2) - 1:0] systolic_mult_0_send_msg;
	wire systolic_mult_0_send_val;
	wire systolic_mult_0_send_rdy;
	wire systolic_mult_0_recv_val;
	wire systolic_mult_0_recv_rdy;
	wire [(INT_WIDTH + FRAC_WIDTH) + 1:0] memory_engine_in_0_recv_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) + 1:0] memory_engine_in_1_recv_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) + 1:0] memory_engine_in_2_recv_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) + 1:0] memory_engine_in_3_recv_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] memory_engine_in_0_send_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] memory_engine_in_1_send_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] memory_engine_in_2_send_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] memory_engine_in_3_send_msg;
	wire memory_engine_in_0_send_val;
	wire memory_engine_in_1_send_val;
	wire memory_engine_in_2_send_val;
	wire memory_engine_in_3_send_val;
	wire memory_engine_in_0_send_rdy;
	wire memory_engine_in_1_send_rdy;
	wire memory_engine_in_2_send_rdy;
	wire memory_engine_in_3_send_rdy;
	wire memory_engine_in_0_recv_val;
	wire memory_engine_in_1_recv_val;
	wire memory_engine_in_2_recv_val;
	wire memory_engine_in_3_recv_val;
	wire memory_engine_in_0_recv_rdy;
	wire memory_engine_in_1_recv_rdy;
	wire memory_engine_in_2_recv_rdy;
	wire memory_engine_in_3_recv_rdy;
	wire [(INT_WIDTH + FRAC_WIDTH) + 1:0] memory_engine_out_0_recv_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] memory_engine_out_0_send_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) + 1:0] memory_engine_out_1_recv_msg;
	wire [(INT_WIDTH + FRAC_WIDTH) - 1:0] memory_engine_out_1_send_msg;
	wire memory_engine_out_0_send_val;
	wire memory_engine_out_1_send_val;
	wire memory_engine_out_0_send_rdy;
	wire memory_engine_out_1_send_rdy;
	wire memory_engine_out_0_recv_val;
	wire memory_engine_out_1_recv_val;
	wire memory_engine_out_0_recv_rdy;
	wire memory_engine_out_1_recv_rdy;
	assign send_val = memory_engine_out_0_send_val && memory_engine_out_1_send_val;
	assign recv_rdy = systolic_mult_0_recv_rdy && memory_engine_in_3_recv_rdy;
	assign send_msg[((INT_WIDTH + FRAC_WIDTH) * 2) - 1:(INT_WIDTH + FRAC_WIDTH) * 1] = memory_engine_out_0_send_msg;
	assign send_msg[((INT_WIDTH + FRAC_WIDTH) * 1) - 1:0] = memory_engine_out_1_send_msg;
	assign memory_engine_in_0_recv_msg[(INT_WIDTH + FRAC_WIDTH) + 1:2] = recv_msg[(INT_WIDTH + FRAC_WIDTH) + 6:7];
	assign memory_engine_in_0_recv_msg[1] = recv_msg[2];
	assign memory_engine_in_0_recv_msg[0] = recv_msg[1];
	wire memoryEngine_a_recv_rdy;
	wire memoryEngine_a_send_val;
	MemoryEngine #(.DATA_ENTRIES(DATA_ENTRIES)) memoryEngine_a(
		.clk(clk),
		.reset(reset),
		.recv_rdy(memoryEngine_a_recv_rdy),
		.recv_val((recv_val && recv_msg[3]) && recv_rdy),
		.recv_msg(memory_engine_in_0_recv_msg),
		.send_rdy(1'b1),
		.send_val(memoryEngine_a_send_val),
		.send_msg(memory_engine_in_0_send_msg)
	);
	assign memory_engine_in_1_recv_msg[(INT_WIDTH + FRAC_WIDTH) + 1:2] = recv_msg[(INT_WIDTH + FRAC_WIDTH) + 6:7];
	assign memory_engine_in_1_recv_msg[1] = recv_msg[2];
	assign memory_engine_in_1_recv_msg[0] = recv_msg[1];
	wire memoryEngineLat_a_recv_rdy;
	wire memoryEngineLat_a_send_val;
	MemoryEngineLat #(
		.DATA_ENTRIES(DATA_ENTRIES),
		.DATA_LAT(DATA_LAT)
	) memoryEngineLat_a(
		.clk(clk),
		.reset(reset),
		.recv_rdy(memoryEngineLat_a_recv_rdy),
		.recv_val((recv_val && recv_msg[4]) && recv_rdy),
		.recv_msg(memory_engine_in_1_recv_msg),
		.send_rdy(1'b1),
		.send_val(memoryEngineLat_a_send_val),
		.send_msg(memory_engine_in_1_send_msg)
	);
	assign memory_engine_in_2_recv_msg[(INT_WIDTH + FRAC_WIDTH) + 1:2] = recv_msg[(INT_WIDTH + FRAC_WIDTH) + 6:7];
	assign memory_engine_in_2_recv_msg[1] = recv_msg[2];
	assign memory_engine_in_2_recv_msg[0] = recv_msg[1];
	wire memoryEngine_b_recv_rdy;
	wire memoryEngine_b_send_val;
	MemoryEngine #(.DATA_ENTRIES(DATA_ENTRIES)) memoryEngine_b(
		.clk(clk),
		.reset(reset),
		.recv_rdy(memoryEngine_b_recv_rdy),
		.recv_val((recv_val && recv_msg[5]) && recv_rdy),
		.recv_msg(memory_engine_in_2_recv_msg),
		.send_rdy(1'b1),
		.send_val(memoryEngine_b_send_val),
		.send_msg(memory_engine_in_2_send_msg)
	);
	assign memory_engine_in_3_recv_msg[(INT_WIDTH + FRAC_WIDTH) + 1:2] = recv_msg[(INT_WIDTH + FRAC_WIDTH) + 6:7];
	assign memory_engine_in_3_recv_msg[1] = recv_msg[2];
	assign memory_engine_in_3_recv_msg[0] = recv_msg[1];
	wire memoryEngineLat_b_send_val;
	MemoryEngineLat #(
		.DATA_ENTRIES(DATA_ENTRIES),
		.DATA_LAT(DATA_LAT)
	) memoryEngineLat_b(
		.clk(clk),
		.reset(reset),
		.recv_rdy(memory_engine_in_3_recv_rdy),
		.recv_val((recv_val && recv_msg[6]) && recv_rdy),
		.recv_msg(memory_engine_in_3_recv_msg),
		.send_rdy(1'b1),
		.send_val(memoryEngineLat_b_send_val),
		.send_msg(memory_engine_in_3_send_msg)
	);
	wire produce_run;
	assign systolic_mult_0_recv_msg[((INT_WIDTH + FRAC_WIDTH) * 4) + 2:((INT_WIDTH + FRAC_WIDTH) * 3) + 3] = memory_engine_in_0_send_msg;
	assign systolic_mult_0_recv_msg[((INT_WIDTH + FRAC_WIDTH) * 3) + 2:((INT_WIDTH + FRAC_WIDTH) * 2) + 3] = memory_engine_in_1_send_msg;
	assign systolic_mult_0_recv_msg[((INT_WIDTH + FRAC_WIDTH) * 2) + 2:((INT_WIDTH + FRAC_WIDTH) * 1) + 3] = memory_engine_in_2_send_msg;
	assign systolic_mult_0_recv_msg[((INT_WIDTH + FRAC_WIDTH) * 1) + 2:3] = memory_engine_in_3_send_msg;
	assign systolic_mult_0_recv_msg[2] = recv_msg[2];
	assign systolic_mult_0_recv_msg[1] = recv_msg[1];
	assign systolic_mult_0_recv_msg[0] = recv_msg[0];
	wire systolicMult_recv_val;
	wire systolicMult_send_rdy;
	SystolicMult #(
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH),
		.SYSTOLIC_SIZE(SYSTOLIC_SIZE),
		.SYSTOLIC_STEP_SIZE(SYSTOLIC_STEP_SIZE)
	) systolicMult(
		.reset(reset),
		.clk(clk),
		.recv_msg(systolic_mult_0_recv_msg),
		.recv_rdy(systolic_mult_0_recv_rdy),
		.recv_val(systolicMult_recv_val),
		.send_msg(systolic_mult_0_send_msg),
		.produce_run(produce_run),
		.send_val(systolic_mult_0_send_val),
		.send_rdy(systolicMult_send_rdy)
	);
	assign memory_engine_out_0_recv_msg[(INT_WIDTH + FRAC_WIDTH) + 1:2] = systolic_mult_0_send_msg[((INT_WIDTH + FRAC_WIDTH) * 2) - 1:INT_WIDTH + FRAC_WIDTH];
	assign memory_engine_out_0_recv_msg[1] = produce_run;
	assign memory_engine_out_0_recv_msg[0] = produce_run;
	assign memory_engine_out_0_send_rdy = send_rdy;
	wire memoryEngineOut0_recv_rdy;
	MemoryEngine #(.DATA_ENTRIES(2)) memoryEngineOut0(
		.clk(clk),
		.reset(reset),
		.recv_rdy(memoryEngineOut0_recv_rdy),
		.recv_val(systolic_mult_0_send_val || produce_run),
		.recv_msg(memory_engine_out_0_recv_msg),
		.send_rdy(memory_engine_out_0_send_rdy),
		.send_val(memory_engine_out_0_send_val),
		.send_msg(memory_engine_out_0_send_msg)
	);
	assign memory_engine_out_1_recv_msg[(INT_WIDTH + FRAC_WIDTH) + 1:2] = systolic_mult_0_send_msg[((INT_WIDTH + FRAC_WIDTH) * 1) - 1:0];
	assign memory_engine_out_1_recv_msg[1] = produce_run;
	assign memory_engine_out_1_recv_msg[0] = produce_run;
	assign memory_engine_out_1_send_rdy = send_rdy;
	wire memoryEngineOut1_recv_rdy;
	MemoryEngine #(.DATA_ENTRIES(2)) memoryEngineOut1(
		.clk(clk),
		.reset(reset),
		.recv_rdy(memoryEngineOut1_recv_rdy),
		.recv_val(systolic_mult_0_send_val || produce_run),
		.recv_msg(memory_engine_out_1_recv_msg),
		.send_rdy(memory_engine_out_1_send_rdy),
		.send_val(memory_engine_out_1_send_val),
		.send_msg(memory_engine_out_1_send_msg)
	);
endmodule
module tapeout_block_test_WrapperVRTL (
	clk,
	reset,
	send_rdy,
	send_val,
	send_msg,
	recv_val,
	recv_rdy,
	recv_msg
);
	input clk;
	input reset;
	input wire send_rdy;
	output wire send_val;
	localparam FRAC_WIDTH = 8;
	localparam INT_WIDTH = 8;
	output wire [31:0] send_msg;
	input wire recv_val;
	output wire recv_rdy;
	input [31:0] recv_msg;
	localparam DATA_ENTRIES = 2;
	localparam DATA_LAT = 0;
	localparam SYSTOLIC_SIZE = 2;
	localparam SYSTOLIC_STEP_SIZE = DATA_ENTRIES;
	Wrapper #(
		.DATA_ENTRIES(DATA_ENTRIES),
		.DATA_LAT(DATA_LAT),
		.INT_WIDTH(INT_WIDTH),
		.FRAC_WIDTH(FRAC_WIDTH),
		.SYSTOLIC_SIZE(SYSTOLIC_SIZE),
		.SYSTOLIC_STEP_SIZE(SYSTOLIC_STEP_SIZE)
	) wrapper(
		.clk(clk),
		.reset(reset),
		.send_rdy(send_rdy),
		.send_val(send_val),
		.send_msg(send_msg),
		.recv_val(recv_val),
		.recv_rdy(recv_rdy),
		.recv_msg(recv_msg[22:0])
	);
endmodule
module tapeout_SPI_TapeOutBlockVRTL (
	clk,
	reset,
	loopthrough_sel,
	minion_parity,
	adapter_parity,
	sclk,
	cs,
	mosi,
	miso
);
	parameter nbits = 34;
	parameter num_entries = 5;
	input wire clk;
	input wire reset;
	input wire loopthrough_sel;
	output wire minion_parity;
	output wire adapter_parity;
	input wire sclk;
	input wire cs;
	input wire mosi;
	output wire miso;
	reg reset_presync;
	reg reset_sync;
	always @(posedge clk) begin
		reset_presync <= reset;
		reset_sync <= reset_presync;
	end
	parameter packet_nbits = nbits - 2;
	wire send_val;
	wire [packet_nbits - 1:0] send_msg;
	wire send_rdy;
	wire recv_val;
	wire [packet_nbits - 1:0] recv_msg;
	wire recv_rdy;
	SPI_v3_components_SPIstackVRTL #(
		.nbits(nbits),
		.num_entries(num_entries)
	) SPIstack(
		.clk(clk),
		.reset(reset_sync),
		.loopthrough_sel(loopthrough_sel),
		.minion_parity(minion_parity),
		.adapter_parity(adapter_parity),
		.sclk(sclk),
		.cs(cs),
		.mosi(mosi),
		.miso(miso),
		.send_val(send_val),
		.send_msg(send_msg),
		.send_rdy(send_rdy),
		.recv_val(recv_val),
		.recv_msg(recv_msg),
		.recv_rdy(recv_rdy)
	);
	tapeout_block_test_WrapperVRTL SystolicMult_SPI_Test(
		.clk(clk),
		.reset(reset_sync),
		.send_val(recv_val),
		.send_msg(recv_msg),
		.send_rdy(recv_rdy),
		.recv_val(send_val),
		.recv_msg((send_val ? send_msg : 23'b00000000000000000000000)),
		.recv_rdy(send_rdy)
	);
endmodule

module tapeout_SPI_TapeOutBlockVRTL_sv2v (
  output adapter_parity,
  input  clk,
  input  loopthrough_sel,
  output minion_parity,
  input  reset,
  input  spi_min_cs,
  output spi_min_miso,
  input  spi_min_mosi,
  input  spi_min_sclk
);
tapeout_SPI_TapeOutBlockVRTL #(
  .nbits(34),
  .num_entries(5)
) v(
  .adapter_parity(adapter_parity),
  .clk(clk),
  .loopthrough_sel(loopthrough_sel),
  .minion_parity(minion_parity),
  .reset(reset),
  .cs(spi_min_cs),
  .miso(spi_min_miso),
  .mosi(spi_min_mosi),
  .sclk(spi_min_sclk)
);
endmodule

