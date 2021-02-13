library ieee;
use ieee.std_logic_1164.all;


package Axi4 is

type rGlobalAxi4 is record
    ACLK        : std_logic; -- ACLK Clock source The global clock signal. All signals are sampled on the rising
							 -- edge of ACLK.
    ARESETn     : std_logic; -- ARESETn Reset source The global reset signal. ARESETn is active-LOW.
end record rGlobalAxi4;

type rAxi4WAddrMoSi is record
AWID : std_logic_vector;    -- AWID Master Identification tag for a write transaction.
							-- See ID signals on page A5-81.
AWADDR : std_logic_vector;	-- AWADDR Master The address of the first transfer in a write transaction.
							-- See Address structure on page A3-48.
AWLEN : std_logic_vector;	-- AWLEN Master Length, the exact number of data transfers in a write transaction. This information
							-- determines the number of data transfers associated with the address.
							-- This changes between AXI3 and AXI4.
							-- See Burst length on page A3-48.
AWSIZE : std_logic_vector;	-- AWSIZE Master Size, the number of bytes in each data transfer in a write transaction.
							-- See Burst size on page A3-49.
AWBURST : std_logic_vector;	-- AWBURST Master Burst type, indicates how address changes between each transfer in a write
							-- transaction.
							-- See Burst type on page A3-49.
AWLOCK : std_logic_vector;	-- AWLOCK Master Provides information about the atomic characteristics of a write transaction.
							-- This changes between AXI3 and AXI4.
							-- See Locked accesses on page A7-99.
AWCACHE : std_logic_vector;	-- AWCACHE Master Indicates how a write transaction is required to progress through a system.
							-- See Memory types on page A4-69.
AWPROT : std_logic_vector;	-- AWPROT Master Protection attributes of a write transaction: privilege, security level, and access
							-- type.
							-- See Access permissions on page A4-75.
AWQOS : std_logic_vector;	-- AWQOS Master Quality of Service identifier for a write transaction.
							-- Not implemented in AXI3.
							-- See QoS signaling on page A8-102.
AWREGION : std_logic_vector;-- AWREGION Master Region indicator for a write transaction.
							-- Not implemented in AXI3.
							-- See Multiple region signaling on page A8-103.
AWUSER : std_logic_vector;	-- AWUSER Master User-defined extension for the write address channel.
							-- Not implemented in AXI3.
							-- See User-defined signaling on page A8-104.
AWVALID : std_logic;		-- AWVALID Master Indicates that the write address channel signals are valid.
							-- See Channel handshake signals on page A3-42.

end record;

type rAxi4WAddrMiSo is record
AWREADY : std_logic;		-- AWREADY Slave Indicates that a transfer on the write address channel can be accepted.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4WDataMoSi is record
WID : std_logic_vector;		-- WID Master The ID tag of the write data transfer.
							-- Implemented in AXI3 only.
							-- See ID signals on page A5-81.
WDATA : std_logic_vector;	-- WDATA Master Write data.
							-- See Write data channel on page A3-43.
WSTRB : std_logic_vector;	-- WSTRB Master Write strobes, indicate which byte lanes hold valid data.
							-- See Write strobes on page A3-54.
WLAST : std_logic;			-- WLAST Master Indicates whether this is the last data transfer in a write transaction.
							-- See Write data channel on page A3-43.
WUSER : std_logic_vector;	-- WUSER Master User-defined extension for the write data channel.
							-- Not implemented in AXI3.
							-- See User-defined signaling on page A8-104.
WVALID : std_logic;			-- WVALID Master Indicates that the write data channel signals are valid.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4WDataMiSo is record
WREADY : std_logic;			-- WREADY Slave Indicates that a transfer on the write data channel can be accepted.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4WRespMoSi is record
BREADY : std_logic; 		-- BREADY Master Indicates that a transfer on the write response channel can be accepted.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4WRespMiS0 is record
BID : std_logic_vector;		-- BID Slave Identification tag for a write response.
							-- See ID signals on page A5-81.
BRESP : std_logic_vector;	-- BRESP Slave Write response, indicates the status of a write transaction.
							-- See Read and write response structure on page A3-59.
