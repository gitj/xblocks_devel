%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://casper.berkeley.edu                                                %      
%   Copyright (C) 2011 Suraj Gowda    Hong Chen                               %
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

function reorder_init_xblock(blk,varargin)
% Valid varnames for this block are:
% map = The desired output order.
% map_latency = The latency of a map block.
% bram_latency = The latency of a BRAM block.
% n_inputs = The number of parallel inputs to be reordered.
% double_buffer = Whether to use two buffers to reorder data (instead of
%                 doing it in-place).
% bram_map = Whether to use BlockRAM for address mapping.

% depend {'delay_bram_en_plus_init_xblock','dbl_buffer_init_xblock','sync_delay_en_init_xblock'}

% Declare any default values for arguments you might like.
defaults = {'map',[0 1 2 3],'map_latency', 0, 'bram_latency', 2, 'n_inputs', 1, 'double_buffer', 0, 'bram_map', 'off'};

map = get_var('map', 'defaults', defaults, varargin{:});
map_latency = get_var('map_latency', 'defaults', defaults, varargin{:});
bram_latency = get_var('bram_latency', 'defaults', defaults, varargin{:});
n_inputs = get_var('n_inputs', 'defaults', defaults, varargin{:});
double_buffer = get_var('double_buffer', 'defaults', defaults, varargin{:});
bram_map = get_var('bram_map', 'defaults', defaults, varargin{:});

if n_inputs < 1
    error('Number of inputs cannot be less than 1.');
end

map_length = length(map);
map_bits = ceil(log2(map_length));
order = compute_order(map);
order_bits = ceil(log2(order));

% Determine if map is a bit reversed up-counter
bit_rev_map = bit_rev(map, map_bits);
bit_rev_upcount = sum(bit_rev_map == 0:map_length-1) == map_length;
bit_rev_downcount = sum(bit_rev_map == fliplr(0:map_length-1)) == map_length;
downcount = sum(map == fliplr(0:map_length-1)) == map_length;

if (strcmp('on',bram_map))
    map_memory_type = 'Block RAM';
else
    map_memory_type = 'Distributed memory';
end

if (double_buffer < 0 || double_buffer > 1) ,
	disp('Double Buffer must be 0 or 1');
	error('Double Buffer must be 0 or 1');
end





% At some point, when Xilinx supports muxes wider than 16, this can be
% fixed.
if order > 16 && double_buffer == 0,   
    disp('Reorder can only support a map orders <= 16 in single buffer mode.');
    error('Reorder can only support a map orders <= 16 in single buffer mode.');
end
% Non-power-of-two maps could be supported by adding a counter an a
% comparitor, rather than grouping the map and address count into one
% counter.
if 2^map_bits ~= map_length,
    disp('Reorder currently only supports maps which are 2^? long.')
    error('Reorder currently only supports maps which are 2^? long.')
end

sync = xInport('sync');
en = xInport('en');
sync_out = xOutport('sync_out');
valid = xOutport('valid');

din_ports = cell(1,n_inputs);
dout_ports = cell(1,n_inputs);

% add dynamic ports
for i=1:n_inputs,
	% Ports
	din_ports{i} = xInport(['din',tostring(i-1)]);
	dout_ports{i} = xOutport(['dout',tostring(i-1)]);
end



sync_delay_out = xSignal;
sync_delay_en_out = xSignal;
delay_we_out = xSignal;
pre_sync_delay_out = xSignal;
sync_delay_en_out = xSignal;





% Add Static Blocks
if double_buffer == 1,
    order = 2;
end
pre_sync_delay = xBlock( struct( 'name', 'pre_sync_delay', 'source', 'Delay'), ...
	{'latency', (order-1)*map_latency}, {sync}, {pre_sync_delay_out});
sync_delay_en = xBlock( struct( 'name', 'sync_delay_en', 'source', str2func('sync_delay_en_init_xblock')), ...
	{[blk,'/sync_delay_en'],map_length}, {pre_sync_delay_out, en}, {sync_delay_en_out});    	
	
post_sync_delay = xBlock( struct('name', 'post_sync_delay', 'source', 'Delay'), ...
    {'latency', (bram_latency+1+double_buffer)}, ...
    {sync_delay_en_out}, {sync_out});
delay_we = xBlock( struct('name', 'delay_we', 'source', 'Delay'), ...
    {'latency', ((order-1)*map_latency)}, {en}, {delay_we_out} );
    
delay_valid = xBlock( struct('name', 'delay_valid', 'source', 'Delay'), ...
    {'latency', (bram_latency+1+double_buffer)}, {delay_we_out}, {valid} );

