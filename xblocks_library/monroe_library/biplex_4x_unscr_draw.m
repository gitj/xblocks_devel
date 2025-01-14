function biplex_4x_unscr_draw(FFTSize, bram_latency, input_bit_width, reorder_din_latency)
% This is a generated function based on subsystem:
%     bi_real_unscr_4x_plan/biplex_4x_unscr
% Though there are limitations about the generated script, 
% the main purpose of this utility is to make learning
% Sysgen Script easier.
% 
% To test it, run the following commands from MATLAB console:
% cfg.source = str2func('biplex_4x_unscr');
% cfg.toplevel = 'bi_real_unscr_4x_plan/biplex_4x_unscr';
% args = {my_FFTSize, my_bram_latency, my_input_bit_width, my_reorder_din_latency};
% xBlock(cfg, args);
% 
% You can edit biplex_4x_unscr.m to debug your script.
% 
% You can also replace the MaskInitialization code with the 
% following commands so the subsystem will be generated 
% according to the values of mask parameters.
% cfg.source = str2func('biplex_4x_unscr');
% cfg.toplevel = gcb;
% args = {FFTSize, bram_latency, input_bit_width, reorder_din_latency};
% xBlock(cfg, args);
% 
% To configure the xBlock call in debug mode, in which mode,
% autolayout will be performed every time a block is added,
% run the following commands:
% cfg.source = str2func('biplex_4x_unscr');
% cfg.toplevel = gcb;
% cfg.debug = 1;
% args = {FFTSize, bram_latency, input_bit_width, reorder_din_latency};
% xBlock(cfg, args);
% 
% To make the xBlock smart so it won't re-generate the
% subsystem if neither the arguments nor the scripts are
% changes, use as the following:
% cfg.source = str2func('biplex_4x_unscr');
% cfg.toplevel = gcb;
% cfg.depend = {'biplex_4x_unscr'};
% args = {FFTSize, bram_latency, input_bit_width, reorder_din_latency};
% xBlock(cfg, args);
% 
% See also xBlock, xInport, xOutport, xSignal, xlsub2script.
% add_latency = 2;
% % 
% xBlock;
% FFTSize = 5;
% bram_latency = 2;
% input_bit_width = 18;
% reorder_din_latency = 1;



%% inports
xlsub2_even = xInport('even');
xlsub2_odd = xInport('odd');
xlsub2_sync = xInport('sync');

%% outports
xlsub2_pol1_out = xOutport('pol1_out');
xlsub2_pol2_out = xOutport('pol2_out');
xlsub2_pol3_out = xOutport('pol3_out');
xlsub2_pol4_out = xOutport('pol4_out');
xlsub2_sync_out = xOutport('sync_out');

