testcase = {}


# CSR write/read sanity test (single descriptor, aligned addresses, incremental burst)
testcase["csr_wr_rd_test"] = [
    "run_op : +UVM_TESTNAME=csr_wr_rd_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW"
]

# Basic functionality test (single descriptor, aligned)
testcase["sanity_simple_test"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=II",
	"run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]

# Basic error test - 1
testcase["dma_error_test"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=UNAL",
    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +uvm_set_type_override=axi4_s_driver,axi_s_error_driver"
]


# Basic error test - II
testcase["dma_error_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=UNAL",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +uvm_set_type_override=axi4_s_driver,axi_s_error_driver"
]

# Multiple-burst transfer (multi descriptor, incremental burst)
testcase["multiple_burst_transfer_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
   
]

# Disable descriptor test (single descriptor, control=0 to disable)
testcase["disable_descriptor_test_II"] = [
   "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_DES_CONFIG=0x0",
    "run_op : +DATA_CTRL=0x21"
 
]

# Unaligned destination transfer test
testcase["unaligned_source_destination_transfer_test_wstrb_1110_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x01",
    "run_op : +DATA_DEST=0x1401",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1100_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x02",
    "run_op : +DATA_DEST=0x1402",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1000_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x03",
    "run_op : +DATA_DEST=0x1403",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


# Error response test (single descriptor, aligned, incremental burst)
testcase["error_response_test"] = [
    "run_op : +UVM_TESTNAME=dma_error_response_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
]

# Max burst configuration test (single descriptor, fixed burst)
testcase["max_burst_configuration_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x400",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x3FD"
]

# ------------------------------------------------
#  Multi-descriptor configuration regression test
# ------------------------------------------------
testcase["multiple_descriptor_configuration_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +NUM_DES=multi",
    "run_op : +SRC_ADDR_TYPE=AL",
   "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=II",
    # descriptor-0 fields
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
     #descriptor-1 fields
    "run_op : +DATA_NUM_BYTES2=0x48", # 24 for singlr burst and 48 for multi burst
    "run_op : +DATA_DES_CONFIG2=0x4",
    # control reg is shared, but we still pass it
    "run_op : +DATA_SRC2=0x0",         # 0 value causes malfunction
    "run_op : +DATA_DEST2=0x1404"
]

# Single burst transfer test (single descriptor, incremental)
testcase["single_burst_transfer_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x44",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x41"
]

# Unaligned source transfer test
testcase["unaligned_source_transfer_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=UNAL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]

# Unaligned destination transfer test
testcase["unaligned_destination_transfer_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=UNAL",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]

# Abort mid-transfer test (single descriptor, then you can override DATA_CTRL to abort)
testcase["abort_mid_transfer_test"] = [
    "run_op : +UVM_TESTNAME=dma_abort_operation_test",
	"run_op : +UVM_TIMEOUT=500000"
]
# same descriptor multiple configuration test
testcase["same_descriptor_multiple_configuration_test"] = [
    "run_op : +UVM_TESTNAME=same_descriptor_multiple_configuration_test",
	"run_op : +UVM_TIMEOUT=500000"
]


# Burst exceeds 4k boundary test (single descriptor, large length)
testcase["burst_exceeds_4k_boundary_test_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=II",
	"run_op : +DATA_SRC=0xFFC"
    "run_op : +DATA_DEST=0x1FF8"
    "run_op : +DATA_NUM_BYTES=0x14",  # 4K
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x11"
]

# 4k bytes transfer test (single descriptor)
testcase["4kb_bytes_transfer_test_single_descriptor_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=II",
	"run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
    "run_op : +DATA_NUM_BYTES=0x1000",  # 4K
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x3FD"
]

# 4k bytes transfer test (single descriptor)
testcase["4kb_bytes_transfer_test_multiple_descriptor_II"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=multi",
    "run_op : +BURST_MODE=II",
	"run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
    "run_op : +DATA_CTRL=0x3FD",
    "run_op : +DATA_NUM_BYTES=0x800",  # 4K
    "run_op : +DATA_DES_CONFIG=0x4",
	"run_op : +DATA_SRC2=0x04",
    "run_op : +DATA_DEST2=0x1404",
    "run_op : +DATA_NUM_BYTES2=0x800"  # 4K
]



###2 Burst: Read Fixed,Write Increment

# Basic functionality test (single descriptor, aligned)
testcase["sanity_simple_test_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FI",
	"run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]

# Multiple-burst transfer (multi descriptor, incremental burst)
testcase["multiple_burst_transfer_test_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_CTRL=0x21"
   
]

# Disable descriptor test (single descriptor, control=0 to disable)
testcase["disable_descriptor_test_FI"] = [
   "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_DES_CONFIG=0x2",
    "run_op : +DATA_CTRL=0x21"
 
]



# Max burst configuration test (single descriptor, fixed burst)
testcase["max_burst_configuration_test_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x14",
    "run_op : +DATA_SRC=0x04",
    "run_op : +DATA_DEST=0x1400",
    "run_op : +DATA_CTRL=0x11"
]

# ------------------------------------------------
#  Multi-descriptor configuration regression test
# ------------------------------------------------
testcase["multiple_descriptor_configuration_test_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +NUM_DES=multi",
    "run_op : +BURST_MODE=FI",
    # descriptor-0 fields
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
     #descriptor-1 fields
    "run_op : +DATA_NUM_BYTES2=0x24",
    # control reg is shared, but we still pass it
    "run_op : +DATA_SRC2=0x04",
    "run_op : +DATA_DEST2=0x1404"
]

# Single burst transfer test (single descriptor, incremental)
testcase["single_burst_transfer_test_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x40",
    "run_op : +DATA_CTRL=0x41"
]
 


# Unaligned destination transfer test
testcase["unaligned_source_destination_transfer_test_wstrb_1110_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x01",
    "run_op : +DATA_DEST=0x1401",

    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1100_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x02",
    "run_op : +DATA_DEST=0x1402",

    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1000_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x03",
    "run_op : +DATA_DEST=0x1403",

    "run_op : +BURST_MODE=FI",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]









# Burst exceeds 4k boundary test (single descriptor, large length)
testcase["burst_exceeds_4k_boundary_test_FI"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=FI",
	"run_op : +DATA_SRC=0xFFC"
    "run_op : +DATA_DEST=0x1FF8"
    "run_op : +DATA_NUM_BYTES=0x14",  # 4K
    "run_op : +DATA_CTRL=0x11"
]






######3 Burst Read Increment Write Fixed

# Basic functionality test (single descriptor, aligned)
testcase["sanity_simple_test_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=IF",
	"run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]

# Multiple-burst transfer (multi descriptor, incremental burst)
testcase["multiple_burst_transfer_test_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_CTRL=0x21"
   
]

# Disable descriptor test (single descriptor, control=0 to disable)
testcase["disable_descriptor_test_IF"] = [
   "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_DES_CONFIG=0x1",
    "run_op : +DATA_CTRL=0x21"
 
]



# Max burst configuration test (single descriptor, fixed burst)
testcase["max_burst_configuration_test_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x400",
    "run_op : +DATA_CTRL=0x3FD"
]

# ------------------------------------------------
#  Multi-descriptor configuration regression test
# ------------------------------------------------
testcase["multiple_descriptor_configuration_test_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +NUM_DES=multi",
    "run_op : +SRC_ADDR_TYPE=AL",
   "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=IF",
    # descriptor-0 fields
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
     #descriptor-1 fields
    "run_op : +DATA_NUM_BYTES2=0x24",
    # control reg is shared, but we still pass it
    "run_op : +DATA_SRC2=0x04",
    "run_op : +DATA_DEST2=0x1404"
]

# Single burst transfer test (single descriptor, incremental)
testcase["single_burst_transfer_test_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x44",
    "run_op : +DATA_CTRL=0x41"
]



# Unaligned destination transfer test
testcase["unaligned_source_destination_transfer_test_wstrb_1110_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x01",
    "run_op : +DATA_DEST=0x1401",

    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1100_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x02",
    "run_op : +DATA_DEST=0x1402",

    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1000_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x03",
    "run_op : +DATA_DEST=0x1403",

    "run_op : +BURST_MODE=IF",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]











# Burst exceeds 4k boundary test (single descriptor, large length)
testcase["burst_exceeds_4k_boundary_test_IF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=IF",
	"run_op : +DATA_SRC=0xFFC"
    "run_op : +DATA_DEST=0x1FF8"
    "run_op : +DATA_NUM_BYTES=0x14",  # 4K
    "run_op : +DATA_CTRL=0x11"
]




####4 Burst Read Fixed write Fixed

# Basic functionality test (single descriptor, aligned)
testcase["sanity_simple_test_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FF",
	"run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]

# Multiple-burst transfer (multi descriptor, incremental burst)
testcase["multiple_burst_transfer_test_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_CTRL=0x21"
   
]

# Disable descriptor test (single descriptor, control=0 to disable)
testcase["disable_descriptor_test_FF"] = [
   "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_DES_CONFIG=0X3",
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_CTRL=0x21"
 
]


# Max burst configuration test (single descriptor, fixed burst)
testcase["max_burst_configuration_test_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_NUM_BYTES=0x400",
    "run_op : +DATA_CTRL=0x3FD"
]

# ------------------------------------------------
#  Multi-descriptor configuration regression test
# ------------------------------------------------
testcase["multiple_descriptor_configuration_test_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +NUM_DES=multi",
    "run_op : +SRC_ADDR_TYPE=AL",
   "run_op : +DEST_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FF",
    # descriptor-0 fields
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
     #descriptor-1 fields
    "run_op : +DATA_NUM_BYTES2=0x24",
    # control reg is shared, but we still pass it
    "run_op : +DATA_SRC2=0x04",
    "run_op : +DATA_DEST2=0x1404"
]

# Single burst transfer test (single descriptor, incremental)
testcase["single_burst_transfer_test_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_NUM_BYTES=0x40",
    "run_op : +DATA_CTRL=0x3D"
]



# Unaligned destination transfer test
testcase["unaligned_source_destination_transfer_test_wstrb_1110_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x01",
    "run_op : +DATA_DEST=0x1401",

    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1100_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x02",
    "run_op : +DATA_DEST=0x1402",

    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]


testcase["unaligned_source_destination_transfer_test_wstrb_1000_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
   #"run_op : +SRC_ADDR_TYPE=AL",
   #"run_op : +DEST_ADDR_TYPE=UNAL",
	"run_op : +DATA_SRC=0x03",
    "run_op : +DATA_DEST=0x1403",

    "run_op : +BURST_MODE=FF",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21"
]








# Burst exceeds 4k boundary test (single descriptor, large length)
testcase["burst_exceeds_4k_boundary_test_FF"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +SRC_ADDR_TYPE=AL",
    "run_op : +BURST_MODE=FF",
	"run_op : +DATA_SRC=0xFFC",
    "run_op : +DATA_DEST=0x1FF8",
    "run_op : +DATA_NUM_BYTES=0x14",  # 4K
    "run_op : +DATA_CTRL=0x11"
]


# Single burst transfer test (single descriptor, incremental)
testcase["random_test_awlen_120"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x1E4",
    "run_op : +DATA_CTRL=0x1E1"
]

# Single burst transfer test (single descriptor, incremental)
testcase["random_test_awlen_180"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
	"run_op : +DATA_SRC=0x4",
    "run_op : +DATA_DEST=0x1400",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x2D4",
    "run_op : +DATA_CTRL=0x2D1"
]

# Single burst transfer test (single descriptor, incremental)
testcase["random_test_awlen_200"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x324",
    "run_op : +DATA_CTRL=0x321"
]

# Single burst transfer test (single descriptor, incremental)
testcase["random_test_wstrb_1110"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
	"run_op : +DATA_SRC=0x4",
    "run_op : +DATA_DEST=0x1401",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]


# Single burst transfer test (single descriptor, incremental)
testcase["random_test_wstrb_1100"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
	"run_op : +DATA_SRC=0x4",
    "run_op : +DATA_DEST=0x1402",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]


# Single burst transfer test (single descriptor, incremental)
testcase["random_test_wstrb_1000"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +UVM_VERBOSITY=UVM_LOW",
    "run_op : +NUM_DES=single",
	"run_op : +DATA_SRC=0x4",
    "run_op : +DATA_DEST=0x1403",

    "run_op : +BURST_MODE=II",
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_CTRL=0x21"
]


testcase["descriptor0_enabled_descriptor1_disabled_test"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +NUM_DES=multi",
    "run_op : +BURST_MODE=II",
    # descriptor-0 fields
    "run_op : +DATA_NUM_BYTES=0x48",
    "run_op : +DATA_DES_CONFIG=0x4",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
     #descriptor-1 fields
    "run_op : +DATA_NUM_BYTES2=0x24",
    "run_op : +DATA_DES_CONFIG2=0x0",
    # control reg is shared, but we still pass it
    "run_op : +DATA_SRC2=0x04",
    "run_op : +DATA_DEST2=0x1404"
]


testcase["descriptor0_fixed_burst_descriptor1_incr_burst_test"] = [
    "run_op : +UVM_TESTNAME=csr_custom_test",
    "run_op : +UVM_TIMEOUT=500000",
    "run_op : +NUM_DES=multi",
    # descriptor-0 fields
    "run_op : +DATA_NUM_BYTES=0x24",
    "run_op : +DATA_DES_CONFIG=0x7",
    "run_op : +DATA_CTRL=0x21",
    "run_op : +DATA_SRC=0x0",
    "run_op : +DATA_DEST=0x1400",
     #descriptor-1 fields
    "run_op : +DATA_NUM_BYTES2=0x24",
    "run_op : +DATA_DES_CONFIG2=0x4",
    # control reg is shared, but we still pass it
    "run_op : +DATA_SRC2=0x04",
    "run_op : +DATA_DEST2=0x1404"
]


import random

# Generate all valid values
valid_values = []
for upper in range(256):  # 8 bits for bits [9:2]
    for lower in [1, 2]:  # Only allow 01 (1) or 10 (2)
        value = (upper << 2) | 0b01
        valid_values.append(value)

        # Pick one randomly
        selected = random.choice(valid_values)
		# Extract [9:2] and multiply by 4
        upper_bits = selected >> 2
        multiplied = (upper_bits + 1) * 4
		
        #selected_str = str(selected)


for i in range(1,501):
    knob_1 = random.randint(0, 100)
    knob_2 = random.randint(0, 100)
    knob_3 = random.randint(0, 100)
    depth_val = random.choice([512, 1024, 2048, 4096, 8192])

    
    testcase["all_random_test_"+str(i)] = [
	    "run_op : +UVM_TESTNAME=csr_custom_test",
	    "run_op : +UVM_TIMEOUT=500000",
	    "run_op : +UVM_VERBOSITY=UVM_LOW",
	    "run_op : +NUM_DES="+str(random.choice(['single','multi'])),
	    "run_op : +SRC_ADDR_TYPE="+str(random.choice(['AL'])),
	    "run_op : +DEST_ADDR_TYPE="+str(random.choice(['AL'])),
	    "run_op : +BURST_MODE="+str(random.choice(['FI','II','IF','FF'])),
	    "run_op : +DATA_NUM_BYTES=0x"+str(multiplied),
	    "run_op : +DATA_CTRL=0x"+str(selected)
		#descriptor-1 fields
        #"run_op : +DATA_NUM_BYTES2=0x"+str(multiplied)

		        ]