BUSER : std_logic_vector;	-- BUSER Slave User-defined extension for the write response channel.	
							-- Not implemented in AXI3.
							-- See User-defined signaling on page A8-104.
BVALID : std_logic;			-- BVALID Slave Indicates that the write response channel signals are valid.
							-- See Channel handshake signals on page A3-42.

end record;

type rAxi4RAddrMoSi is record
ARID : std_logic_vector;	-- ARID Master Identification tag for a read transaction.
							-- See ID signals on page A5-81.
ARADDR : std_logic_vector;	-- ARADDR Master The address of the first transfer in a read transaction.
							-- See Address structure on page A3-48.
ARLEN : std_logic_vector;	-- ARLEN Master Length, the exact number of data transfers in a read transaction. This changes between
							-- AXI3 and AXI4.
							-- See Burst length on page A3-48.
ARSIZE : std_logic_vector;	-- ARSIZE Master Size, the number of bytes in each data transfer in a read transaction.
							-- See Burst size on page A3-49.
ARBURST : std_logic_vector;	-- ARBURST Master Burst type, indicates how address changes between each transfer in a read transaction.
							-- See Burst type on page A3-49.
ARLOCK : std_logic_vector;	-- ARLOCK Master Provides information about the atomic characteristics of a read transaction. This
							-- changes between AXI3 and AXI4.
							-- See Locked accesses on page A7-99.
ARCACHE : std_logic_vector;	-- ARCACHE Master Indicates how a read transaction is required to progress through a system.
							-- See Memory types on page A4-69.
ARPROT : std_logic_vector;	-- ARPROT Master Protection attributes of a read transaction: privilege, security level, and access type.
							-- See Access permissions on page A4-75.
ARQOS : std_logic_vector;	-- ARQOS Master Quality of Service identifier for a read transaction.
							-- Not implemented in AXI3.
							-- See QoS signaling on page A8-102.
ARREGION : std_logic_vector;-- ARREGION Master Region indicator for a read transaction.
							-- Not implemented in AXI3.
							-- See Multiple region signaling on page A8-103.
ARUSER : std_logic_vector;	-- ARUSER Master User-defined extension for the read address channel.
							-- Not implemented in AXI3.
							-- See User-defined signaling on page A8-104.
ARVALID : std_logic;		-- ARVALID Master Indicates that the read address channel signals are valid.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4RAddrMiSo is record
ARREADY : std_logic; 		-- ARREADY Slave Indicates that a transfer on the read address channel can be accepted.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4RDataMoSi is record
RREADY : std_logic;			-- RREADY Master Indicates that a transfer on the read data channel can be accepted.
							-- See Channel handshake signals on page A3-42.
end record;

type rAxi4RDataMiSo is record
RID : std_logic_vector;		-- RID Slave Identification tag for read data and response.
							-- See ID signals on page A5-81.
RDATA : std_logic_vector;	-- RDATA Slave Read data.
							-- See Read data channel on page A3-43.
RRESP : std_logic_vector;	-- RRESP Slave Read response, indicates the status of a read transfer.
							-- See Read and write response structure on page A3-59.
RLAST : std_logic;			-- RLAST Slave Indicates whether this is the last data transfer in a read transaction.
							-- See Read data channel on page A3-43.
RUSER : std_logic_vector;	-- RUSER Slave User-defined extension for the read data channel.
							-- Not implemented in AXI3.
							-- See User-defined signaling on page A8-104.
RVALID : std_logic;			-- RVALID Slave Indicates that the read data channel signals are valid.
							-- See Channel handshake signals on page A3-42.
end record;


type rAxi4MoSi is record
WAddrCh : rAxi4WAddrMoSi;
WDataCh : rAxi4WDataMoSi;
WRespCh	: rAxi4WRespMoSi;
RAddrCh : rAxi4RAddrMoSi;
RDataCh : rAxi4RDataMoSi;
end record;

type rAxi4MiSo is record
WAddrCh : rAxi4WAddrMiSo;
WDataCh : rAxi4WDataMiSo;
WRespCh	: rAxi4WRespMiSo;
RAddrCh : rAxi4RAddrMiSo;
RDataCh : rAxi4RDataMiSo;
end record;

end package Axi4;