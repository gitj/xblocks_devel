%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://casper.berkeley.edu                                                %      
%   Copyright (C) 2011 Hong Chen                                              %
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
function biplex_cplx_unscrambler_init_xblock(blk, FFTSize, bram_latency)
% depend {'reorder_init_xblock','delay_bram_en_plus_init_xblock','dbl_buffer_init_xblock','sync_delay_en_init_xblock'}
% depend {'barrel_switcher_init_xblock'}

map = bit_reverse(0:2^(FFTSize-1)-1, FFTSize-1);

%% inports
xlsub2_even = xInport('even');
xlsub2_odd = xInport('odd');
xlsub2_sync = xInport('sync');

%% outports
xlsub2_pol1 = xOutport('pol1');
xlsub2_pol2 = xOutport('pol2');
xlsub2_sync_out = xOutport('sync_out');

%% diagram

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Constant
xlsub2_Constant_out1 = xSignal;
xlsub2_Constant = xBlock(struct('source', 'Constant', 'name', 'Constant'), ...
                         struct('arith_type', 'Boolean', ...
                                'n_bits', 1, ...
                                'bin_pt', 0, ...
                                'explicit_period', 'on'), ...
                         {}, ...
                         {xlsub2_Constant_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Constant1
xlsub2_Constant1_out1 = xSignal;
xlsub2_Constant1 = xBlock(struct('source', 'Constant', 'name', 'Constant1'), ...
                          struct('arith_type', 'Unsigned', ...
                                 'const', 2^(FFTSize-1), ...
                                 'n_bits', FFTSize, ...
                                 'bin_pt', 0, ...
                                 'explicit_period', 'on'), ...
                          {}, ...
                          {xlsub2_Constant1_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Constant2
xlsub2_Constant2_out1 = xSignal;
xlsub2_Constant2 = xBlock(struct('source', 'Constant', 'name', 'Constant2'), ...
                          struct('arith_type', 'Unsigned', ...
                                 'const', 2^(FFTSize-1), ...
                                 'n_bits', FFTSize, ...
                                 'bin_pt', 0, ...
                                 'explicit_period', 'on'), ...
                          {}, ...
                          {xlsub2_Constant2_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Convert
xlsub2_Relational_out1 = xSignal;
xlsub2_Convert_out1 = xSignal;
xlsub2_Convert = xBlock(struct('source', 'Convert', 'name', 'Convert'), ...
                        struct('arith_type', 'Unsigned', ...
                               'n_bits', 1, ...
                               'bin_pt', 0), ...
                        {xlsub2_Relational_out1}, ...
                        {xlsub2_Convert_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Convert1
xlsub2_Relational1_out1 = xSignal;
xlsub2_Convert1_out1 = xSignal;
xlsub2_Convert1 = xBlock(struct('source', 'Convert', 'name', 'Convert1'), ...
                         struct('arith_type', 'Unsigned', ...
                                'n_bits', 1, ...
                                'bin_pt', 0), ...
                         {xlsub2_Relational1_out1}, ...
                         {xlsub2_Convert1_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Counter
xlsub2_Counter_out1 = xSignal;
xlsub2_Counter = xBlock(struct('source', 'Counter', 'name', 'Counter'), ...
                        struct('n_bits', FFTSize, ...
                               'rst', 'on', ...
                               'explicit_period', 'off', ...
                               'use_rpm', 'on'), ...
                        {xlsub2_sync}, ...
                        {xlsub2_Counter_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Counter1
xlsub2_reorder_out1 = xSignal;
xlsub2_Counter1_out1 = xSignal;
xlsub2_Counter1 = xBlock(struct('source', 'Counter', 'name', 'Counter1'), ...
                         struct('n_bits', FFTSize, ...
                                'rst', 'on', ...
                                'explicit_period', 'off', ...
                                'use_rpm', 'on'), ...
                         {xlsub2_reorder_out1}, ...
                         {xlsub2_Counter1_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Relational
xlsub2_Relational = xBlock(struct('source', 'Relational', 'name', 'Relational'), ...
                           struct('mode', 'a<=b', ...
                                  'latency', 0), ...
                           {xlsub2_Constant1_out1, xlsub2_Counter_out1}, ...
                           {xlsub2_Relational_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/Relational1
xlsub2_Relational1 = xBlock(struct('source', 'Relational', 'name', 'Relational1'), ...
                            struct('mode', 'a<=b', ...
                                   'latency', 0), ...
                            {xlsub2_Constant2_out1, xlsub2_Counter1_out1}, ...
                            {xlsub2_Relational1_out1});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/barrel_switcher1
xlsub2_reorder_out3 = xSignal;
xlsub2_reorder1_out3 = xSignal;
xlsub2_barrel_switcher1_config.source =  str2func('barrel_switcher_init_xblock');
xlsub2_barrel_switcher1_config.name = 'barrel_switcher1';
xlsub2_barrel_switcher1_config.depend = {'barrel_switcher_init_xblock'};
xlsub2_barrel_switcher1_args = {[blk, '/', xlsub2_barrel_switcher1_config.name], 1};
xlsub2_barrel_switcher1 = xBlock(xlsub2_barrel_switcher1_config, ...
                                 xlsub2_barrel_switcher1_args, ...
                                 {xlsub2_Convert1_out1, xlsub2_reorder_out1, xlsub2_reorder_out3, xlsub2_reorder1_out3}, ...
                                 {xlsub2_sync_out, xlsub2_pol1, xlsub2_pol2});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/barrel_switcher
xlsub2_barrel_switcher_out1 = xSignal;
xlsub2_barrel_switcher_out2 = xSignal;
xlsub2_barrel_switcher_out3 = xSignal;
xlsub2_barrel_switcher_config.source =  str2func('barrel_switcher_init_xblock');
xlsub2_barrel_switcher_config.name = 'barrel_switcher';
xlsub2_barrel_switcher_config.depend = {'barrel_switcher_init_xblock'};
xlsub2_barrel_switcher_args = {[blk, '/', xlsub2_barrel_switcher_config.name], 1};
xlsub2_barrel_switcher_sub = xBlock(xlsub2_barrel_switcher_config, ...
                                xlsub2_barrel_switcher_args, ...
                                {xlsub2_Convert_out1, xlsub2_sync, xlsub2_even, xlsub2_odd}, ...
                                {xlsub2_barrel_switcher_out1, xlsub2_barrel_switcher_out2, xlsub2_barrel_switcher_out3});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/reorder
xlsub2_reorder_config.source = str2func('reorder_init_xblock');
xlsub2_reorder_config.name = 'reorder';
xlsub2_reorder_config.depend = {'reorder_init_xblock','delay_bram_en_plus_init_xblock','dbl_buffer_init_xblock','sync_delay_en_init_xblock'};
xlsub2_reorder_args = {[blk,'/' xlsub2_reorder_config.name], ...
                       'map',[map,map+2^(FFTSize-1)], ...  % {[map,map+2^(FFTSize-1)], 1, 2, 0, 0, 'off'}, ...
                       'bram_latency',bram_latency};
xlsub2_reorder_sub = xBlock(xlsub2_reorder_config, ...
                        xlsub2_reorder_args,...
                        {xlsub2_barrel_switcher_out1, xlsub2_Constant_out1, xlsub2_barrel_switcher_out2}, ...
                        {xlsub2_reorder_out1, [], xlsub2_reorder_out3});

% block: temp_biplex_cplx_unscrambler/biplex_cplx_unscrambler/reorder1
xlsub2_reorder1_config.source = str2func('reorder_init_xblock');
xlsub2_reorder1_config.name = 'reorder1';
xlsub2_reorder1_config.depend = {'reorder_init_xblock','delay_bram_en_plus_init_xblock','dbl_buffer_init_xblock','sync_delay_en_init_xblock'};
xlsub2_reorder1_args = {[blk,'/' xlsub2_reorder1_config.name], ...
                        'map',[map+2^(FFTSize-1),map], ...  % notice the map for two reroder blocks are different % {[map,map+2^(FFTSize-1)], 1, 2, 0, 0, 'off'}, ...
                        'bram_latency',bram_latency};
xlsub2_reorder1_sub = xBlock(xlsub2_reorder1_config, ...
                             xlsub2_reorder1_args, ...
                         {xlsub2_barrel_switcher_out1, xlsub2_Constant_out1, xlsub2_barrel_switcher_out3}, ...
                         {[], [], xlsub2_reorder1_out3});


if ~isempty(blk) && ~strcmp(blk(1), '/')
    clean_blocks(blk);
end

end