%% diagram

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Constant1
xlsub2_Constant1_out1 = xSignal;
xlsub2_Constant1 = xBlock(struct('source', 'Constant', 'name', 'Constant1'), ...
                          struct('arith_type', 'Unsigned', ...
                                 'const', 2^(FFTSize-1)-1, ...
                                 'n_bits', FFTSize, ...
                                 'bin_pt', 0, ...
                                 'explicit_period', 'on'), ...
                          {}, ...
                          {xlsub2_Constant1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Constant2
xlsub2_Constant2_out1 = xSignal;
xlsub2_Constant2 = xBlock(struct('source', 'Constant', 'name', 'Constant2'), ...
                          struct('arith_type', 'Unsigned', ...
                                 'const', 2^FFTSize -1, ...
                                 'n_bits', FFTSize, ...
                                 'bin_pt', 0, ...
                                 'explicit_period', 'on'), ...
                          {}, ...
                          {xlsub2_Constant2_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Counter
xlsub2_dual_bit_reverse_out1 = xSignal;
xlsub2_Counter_out1 = xSignal;
xlsub2_Counter = xBlock(struct('source', 'Counter', 'name', 'Counter'), ...
                        struct('n_bits', FFTSize, ...
                               'rst', 'on', ...
                               'explicit_period', 'off', ...
                               'use_rpm', 'on'), ...
                        {xlsub2_dual_bit_reverse_out1}, ...
                        {xlsub2_Counter_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Delay
xlsub2_dual_bit_reverse_out3 = xSignal;
xlsub2_Delay_out1 = xSignal;
xlsub2_Delay = xBlock(struct('source', 'Delay', 'name', 'Delay'), ...
                      [], ...
                      {xlsub2_dual_bit_reverse_out3}, ...
                      {xlsub2_Delay_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Mux
xlsub2_Relational_out1 = xSignal;
xlsub2_dual_bit_reverse_out2 = xSignal;
xlsub2_Mux_out1 = xSignal('xlsub2_Mux_out1');
xlsub2_Mux = xBlock(struct('source', 'Mux', 'name', 'Mux'), ...
                    struct('latency', 1, ...
                           'arith_type', 'Signed  (2''s comp)', ...
                           'n_bits', 8, ...
                           'bin_pt', 2), ...
                    {xlsub2_Relational_out1, xlsub2_Delay_out1, xlsub2_dual_bit_reverse_out2}, ...
                    {xlsub2_Mux_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Mux1
xlsub2_Relational1_out1 = xSignal;
xlsub2_Mux1_out1 = xSignal;
xlsub2_Mux1 = xBlock(struct('source', 'Mux', 'name', 'Mux1'), ...
                     struct('latency', 1, ...
                            'arith_type', 'Signed  (2''s comp)', ...
                            'n_bits', 8, ...
                            'bin_pt', 2), ...
                     {xlsub2_Relational1_out1, xlsub2_dual_bit_reverse_out2, xlsub2_Delay_out1}, ...
                     {xlsub2_Mux1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Mux2
sTailIn5 = xSignal;
xlsub2_Mux2 = xBlock(struct('source', 'Mux', 'name', 'Mux2'), ...
                     struct('latency', 1, ...
                            'arith_type', 'Signed  (2''s comp)', ...
                            'n_bits', 8, ...
                            'bin_pt', 2), ...
                     {xlsub2_Relational1_out1, xlsub2_Delay_out1, xlsub2_dual_bit_reverse_out2}, ...
                     {sTailIn5});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Mux3
sTailIn4 = xSignal;
xlsub2_Mux3 = xBlock(struct('source', 'Mux', 'name', 'Mux3'), ...
                     struct('latency', 1, ...
                            'arith_type', 'Signed  (2''s comp)', ...
                            'n_bits', 8, ...
                            'bin_pt', 2), ...
                     {xlsub2_Relational_out1, xlsub2_dual_bit_reverse_out2, xlsub2_Delay_out1}, ...
                     {sTailIn4});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Relational
xlsub2_Relational = xBlock(struct('source', 'Relational', 'name', 'Relational'), ...
                           [], ...
                           {xlsub2_Counter_out1, xlsub2_Constant2_out1}, ...
                           {xlsub2_Relational_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/Relational1
xlsub2_Relational1 = xBlock(struct('source', 'Relational', 'name', 'Relational1'), ...
                            [], ...
                            {xlsub2_Constant1_out1, xlsub2_Counter_out1}, ...
                            {xlsub2_Relational1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/double_delay_bram_fast
sTailIn2 = xSignal;
sTailIn3 = xSignal;
sTailIn1 = xlsub2_dual_bit_reverse_out1;
xlsub2_double_delay_bram_fast = xBlock(struct('source', 'monroe_library/double_delay_bram_fast', 'name', 'double_delay_bram_fast'), ...
                                       struct('delay_len', 2^(FFTSize-1), ...
                                              'bram_latency', bram_latency));
xlsub2_double_delay_bram_fast.bindPort({xlsub2_Mux1_out1, xlsub2_Mux_out1}, ...
                                       {sTailIn2, sTailIn3});


% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse
xlsub2_dual_bit_reverse_sub = xBlock(struct('source', @xlsub2_dual_bit_reverse, 'name', 'dual_bit_reverse'), ...
                                 {bram_latency, reorder_din_latency}, ...
                                 {xlsub2_sync, xlsub2_even, xlsub2_odd}, ...
                                 {xlsub2_dual_bit_reverse_out1, xlsub2_dual_bit_reverse_out2, xlsub2_dual_bit_reverse_out3});

                             
bUnscrTail = xBlock(struct('source', 'monroe_library/unscr_tail', 'name', 'unscr_tail'), ...
                                       struct('FFTSize', FFTSize, ...
                                              'input_bit_width', input_bit_width, ...
                                              'bram_latency', bram_latency, ...
                                              'reorder_din_latency', reorder_din_latency), ...
                                       {sTailIn1, sTailIn2, sTailIn3, sTailIn4, sTailIn5}, ...
                                       {xlsub2_sync_out, xlsub2_pol1_out, xlsub2_pol2_out, xlsub2_pol3_out, xlsub2_pol4_out});


function xlsub2_dual_bit_reverse(bram_latency, din_latency)



%% inports
xlsub3_sync = xInport('sync');
xlsub3_din0 = xInport('din0');
xlsub3_din1 = xInport('din1');

%% outports
xlsub3_sync_out = xOutport('sync_out');
xlsub3_dout0 = xOutport('dout0');
xlsub3_dout1 = xOutport('dout1');

%% diagram

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Concat1
xlsub3_Constant1_out1 = xSignal;
xlsub3_Mux1_out1 = xSignal;
xlsub3_Concat1_out1 = xSignal;
xlsub3_Concat1 = xBlock(struct('source', 'Concat', 'name', 'Concat1'), ...
                        [], ...
                        {xlsub3_Constant1_out1, xlsub3_Mux1_out1}, ...
                        {xlsub3_Concat1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Concat2
xlsub3_Constant5_out1 = xSignal;
xlsub3_Mux_out1 = xSignal;
xlsub3_Concat2_out1 = xSignal;
xlsub3_Concat2 = xBlock(struct('source', 'Concat', 'name', 'Concat2'), ...
                        [], ...
                        {xlsub3_Constant5_out1, xlsub3_Mux_out1}, ...
                        {xlsub3_Concat2_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Constant
xlsub3_Constant_out1 = xSignal;
xlsub3_Constant = xBlock(struct('source', 'Constant', 'name', 'Constant'), ...
                         struct('arith_type', 'Boolean', ...
                                'n_bits', 1, ...
                                'bin_pt', 0, ...
                                'explicit_period', 'on'), ...
                         {}, ...
                         {xlsub3_Constant_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Constant1
xlsub3_Constant1 = xBlock(struct('source', 'Constant', 'name', 'Constant1'), ...
                          struct('arith_type', 'Boolean', ...
                                 'const', 0, ...
                                 'n_bits', 1, ...
                                 'bin_pt', 0, ...
                                 'explicit_period', 'on'), ...
                          {}, ...
                          {xlsub3_Constant1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Constant5
xlsub3_Constant5 = xBlock(struct('source', 'Constant', 'name', 'Constant5'), ...
                          struct('arith_type', 'Boolean', ...
                                 'n_bits', 1, ...
                                 'bin_pt', 0, ...
                                 'explicit_period', 'on'), ...
                          {}, ...
                          {xlsub3_Constant5_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Counter
xlsub3_post_sync_delay1_out1 = xSignal;
xlsub3_Counter_out1 = xSignal;
xlsub3_Counter = xBlock(struct('source', 'Counter', 'name', 'Counter'), ...
                        struct('cnt_to', 1023, ...
                               'n_bits', FFTSize, ...
                               'rst', 'on', ...
                               'use_rpm', 'off'), ...
                        {xlsub3_post_sync_delay1_out1}, ...
                        {xlsub3_Counter_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Counter1
xlsub3_Counter1_out1 = xSignal;
xlsub3_Counter1 = xBlock(struct('source', 'Counter', 'name', 'Counter1'), ...
                         struct('cnt_to', 1023, ...
                                'operation', 'Down', ...
                                'start_count', (2^FFTSize)-1, ...
                                'n_bits', FFTSize, ...
                                'rst', 'on', ...
                                'use_rpm', 'off'), ...
                         {xlsub3_post_sync_delay1_out1}, ...
                         {xlsub3_Counter1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Dual Port RAM
xlsub3_delay_din0_out1 = xSignal;
xlsub3_delay_din1_out1 = xSignal;
xlsub3_Dual_Port_RAM = xBlock(struct('source', 'Dual Port RAM', 'name', 'Dual Port RAM'), ...
                              struct('depth', 2^(FFTSize), ...
                                     'latency', bram_latency, ...
                                     'write_mode_A', 'Read Before Write', ...
                                     'write_mode_B', 'Read Before Write'), ...
                              {xlsub3_Concat2_out1, xlsub3_delay_din0_out1, xlsub3_Constant_out1, xlsub3_Concat1_out1, xlsub3_delay_din1_out1, xlsub3_Constant_out1}, ...
                              {xlsub3_dout0, xlsub3_dout1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Inverter
xlsub3_Slice3_out1 = xSignal;
xlsub3_Inverter_out1 = xSignal;
xlsub3_Inverter = xBlock(struct('source', 'Inverter', 'name', 'Inverter'), ...
                         [], ...
                         {xlsub3_Slice3_out1}, ...
                         {xlsub3_Inverter_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Mux
xlsub3_Slice1_out1 = xSignal;
xlsub3_Slice2_out1 = xSignal;
xlsub3_bit_reverse_out1 = xSignal;
xlsub3_Mux = xBlock(struct('source', 'Mux', 'name', 'Mux'), ...
                    [], ...
                    {xlsub3_Slice1_out1, xlsub3_Slice2_out1, xlsub3_bit_reverse_out1}, ...
                    {xlsub3_Mux_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Mux1
xlsub3_Slice4_out1 = xSignal('xlsub3_Slice4_out1');
xlsub3_bit_reverse1_out1 = xSignal;
xlsub3_Mux1 = xBlock(struct('source', 'Mux', 'name', 'Mux1'), ...
                     [], ...
                     {xlsub3_Slice1_out1, xlsub3_Slice2_out1, xlsub3_bit_reverse1_out1}, ...
                     {xlsub3_Mux1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Slice1
xlsub3_Slice1 = xBlock(struct('source', 'Slice', 'name', 'Slice1'), ...
                       [], ...
                       {xlsub3_Counter_out1}, ...
                       {xlsub3_Slice1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Slice2
xlsub3_Slice2 = xBlock(struct('source', 'Slice', 'name', 'Slice2'), ...
                       struct('nbits', FFTSize-1, ...
                              'mode', 'Lower Bit Location + Width'), ...
                       {xlsub3_Counter_out1}, ...
                       {xlsub3_Slice2_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Slice3
xlsub3_Slice3 = xBlock(struct('source', 'Slice', 'name', 'Slice3'), ...
                       [], ...
                       {xlsub3_Counter1_out1}, ...
                       {xlsub3_Slice3_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/Slice4
xlsub3_Slice4 = xBlock(struct('source', 'Slice', 'name', 'Slice4'), ...
                       struct('nbits', FFTSize-1, ...
                              'mode', 'Lower Bit Location + Width'), ...
                       {xlsub3_Counter1_out1}, ...
                       {xlsub3_Slice4_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/delay_din0
xlsub3_delay_din0 = xBlock(struct('source', 'Delay', 'name', 'delay_din0'), ...
                           struct('latency', din_latency), ...
                           {xlsub3_din0}, ...
                           {xlsub3_delay_din0_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/delay_din1
xlsub3_delay_din1 = xBlock(struct('source', 'Delay', 'name', 'delay_din1'), ...
                           struct('latency', din_latency), ...
                           {xlsub3_din1}, ...
                           {xlsub3_delay_din1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/post_sync_delay
xlsub3_sync_delay_fast_out1 = xSignal;
sDelayTemp = xDelay(xlsub3_sync_delay_fast_out1,bram_latency, 'post_sync_delay');
xlsub3_sync_out.bind(sDelayTemp);


% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/post_sync_delay1
xlsub3_post_sync_delay1 = xBlock(struct('source', 'Delay', 'name', 'post_sync_delay1'), ...
                                 struct('latency', din_latency), ...
                                 {xlsub3_sync}, ...
                                 {xlsub3_post_sync_delay1_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/sync_delay_fast
xlsub3_sync_delay_fast = xBlock(struct('source', 'monroe_library/sync_delay_fast', 'name', 'sync_delay_fast'), ...
                                struct('delay_len', 2^(FFTSize-1)), ...
                                {xlsub3_post_sync_delay1_out1}, ...
                                {xlsub3_sync_delay_fast_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/bit_reverse

xlsub3_bit_reverse_sub = xBlock(struct('source', str2func('bit_reverse_draw'), 'name','bit_reverse_1'), {FFTSize-1});
%xlsub3_bit_reverse_sub = xlsub3_bit_reverse(FFTSize-1);
xlsub3_bit_reverse_sub.bindPort({xlsub3_Slice2_out1}, {xlsub3_bit_reverse_out1});

% block: bi_real_unscr_4x_plan/biplex_4x_unscr/dual_bit_reverse/bit_reverse1
%xlsub3_bit_reverse1_sub = xlsub3_bit_reverse1(FFTSize-1);
xlsub3_bit_reverse1_sub = xBlock(struct('source', str2func('bit_reverse_draw'), 'name','bit_reverse_2'), {FFTSize-1});
xlsub3_bit_reverse1_sub.bindPort({xlsub3_Slice4_out1}, {xlsub3_bit_reverse1_out1});



% function xblock_obj = xlsub3_bit_reverse(nBits)
% 
% 
% % Mask Initialization code
% config.source=str2func('bit_reverse_draw');
% 
% config.debug=0;
% config.depend={'bit_reverse_draw.m'};
% %xblock_obj = xBlock(config,{nBits,1});
% 
% 
% %% inports
% 
% %% outports
% 
% %% diagram
% 
% 
% 
% end
% 
% function xblock_obj = xlsub3_bit_reverse1(nBits)
% 
% 
% % Mask Initialization code
% config.source=str2func('bit_reverse_draw');
% 
% config.debug=0;
% config.depend={'bit_reverse_draw.m'};
% %xblock_obj = xBlock(config,{nBits,1});
% 
% 
% %% inports
% 
% %% outports
% 
% %% diagram
% 
% 
% 
% end

end


end

