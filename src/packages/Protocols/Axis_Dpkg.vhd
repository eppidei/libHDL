library ieee;
use ieee.std_logic_1164.all;


package Axis is

type rGlobalAxis is record
    ACLK        : std_logic; -- ACLK Clock source The global clock signal. All signals are sampled on the rising
							 -- edge of ACLK.
    ARESETn     : std_logic; -- ARESETn Reset source The global reset signal. ARESETn is active-LOW.
end record rGlobalAxis;

type rAxisMoSi is record
							-- n Data bus width in bytes.
							-- i TID width. Recommended maximum is 8-bits.
							-- d TDEST width. Recommended maximum is 4-bits.
							-- u TUSER width. Recommended number of bits is an integer multiple of the width
							-- of the interface in bytes



TVALID : std_logic; 		-- TVALID Master TVALID indicates that the master is driving a valid transfer.
							-- A transfer takes place when both TVALID and TREADY are
							-- asserted.

TDATA  : std_logic_vector;  -- TDATA[(8n-1):0] Master TDATA is the primary payload that is used to provide the data
							-- that is passing across the interface. The width of the data
							-- payload is an integer number of bytes.
TSTRB  : std_logic_vector;  -- TSTRB[(n-1):0] Master TSTRB is the byte qualifier that indicates whether the content
							-- of the associated byte of TDATA is processed as a data byte or
							-- a position byte.
TKEEP  : std_logic_vector;  -- TKEEP[(n-1):0] Master TKEEP is the byte qualifier that indicates whether the content
							-- of the associated byte of TDATA is processed as part of the data
							-- stream.
							-- Associated bytes that have the TKEEP byte qualifier deasserted
							-- are null bytes and can be removed from the data stream.
TLAST  : std_logic_vector;  -- TLAST Master TLAST indicates the boundary of a packet.
TID    : std_logic_vector;  -- TID[(i-1):0] Master TID is the data stream identifier that indicates different streams
							-- of data.
TDEST  : std_logic_vector;	-- TDEST[(d-1):0] Master TDEST provides routing information for the data stream.
TUSER  : std_logic_vector;	-- TUSER[(u-1):0] Master TUSER is user defined sideband information that can be
							-- transmitted alongside the data stream.

end record;

type rAxisMiSo is record
TREADY : std_logic; 		-- TREADY Slave TREADY indicates that the slave can accept a transfer in the
							-- current cycle.
end record;

end package Axis;