% Special case for reorder of order 1 (just delay)
if order == 1,   
    delay_din_bram_in = cell(1,n_inputs);
    delay_din = cell(1,n_inputs);
    delay_din_bram = cell(1,n_inputs);
    for i=1:n_inputs,
        % Delays
        delay_din_bram_in{i} = xSignal;
        delay_din{i} = xBlock( struct('source', 'Delay', 'name', ['delay_din',num2str(i)]), ...
                      {'latency', 1}, ...
                      { din_ports{i} }, { delay_din_bram_in{i} });
        delay_din_bram{i} = xBlock( struct('source', str2func('delay_bram_en_plus_init_xblock'), 'name', ['delay_din_bram',tostring(i-1)]), ...
                                {[blk,'/','delay_din_bram',tostring(i-1)],length(map),bram_latency}, ... % DelayLen, bram_latency
                                {delay_din_bram_in{i}, delay_we_out}, {dout_ports{i}});
    end
% Case for order != 1, single-buffered
elseif double_buffer == 0,
    delay_d0_out = xSignal;
    delay_sel_out = xSignal;
    mux_out = xSignal;
    counter_out1 = xSignal;
    slice1_out = xSignal;
    slice2_out = xSignal;
    mux_in = cell(1,order-1);
    for i = 1:order-1,
        mux_in{i} = xSignal;
    end
    counter = xBlock( struct('name', 'Counter', 'source', 'Counter'), ...
              struct('n_bits', (map_bits + order_bits), ...
                'cnt_type', 'Count Limited', ...
                 'arith_type', 'Unsigned', ...
                 'cnt_to', (2^map_bits * order - 1), ...
                 'en', 'on', ...
                 'rst', 'on'), ...
              {sync,en}, ...
              {counter_out1});
    slice1 = xBlock( struct('name', 'Slice1', 'source', 'xbsIndex_r4/Slice'), ...
            struct( 'mode', 'Upper Bit Location + Width', ...
                      'nbits', (order_bits) ),...
                  {counter_out1}, ...
                  {slice1_out});
    slice2 = xBlock( struct('name', 'Slice2', 'source', 'Slice'), ...
             struct('mode', 'Lower Bit Location + Width', ...
                     'nbits', (map_bits)),... 
                     {counter_out1},...
                     {slice2_out});
    mux = xBlock( struct('name', 'Mux', 'source', 'Mux'), ...
              struct('inputs', (order), ...
                      'latency', 1),...
                      [{delay_sel_out}, {delay_d0_out}, mux_in],...
                      {mux_out});
    delay_sel = xBlock( struct('name', 'delay_sel', 'source', 'Delay'), ...
             struct('latency', ((order-1)*map_latency)),...
                     {slice1_out},...
                     {delay_sel_out});
    delay_d0 = xBlock( struct('name', 'delay_d0', 'source', 'Delay'), ...
               struct('latency', ((order-1)*map_latency)),...
                        {slice2_out},...
                        {delay_d0_out});

    % Add Dynamic Blocks
    delay_din = cell(1,n_inputs);
    bram = cell(1,n_inputs);
    delay_din_out1 = cell(1,n_inputs);
    for i=1:n_inputs,
        delay_din_out1{i} = xSignal;
        % BRAMS
        delay_din{i} = xBlock(struct ('name', ['delay_din',tostring(i-1)], 'source', 'xbsIndex_r4/Delay'), ...
                 struct( 'latency', (order-1)*map_latency+1),...
                 {din_ports{i}}, ...
                 {delay_din_out1{i}});
        bram{i} = xBlock(struct('name', ['bram',tostring(i-1)], 'source','xbsIndex_r4/Single Port RAM'), ...
                struct( 'depth', 2^map_bits, ...
                            'write_mode', 'Read Before Write', ...
                            'latency', bram_latency),...
                            { mux_out , delay_din_out1{i}  ,  delay_we_out},...
                            {dout_ports{i}});
    end

    % Add Maps
    map_blk = cell(1,order-1);
    map_delay = cell(1,order-1);    
    map_in = cell(1,order);  % one more than the number of maps
    map_in{1} = slice2_out;
    
    if bit_rev_upcount && order == 2 % FFT wideband real special case!
        map_in{2} = xSignal;
        bit_reverser_config.source = str2func('bit_reverser_init_xblock');
        bit_reverser_config.name = 'map1';
        bit_reverser_params = {[], 'n_bits', map_bits};
        xBlock(bit_reverser_config, bit_reverser_params, {map_in{1}}, {map_in{2}});
        
        map_delay{1} = xBlock(struct('name', 'delay_map1', 'source', 'Delay'), ...
            struct('latency', 0), {map_in{2}}, {mux_in{1}});
    elseif (bit_rev_downcount || downcount) && order == 2 % FFT wideband real special case!
        % instantiate a down counter with same reset as the other counter
        down_count = xSignal;
        down_count_slice = xSignal;
        counter = xBlock( struct('name', 'down_counter', 'source', 'Counter'), ...
			struct('n_bits', map_bits+1, ...
			  'cnt_type', 'Count Limited', 'operation', 'Down', ...
			   'arith_type', 'Unsigned', ...
			   'start_count', (2^map_bits * order - 1), 'cnt_to', 0, ...
			   'en', 'on', ...
			   'rst', 'on'), ...
			{sync,en}, {down_count});        
		
		slice2 = xBlock( struct('name', 'down_count_slice', 'source', 'Slice'), ...
             struct('mode', 'Lower Bit Location + Width', ...
                     'nbits', (map_bits)),... 
                     {down_count},...
                     {down_count_slice});
        
        if bit_rev_downcount
        	map_in{2} = xSignal;
        	
			% bit rev the output    
			bit_reverser_config.source = str2func('bit_reverser_init_xblock');
			bit_reverser_config.name = 'map1';
			bit_reverser_params = {[], 'n_bits', map_bits};
			xBlock(bit_reverser_config, bit_reverser_params, {down_count_slice}, {map_in{2}});        
        else
        	map_in{2} = down_count_slice;
        end
        map_delay{1} = xBlock(struct('name', 'delay_map1', 'source', 'Delay'), ...
            struct('latency', 0), {map_in{2}}, {mux_in{1}});        
    else
        for i=1:order-1,
            mapname = ['map', tostring(i)];
            map_in{i+1} = xSignal;
            map_blk{i} = xBlock(struct('name', mapname, 'source','xbsIndex_r4/ROM'), ...
                        struct('depth', map_length, ...
                            'initVector', map, ...
                            'latency', map_latency, ...
                             'arith_type', 'Unsigned',...
                             'n_bits', map_bits, ...
                             'bin_pt', 0, ...
                             'distributed_mem', map_memory_type),...
                             {map_in{i}},...
                             {map_in{i+1}});
            map_delay{i} = xBlock(struct('name', ['delay_',mapname],'source', 'xbsIndex_r4/Delay'), ...
                    struct('latency', (order-(i+1))*map_latency),...
                            {map_in{i+1}},...
                            {mux_in{i}});
        end
    end
    
    
