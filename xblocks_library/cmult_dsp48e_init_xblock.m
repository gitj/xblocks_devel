%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://casper.berkeley.edu                                                %      
%   Copyright (C) 2011 Suraj Gowda, Hong Chen                                 %
%                                                                             %
%   This program is free software; you can redistribute it and/or modify      %
%   it under the terms of the GNU General Public License as published by      %
%   the Free Software Foundation; either version 2 of the License, or         %
%   (at your option) any later version.                                       %
%                                                                             %
%   This program is distributed in the hope that it will be useful,           %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of            %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             %
%   GNU General Public License for more details.                              %
%                                                                             %
%   You should have received a copy of the GNU General Public License along   %
%   with this program; if not, write to the Free Software Foundation, Inc.,   %
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cmult_dsp48e_init_xblock(blk, n_bits_a, bin_pt_a, n_bits_b, bin_pt_b, conjugated, ...
	full_precision, n_bits_c, bin_pt_c, quantization, overflow, cast_latency)

% Validate input fields.
% Initialization script
if (n_bits_a < 1),
	disp([gcb,': Input ''a'' bit width must be greater than 0.']);
	return
end

if (n_bits_b < 1),
	disp([gcb, ': Input ''b'' bit width must be greater than 0.']);
	return
end

if (n_bits_c < 1),
	disp([gcb, ': Output ''c'' bit width must be greater than 0.']);
	return
end

if (n_bits_a > 25),
	disp([gcb, ': Input ''a'' bit width cannot exceed 25.']);
	return
end

if (n_bits_b > 18),
	disp([gcb, ': Input ''b'' bit width cannot exceed 18.']);
	return
end

if (bin_pt_a < 0),
	disp([gcb, ': Input ''a'' binary point must be greater than 0.']);
	return
end

if (bin_pt_b < 0),
	disp([gcb, ': Input ''b'' binary point must be greater than 0.']);
	return
end

if (bin_pt_c < 0),
	disp([gcb, ': Output ''c'' binary point must be greater than 0.']);
	return
end

if (bin_pt_a > n_bits_a),
  disp([gcb, ': Input ''a'' binary point cannot exceed bit width.']);
  return
end

if (bin_pt_b > n_bits_b),
  disp([gcb, ': Input ''b'' binary point cannot exceed bit width.']);
  return
end

if (bin_pt_c > n_bits_c),
  disp([gcb, ': Output ''c'' binary point cannot exceed bit width.']);
  return
end

bin_pt_reinterp = bin_pt_a + bin_pt_b;
if strcmp(full_precision, 'on'),
  n_bits_out = n_bits_a + n_bits_b + 1;
  bin_pt_out = bin_pt_a + bin_pt_b;
else
  n_bits_out = n_bits_c;
  bin_pt_out = bin_pt_c;
end


% Set conjugation mode.

if strcmp(conjugated, 'on'),
    alumode1_val = 1;
    carryin1_val = 1;
    alumode3_val = 0;
else
    alumode1_val = 0;
    carryin1_val = 0;
    alumode3_val = 3;
end


%% inports
a_re = xInport('a_re');
a_im = xInport('a_im');
b_re = xInport('b_re');
b_im = xInport('b_im');

%% outports
c_re = xOutport('c_re');
c_im = xOutport('c_im');

