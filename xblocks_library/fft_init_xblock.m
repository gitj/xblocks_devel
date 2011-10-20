%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://casper.berkeley.edu                                                %      
%   Copyright (C) 2011 Suraj Gowda, Hong Chen, Terry Filiba, Aaron Parsons    %
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
function fft_init_xblock(blk, varargin)

% Set default vararg values.
defaults = { ...
    'FFTSize', 5,  ...
    'n_inputs', 2, ...
    'input_bit_width', 18, ...
    'coeff_bit_width', 18, ...
    'add_latency', 1, ...
    'mult_latency', 2, ...
    'bram_latency', 2, ...
    'conv_latency', 1, ...
    'quantization', 'Round  (unbiased: +/- Inf)', ...
    'overflow', 'Saturate', ...
    'arch', 'Virtex5', ...
    'opt_target', 'logic', ...
    'coeffs_bit_limit', 8, ...
    'delays_bit_limit', 8, ...
    'specify_mult', 'off', ...
    'mult_spec', [2 2 2 2 2], ...
    'hardcode_shifts', 'off', ...
    'shift_schedule', [1 1 1 1 1], ...
    'dsp48_adders', 'off', ...
    'unscramble', 'on', ...
    'bit_growth_chart', [0 0], ...
};

% Retrieve values from mask fields.
FFTSize = get_var('FFTSize', 'defaults', defaults, varargin{:});
n_inputs = get_var('n_inputs', 'defaults', defaults, varargin{:});
input_bit_width = get_var('input_bit_width', 'defaults', defaults, varargin{:});
coeff_bit_width = get_var('coeff_bit_width', 'defaults', defaults, varargin{:});
add_latency = get_var('add_latency', 'defaults', defaults, varargin{:});
mult_latency = get_var('mult_latency', 'defaults', defaults, varargin{:});
bram_latency = get_var('bram_latency', 'defaults', defaults, varargin{:});
conv_latency = get_var('conv_latency', 'defaults', defaults, varargin{:});
quantization = get_var('quantization', 'defaults', defaults, varargin{:});
overflow = get_var('overflow', 'defaults', defaults, varargin{:});
arch = get_var('arch', 'defaults', defaults, varargin{:});
opt_target = get_var('opt_target', 'defaults', defaults, varargin{:});
coeffs_bit_limit = get_var('coeffs_bit_limit', 'defaults', defaults, varargin{:});
delays_bit_limit = get_var('delays_bit_limit', 'defaults', defaults, varargin{:});
specify_mult = get_var('specify_mult', 'defaults', defaults, varargin{:});
mult_spec = get_var('mult_spec', 'defaults', defaults, varargin{:});
hardcode_shifts = get_var('hardcode_shifts', 'defaults', defaults, varargin{:});
shift_schedule = get_var('shift_schedule', 'defaults', defaults, varargin{:});
dsp48_adders = get_var('dsp48_adders', 'defaults', defaults, varargin{:});
unscramble = get_var('unscramble', 'defaults', defaults, varargin{:});
bit_growth_chart = get_var('bit_growth_chart', 'defaults', defaults, varargin{:});

% for bit growth FFT
bit_growth_chart =[reshape(bit_growth_chart, 1, []) zeros(1,FFTSize)];
bit_growth_chart
bit_growth_biplex = 0;
for i=1:(FFTSize - n_inputs)
    bit_growth_biplex = bit_growth_biplex + bit_growth_chart(i);
end
bit_growth_sum = 0;
for i=1:FFTSize,
    bit_growth_sum = bit_growth_sum + bit_growth_chart(i);
end

if( strcmp(specify_mult, 'on') && length(mult_spec) ~= FFTSize ),
    error('fft_init.m: Multiplier use specification for stages does not match FFT size');
    clog('fft_init.m: Multiplier use specification for stages does not match FFT size','error');
    return
end