% case for order > 1, double-buffered
else
    delay_d0_out = xSignal;
    delay_sel_out = xSignal;
    counter_out1 = xSignal;
    slice1_out = xSignal;
    slice2_out = xSignal;
    counter = xBlock( struct('name', 'Counter', 'source', 'Counter'), ...
              struct('n_bits', (map_bits + 1), ...
                'cnt_type', 'Count Limited', ...
                 'arith_type', 'Unsigned', ...
                 'cnt_to',(2^map_bits * order - 1), ...
                 'en', 'on', ...
                 'rst', 'on'), ...
              {sync,en}, ...
              {counter_out1});
    slice1 = xBlock( struct('name', 'Slice1', 'source', 'xbsIndex_r4/Slice'), ...
            struct( 'mode', 'Upper Bit Location + Width', ...
                    'nbits', 1 ),...
                  {counter_out1}, ...
                  {slice1_out});
    slice2 = xBlock( struct('name','Slice2', 'source', 'Slice'), ...
             struct('mode', 'Lower Bit Location + Width', ...
                     'nbits', (map_bits)),... 
                     {counter_out1},...
                     {slice2_out});
    delay_sel = xBlock( struct('name', 'delay_sel', 'source', 'Delay'), ...
             struct('latency',map_latency),...
                     {slice1_out},...
                     {delay_sel_out});
    delay_d0 = xBlock( struct('name', 'delay_d0', 'source', 'Delay'), ...
               struct('latency', map_latency),...
                        {slice2_out},...
                        {delay_d0_out});    


   
    % Add Maps
    mapname = 'map1';
    map_out = xSignal;
    map_blk = xBlock(struct('name', mapname, 'source','xbsIndex_r4/ROM'), ...
            struct('depth', map_length, ...
                'initVector', map, ...
                'latency', map_latency, ...
                 'arith_type', 'Unsigned',...
                 'n_bits', map_bits, ...
                 'bin_pt', 0, ...
                 'distributed_mem', map_memory_type),...
                 {slice2_out},...
                 {map_out});
   % Add Dynamic Blocks             
    delay_din = cell(1,n_inputs);
    dblbuffer = cell(1,n_inputs);
    delay_din_out1 = cell(1,n_inputs);
    for i=1:n_inputs,
        delay_din_out1{i} = xSignal;
        % BRAMS
        delay_din{i} = xBlock(struct ('name', ['delay_din',tostring(i-1)], 'source', 'xbsIndex_r4/Delay'), ...
                 struct( 'latency', (order-1)*map_latency+1),...
                 {din_ports{i}}, ...
                 {delay_din_out1{i}});
        dblbuffer{i} = xBlock(struct('name', ['dbl_buffer',tostring(i-1)], 'source',str2func('dbl_buffer_init_xblock')), ...
                             {[blk,'/','dbl_buffer',tostring(i-1)], ...
                              2^map_bits, ...
                              bram_latency}, ...
                              {delay_sel_out , delay_d0_out, map_out, delay_din_out1{i},delay_we_out},...
                              {dout_ports{i}});
    end
    
    

end

if ~isempty(blk) && ~strcmp(blk(1), '/')
    clean_blocks(blk);
    fmtstr = sprintf('order=%d', order);
    set_param(blk, 'AttributesFormatString', fmtstr);
end
end