%% diagram
% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert
reinterp_a_im_out1 = xSignal;
Convert_out1 = xSignal;
Convert = xBlock(struct('source', 'Convert', 'name', 'Convert'), ...
                        struct('n_bits', 30, ...
                               'bin_pt', 0, ...
                               'pipeline', 'on'), ...
                        {reinterp_a_im_out1}, ...
                        {Convert_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert1
Convert1_out1 = xSignal;
Convert1 = xBlock(struct('source', 'Convert', 'name', 'Convert1'), ...
                         struct('n_bits', 30, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_a_im_out1}, ...
                         {Convert1_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert2
reinterp_a_re_out1 = xSignal;
Convert2_out1 = xSignal;
Convert2 = xBlock(struct('source', 'Convert', 'name', 'Convert2'), ...
                         struct('n_bits', 30, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_a_re_out1}, ...
                         {Convert2_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert3
reinterp_b_im_out1 = xSignal;
Convert3_out1 = xSignal;
Convert3 = xBlock(struct('source', 'Convert', 'name', 'Convert3'), ...
                         struct('n_bits', 18, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_b_im_out1}, ...
                         {Convert3_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert4
reinterp_b_re_out1 = xSignal;
Convert4_out1 = xSignal;
Convert4 = xBlock(struct('source', 'Convert', 'name', 'Convert4'), ...
                         struct('n_bits', 18, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_b_re_out1}, ...
                         {Convert4_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert5
Convert5_out1 = xSignal;
Convert5 = xBlock(struct('source', 'Convert', 'name', 'Convert5'), ...
                         struct('n_bits', 30, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_a_re_out1}, ...
                         {Convert5_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert6
Convert6_out1 = xSignal;
Convert6 = xBlock(struct('source', 'Convert', 'name', 'Convert6'), ...
                         struct('n_bits', 18, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_b_re_out1}, ...
                         {Convert6_out1});
                     
                     
                     
% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/Convert7
Convert7_out1 = xSignal;
Convert7 = xBlock(struct('source', 'Convert', 'name', 'Convert7'), ...
                         struct('n_bits', 18, ...
                                'bin_pt', 0, ...
                                'pipeline', 'on'), ...
                         {reinterp_b_im_out1}, ...
                         {Convert7_out1});


% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/DSP48E_0
opmode0_out1 = xSignal;
alumode0_out1 = xSignal;
carryin0_out1 = xSignal;
carryinsel0_out1 = xSignal;
DSP48E_0_out1 = xSignal;
DSP48E_0_out2 = xSignal;
DSP48E_0 = xBlock(struct('source', 'DSP48E', 'name', 'DSP48E_0'), ...
                         struct('use_pcout', 'on'), ...
                         {Convert5_out1, Convert7_out1, opmode0_out1, alumode0_out1, carryin0_out1, carryinsel0_out1}, ...
                         {DSP48E_0_out1, DSP48E_0_out2});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/DSP48E_1
opmode1_out1 = xSignal;
alumode1_out1 = xSignal;
carryin1_out1 = xSignal;
carryinsel1_out1 = xSignal;
DSP48E_1_out1 = xSignal;
DSP48E_1 = xBlock(struct('source', 'DSP48E', 'name', 'DSP48E_1'), ...
                         struct('use_pcin', 'on', ...
                                'pipeline_a', '2', ...
                                'pipeline_b', '2'), ...
                         {Convert1_out1, Convert6_out1, DSP48E_0_out2, opmode1_out1, alumode1_out1, carryin1_out1, carryinsel1_out1}, ...
                         {DSP48E_1_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/DSP48E_2
opmode2_out1 = xSignal;
alumode2_out1 = xSignal;
carryin2_out1 = xSignal;
carryinsel2_out1 = xSignal;
DSP48E_2_out1 = xSignal;
DSP48E_2_out2 = xSignal;
DSP48E_2 = xBlock(struct('source', 'DSP48E', 'name', 'DSP48E_2'), ...
                         struct('use_pcout', 'on'), ...
                         {Convert2_out1, Convert4_out1, opmode2_out1, alumode2_out1, carryin2_out1, carryinsel2_out1}, ...
                         {DSP48E_2_out1, DSP48E_2_out2});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/DSP48E_3
opmode3_out1 = xSignal;
alumode3_out1 = xSignal;
carryin3_out1 = xSignal;
carryinsel3_out1 = xSignal;
DSP48E_3_out1 = xSignal;
DSP48E_3 = xBlock(struct('source', 'DSP48E', 'name', 'DSP48E_3'), ...
                         struct('use_pcin', 'on', ...
                                'pipeline_a', '2', ...
                                'pipeline_b', '2'), ...
                         {Convert_out1, Convert3_out1, DSP48E_2_out2, opmode3_out1, alumode3_out1, carryin3_out1, carryinsel3_out1}, ...
                         {DSP48E_3_out1});



% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/alumode0
alumode0 = xBlock(struct('source', 'Constant', 'name', 'alumode0'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', 0, ...
                                'n_bits', 4, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {alumode0_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/alumode1
alumode1 = xBlock(struct('source', 'Constant', 'name', 'alumode1'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', alumode1_val, ...
                                'n_bits', 4, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {alumode1_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/alumode2
alumode2 = xBlock(struct('source', 'Constant', 'name', 'alumode2'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', 0, ...
                                'n_bits', 4, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {alumode2_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/alumode3
alumode3 = xBlock(struct('source', 'Constant', 'name', 'alumode3'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', alumode3_val, ...
                                'n_bits', 4, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {alumode3_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryin0
carryin0 = xBlock(struct('source', 'Constant', 'name', 'carryin0'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', 0, ...
                                'n_bits', 1, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {carryin0_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryin1
carryin1 = xBlock(struct('source', 'Constant', 'name', 'carryin1'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', carryin1_val, ...
                                'n_bits', 1, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {carryin1_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryin2
carryin2 = xBlock(struct('source', 'Constant', 'name', 'carryin2'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', 0, ...
                                'n_bits', 1, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {carryin2_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryin3
carryin3 = xBlock(struct('source', 'Constant', 'name', 'carryin3'), ...
                         struct('arith_type', 'Unsigned', ...
                                'const', 0, ...
                                'n_bits', 1, ...
                                'bin_pt', 0), ...
                         {}, ...
                         {carryin3_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryinsel0
carryinsel0 = xBlock(struct('source', 'Constant', 'name', 'carryinsel0'), ...
                            struct('arith_type', 'Unsigned', ...
                                   'const', 0, ...
                                   'n_bits', 3, ...
                                   'bin_pt', 0), ...
                            {}, ...
                            {carryinsel0_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryinsel1
carryinsel1 = xBlock(struct('source', 'Constant', 'name', 'carryinsel1'), ...
                            struct('arith_type', 'Unsigned', ...
                                   'const', 0, ...
                                   'n_bits', 3, ...
                                   'bin_pt', 0), ...
                            {}, ...
                            {carryinsel1_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryinsel2
carryinsel2 = xBlock(struct('source', 'Constant', 'name', 'carryinsel2'), ...
                            struct('arith_type', 'Unsigned', ...
                                   'const', 0, ...
                                   'n_bits', 3, ...
                                   'bin_pt', 0), ...
                            {}, ...
                            {carryinsel2_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/carryinsel3
carryinsel3 = xBlock(struct('source', 'Constant', 'name', 'carryinsel3'), ...
                            struct('arith_type', 'Unsigned', ...
                                   'const', 0, ...
                                   'n_bits', 3, ...
                                   'bin_pt', 0), ...
                            {}, ...
                            {carryinsel3_out1});

               
% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/cast_c_im
reinterp_c_im_out1 = xSignal;
cast_c_im = xBlock(struct('source', 'Convert', 'name', 'cast_c_im'), ...
                          struct('n_bits', n_bits_out, ...
                                 'bin_pt', bin_pt_out, ...
                                 'latency', cast_latency, ...
                                 'quantization', quantization, 'overflow', overflow, ...
                                 'pipeline', 'on'), ...
                          {reinterp_c_im_out1}, ...
                          {c_im});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/cast_c_re
reinterp_c_re_out1 = xSignal;
cast_c_re = xBlock(struct('source', 'Convert', 'name', 'cast_c_re'), ...
                          struct('n_bits', n_bits_out, ...
                                 'bin_pt', bin_pt_out, ...
                                 'latency', cast_latency, ...
                                 'quantization', quantization, 'overflow', overflow, ...
                                 'pipeline', 'on'), ...
                          {reinterp_c_re_out1}, ...
                          {c_re});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/opmode0
opmode0 = xBlock(struct('source', 'Constant', 'name', 'opmode0'), ...
                        struct('arith_type', 'Unsigned', ...
                               'const', 5, ...
                               'n_bits', 7, ...
                               'bin_pt', 0), ...
                        {}, ...
                        {opmode0_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/opmode1
opmode1 = xBlock(struct('source', 'Constant', 'name', 'opmode1'), ...
                        struct('arith_type', 'Unsigned', ...
                               'const', 21, ...
                               'n_bits', 7, ...
                               'bin_pt', 0), ...
                        {}, ...
                        {opmode1_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/opmode2
opmode2 = xBlock(struct('source', 'Constant', 'name', 'opmode2'), ...
                        struct('arith_type', 'Unsigned', ...
                               'const', 5, ...
                               'n_bits', 7, ...
                               'bin_pt', 0), ...
                        {}, ...
                        {opmode2_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/opmode3
opmode3 = xBlock(struct('source', 'Constant', 'name', 'opmode3'), ...
                        struct('arith_type', 'Unsigned', ...
                               'const', 21, ...
                               'n_bits', 7, ...
                               'bin_pt', 0), ...
                        {}, ...
                        {opmode3_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/realign_a_im
realign_a_im_out1 = xSignal;
realign_a_im = xBlock(struct('source', 'Convert', 'name', 'realign_a_im'), ...
                             struct('n_bits', n_bits_a, ...
                                    'bin_pt', bin_pt_a, ...
                                    'pipeline', 'on'), ...
                             {a_im}, ...
                             {realign_a_im_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/realign_a_re
realign_a_re_out1 = xSignal;
realign_a_re = xBlock(struct('source', 'Convert', 'name', 'realign_a_re'), ...
                             struct('n_bits', n_bits_a, ...
                                    'bin_pt', bin_pt_a, ...
                                    'pipeline', 'on'), ...
                             {a_re}, ...
                             {realign_a_re_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/realign_b_im
realign_b_im_out1 = xSignal;
realign_b_im = xBlock(struct('source', 'Convert', 'name', 'realign_b_im'), ...
                             struct('n_bits', n_bits_b, ...
                                    'bin_pt', bin_pt_b, ...
                                    'pipeline', 'on'), ...
                             {b_im}, ...
                             {realign_b_im_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/realign_b_re
realign_b_re_out1 = xSignal;
realign_b_re = xBlock(struct('source', 'Convert', 'name', 'realign_b_re'), ...
                             struct('n_bits', n_bits_b, ...
                                    'bin_pt', bin_pt_b, ...
                                    'pipeline', 'on'), ...
                             {b_re}, ...
                             {realign_b_re_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/reinterp_a_im
reinterp_a_im = xBlock(struct('source', 'Reinterpret', 'name', 'reinterp_a_im'), ...
                              struct('force_arith_type', 'on', ...
                                     'arith_type', 'Signed  (2''s comp)', ...
                                     'force_bin_pt', 'on'), ...
                              {realign_a_im_out1}, ...
                              {reinterp_a_im_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/reinterp_a_re
reinterp_a_re = xBlock(struct('source', 'Reinterpret', 'name', 'reinterp_a_re'), ...
                              struct('force_arith_type', 'on', ...
                                     'arith_type', 'Signed  (2''s comp)', ...
                                     'force_bin_pt', 'on'), ...
                              {realign_a_re_out1}, ...
                              {reinterp_a_re_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/reinterp_b_im
reinterp_b_im = xBlock(struct('source', 'Reinterpret', 'name', 'reinterp_b_im'), ...
                              struct('force_arith_type', 'on', ...
                                     'arith_type', 'Signed  (2''s comp)', ...
                                     'force_bin_pt', 'on'), ...
                              {realign_b_im_out1}, ...
                              {reinterp_b_im_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/reinterp_b_re
reinterp_b_re = xBlock(struct('source', 'Reinterpret', 'name', 'reinterp_b_re'), ...
                              struct('force_arith_type', 'on', ...
                                     'arith_type', 'Signed  (2''s comp)', ...
                                     'force_bin_pt', 'on'), ...
                              {realign_b_re_out1}, ...
                              {reinterp_b_re_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/reinterp_c_im
reinterp_c_im = xBlock(struct('source', 'Reinterpret', 'name', 'reinterp_c_im'), ...
                              struct('force_arith_type', 'on', ...
                                     'arith_type', 'Signed  (2''s comp)', ...
                                     'force_bin_pt', 'on', ...
                                     'bin_pt', bin_pt_reinterp), ...
                              {DSP48E_1_out1}, ...
                              {reinterp_c_im_out1});

% block: twiddle_dsp48e_test/twiddle_general_dsp48e/cmult/reinterp_c_re
reinterp_c_re = xBlock(struct('source', 'Reinterpret', 'name', 'reinterp_c_re'), ...
                              struct('force_arith_type', 'on', ...
                                     'arith_type', 'Signed  (2''s comp)', ...
                                     'force_bin_pt', 'on', ...
                                     'bin_pt', bin_pt_reinterp), ...
                              {DSP48E_3_out1}, ...
                              {reinterp_c_re_out1});


                          
if ~isempty(blk) && strcmp(blk(1),'/')
    % Set attribute format string (block annotation).
    annotation_fmt = '%d_%d * %d_%d ==> %d_%d\nLatency=%d';
    annotation = sprintf(annotation_fmt, ...
      n_bits_a, bin_pt_a, ...
      n_bits_b, bin_pt_b, ...
      n_bits_out, bin_pt_out, ...
      4+cast_latency);
    set_param(blk, 'AttributesFormatString', annotation);
end

end