% split up multiplier specification
mults_biplex = 2.*ones(1, FFTSize-n_inputs);
mults_direct = 2.*ones(1, n_inputs);
if strcmp(specify_mult, 'on'),
    mults_biplex(1:FFTSize-n_inputs) = mult_spec(1: FFTSize-n_inputs);
    mults_direct = mult_spec(FFTSize-n_inputs+1:FFTSize);
end

% split up shift schedule
shifts_biplex = ones(1, FFTSize-n_inputs);
shifts_direct = ones(1, n_inputs);
if strcmp(hardcode_shifts, 'on'),
    shifts_biplex(1:FFTSize-n_inputs) = shift_schedule(1: FFTSize-n_inputs);
    shifts_direct = shift_schedule(FFTSize-n_inputs+1:FFTSize);
end


%% inports
xlsub2_sync = xInport('sync');
xlsub2_shift = xInport('shift');
if (n_inputs < 1 )
    pol0 = xInport('pol0');
    pol1 = xInport('pol1');
else
    xlsub2_in = cell(1,2^n_inputs);
    for i=1:2^n_inputs
        xlsub2_in{i} = xInport(['in',num2str(i-1)]);
    end
end

%% outports
xlsub2_sync_out = xOutport('sync_out');
xlsub2_of = xOutport('of');
if (n_inputs <1)
    out0 = xOutport('out0');
    out1 = xOutport('out1');
else
    xlsub2_out = cell(1,2^n_inputs);
    for i =1:2^n_inputs
        xlsub2_out{i} = xOutport(['out',num2str(i-1)]);
    end
end

%% diagram

% Add biplex FFTs
if (n_inputs == 0)
    % block: fft_xblock_models/fft1/fft_biplex
    
    xlsub2_fft_biplex_out1 = xSignal;
    xlsub2_fft_biplex_out2 = xSignal;
    xlsub2_fft_biplex_out3 = xSignal;
    xlsub2_fft_biplex_out4 = xSignal;
    xlsub2_fft_biplex_sub = xBlock(struct('source', str2func('fft_biplex_init_xblock'), 'name', 'fft_biplex'), ...
                                        {[blk,'/fft_biplex'], ...
                                        'FFTSize', FFTSize-n_inputs,...
                                        'input_bit_width', input_bit_width,...
                                        'coeff_bit_width', coeff_bit_width,...
                                        'quantization', quantization,...
                                        'overflow', overflow,...
                                        'add_latency', add_latency,...
                                        'mult_latency', mult_latency,...
                                        'bram_latency', bram_latency,...
                                        'conv_latency', conv_latency, ...
                                        'arch', arch, ...
                                        'opt_target', opt_target, ...
                                        'coeffs_bit_limit', coeffs_bit_limit, ...
                                        'delays_bit_limit', delays_bit_limit, ...
                                        'hardcore_shifts',hardcode_shifts,...
                                        'shift_schedule', shift_schedule, ...
                                        'specify_mult', specify_mult, ...
                                        'mult_spec', mult_spec, ...
                                        'dsp48_adders', dsp48_adders, ...
                                        'bit_growth_chart', bit_growth_chart}, ... 
                               {xlsub2_sync, xlsub2_shift, pol0, pol1}, ...
                               {xlsub2_fft_biplex_out1, xlsub2_fft_biplex_out2, xlsub2_fft_biplex_out3, xlsub2_fft_biplex_out4});
elseif (n_inputs ~= FFTSize)
    
    % block: fft_xblock_models/fft1/of_or
    
    xlsub2_fft_direct_xblock_out4 = xSignal;
    xlsub2_fft_biplex_sub = cell(1,2^(n_inputs-1));
    xlsub2_fft_biplex_out1 = cell(1,2^(n_inputs-1));
    xlsub2_fft_biplex_out2 = cell(1,2^(n_inputs-1));
    xlsub2_fft_biplex_out3 = cell(1,2^(n_inputs-1));
    xlsub2_fft_biplex_out4 = cell(1,2^(n_inputs-1));
    for i=1:2^(n_inputs-1),
        xlsub2_fft_biplex_out1{i} = xSignal;
        xlsub2_fft_biplex_out2{i} = xSignal;
        xlsub2_fft_biplex_out3{i} = xSignal;
        xlsub2_fft_biplex_out4{i} = xSignal;
        xlsub2_fft_biplex_sub{i} = xBlock(struct('source', str2func('fft_biplex_init_xblock'), 'name', ['fft_biplex',num2str(i)]), ...
                                          {[blk,'/fft_biplex',num2str(i)], ...
                                         'FFTSize', FFTSize-n_inputs,...
                                        'input_bit_width', input_bit_width,...
                                        'coeff_bit_width', coeff_bit_width,...
                                        'quantization', quantization,...
                                        'overflow', overflow,...
                                        'add_latency', add_latency,...
                                        'mult_latency', mult_latency,...
                                        'bram_latency', bram_latency,...
                                        'conv_latency', conv_latency, ...
                                        'arch', arch, ...
                                        'opt_target', opt_target, ...
                                        'coeffs_bit_limit', coeffs_bit_limit, ...
                                        'delays_bit_limit', delays_bit_limit, ...
                                        'hardcore_shifts',hardcode_shifts,...
                                        'shift_schedule', shift_schedule, ...
                                        'specify_mult', specify_mult, ...
                                        'mult_spec', mult_spec, ...
                                        'dsp48_adders', dsp48_adders, ...
                                        'bit_growth_chart', bit_growth_chart}, ... 
                               {xlsub2_sync, xlsub2_shift, xlsub2_in{2*i-1}, xlsub2_in{2*i}}, ...
                               {xlsub2_fft_biplex_out1{i}, xlsub2_fft_biplex_out2{i}, xlsub2_fft_biplex_out3{i}, xlsub2_fft_biplex_out4{i}});
    end
    
    xlsub2_of_or = xBlock(struct('source', 'Logical', 'name', 'of_or'), ...
                          struct('logical_function', 'OR', ...
                                 'inputs',2^(n_inputs-1)+1, ...
                                 'latency', 1), ...
                          [{xlsub2_fft_direct_xblock_out4}, xlsub2_fft_biplex_out4], ...
                          {xlsub2_of});
    

end






% Add direct FFTs
if (n_inputs == 0)
    xlsub2_sync_out.bind(xlsub2_fft_biplex_out1);
    out0.bind(xlsub2_fft_biplex_out2);
    out1.bind(xlsub2_fft_biplex_out3);
    xlsub2_of.bind(xlsub2_fft_biplex_out4);
elseif (n_inputs == FFTSize)
    xlsub2_fft_direct_xblock_out1 = xSignal;
    xlsub2_fft_direct_xblock_out2 = xSignal;
    xlsub2_fft_direct_xblock_out3 = xSignal;
    xlsub2_fft_direct_xblock_sub = xBlock(struct('source', str2func('fft_direct_init_xblock'), 'name', 'fft_direct_xblock'), ...
                                             {[blk,'/fft_directr_xblock'], ...
                                            'FFTSize', n_inputs, ...
                                            'input_bit_width', input_bit_width + bit_growth_biplex, ...
                                            'coeff_bit_width', coeff_bit_width + bit_growth_biplex, ...
                                            'map_tail', 'off', ...
                                            'add_latency', add_latency, ...
                                            'mult_latency', mult_latency, ...
                                            'bram_latency', bram_latency, ...
                                            'conv_latency', conv_latency, ...
                                            'quantization', quantization, ... 
                                            'overflow', overflow, ...
                                            'arch', arch, ...
                                            'opt_target', opt_target, ...
                                            'coeffs_bit_limit', coeffs_bit_limit, ...
                                            'specify_mult',specify_mult, ...
                                            'mult_spec', mults_direct, ...
                                            'hardcode_shifts', hardcode_shifts, ...
                                            'shift_schedule', shifts_direct, ...
                                            'dsp48_adders', dsp48_adders, ...
                                            'bit_growth_chart',bit_growth_chart((FFTSize - n_inputs + 1):end)}, ...
                                      [{xlsub2_sync},{xlsub2_shift}, xlsub2_in], ...
                                      [{xlsub2_sync_out},xlsub2_out,{xlsub2_of}]);
else
    % block: fft_xblock_models/fft1/slice
    xlsub2_slice_out1 = xSignal;
    xlsub2_slice = xBlock(struct('source', 'Slice', 'name', 'slice'), ...
                          struct('mode', 'Lower Bit Location + Width', ...
                                'bit0', FFTSize-n_inputs, ...
                                'nbits', n_inputs), ...
                          {xlsub2_shift}, ...
                          {xlsub2_slice_out1});
                      
    fft_direct_inputs = cell(1,2^n_inputs);
    fft_direct_outputs = cell(1,2^n_inputs);
    for i = 1:2^n_inputs,
        fft_direct_inputs{i} = xSignal;
        fft_direct_outputs{i} = xSignal;
    end
    fft_direct_output1 = xSignal;
    xlsub2_fft_direct_xblock_sub = xBlock(struct('source', str2func('fft_direct_init_xblock'), 'name', 'fft_direct_xblock'), ...
                                            {[blk,'/fft_direct_xblock'], ...
                                            'FFTSize', n_inputs, ...
                                            'input_bit_width', input_bit_width + bit_growth_biplex, ...
                                            'coeff_bit_width', coeff_bit_width + bit_growth_biplex, ...
                                            'map_tail', 'on', ...
                                            'LargerFFTSize', FFTSize, ...                
                                            'StartStage',FFTSize-n_inputs+1, ...
                                            'add_latency', add_latency, ...
                                            'mult_latency', mult_latency, ...
                                            'bram_latency', bram_latency, ...
                                            'conv_latency', conv_latency, ...
                                            'quantization', quantization, ...
                                            'overflow', overflow, ...
                                            'arch', arch, ...
                                            'opt_target', opt_target, ...
                                            'coeffs_bit_limit', coeffs_bit_limit, ...
                                            'specify_mult',specify_mult, ...
                                            'mult_spec', mults_direct, ...
                                            'hardcode_shifts', hardcode_shifts, ...
                                            'shift_schedule', shifts_direct, ...
                                            'dsp48_adders', dsp48_adders, ...
                                            'bit_growth_chart',bit_growth_chart((FFTSize - n_inputs + 1):end)}, ...
                                      [{xlsub2_fft_biplex_out1{1}}, {xlsub2_slice_out1}, fft_direct_inputs], ...
                                      [{fft_direct_output1},fft_direct_outputs,{xlsub2_fft_direct_xblock_out4}]);    
    for i=1:2^(n_inputs-1)
        xlsub2_fft_biplex_out2{i}.bind(fft_direct_inputs{2*i-1});
        xlsub2_fft_biplex_out3{i}.bind(fft_direct_inputs{2*i});
    end


    % Add Unscrambler
    if strcmp(unscramble, 'on')
        % block: fft_xblock_models/fft1/fft_unscrambler_xblock
        xlsub2_fft_unscrambler_xblock_sub = xBlock(struct('source', str2func('fft_unscrambler_init_xblock'), 'name', 'fft_unscrambler_xblock'), ...
                                               {[blk,'/fft_unscrambler_xblock'],FFTSize, n_inputs, bram_latency}, ...
                                               [{fft_direct_output1}, fft_direct_outputs], ...
                                               [{xlsub2_sync_out}, xlsub2_out]);

    else
        xlsub2_sync_out.bind(fft_direct_output1);
        for i=1:2^n_inputs,
            xlsub2_out{i}.bind(fft_direct_outputs{i});
        end
    end
end


if ~isempty(blk) && ~strcmp(blk(1), '/')
    clean_blocks(blk);

    fmtstr = sprintf('%d stages\n(%d,%d)\n%s\n%s\n%s', FFTSize, input_bit_width, coeff_bit_width, quantization, overflow,num2str(bit_growth_chart,'%d '));
    set_param(blk, 'AttributesFormatString', fmtstr);
end

end

