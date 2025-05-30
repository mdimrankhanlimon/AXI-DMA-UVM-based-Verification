//`include "/home/cad_tech_02/LIMON/GITREPO/axi_dma_project/TB/axi4lite_master_uvc/axi4lite_master_sequences/csr_wr_rd_seq.sv"

`include "register_wr_rd_sequence.sv"
`include "sample_sanity_seq.sv"
`include "csr_wr_rd_seq.sv"
`include "sanity_simple_seq.sv"
`include "abort_mid_transfer_seq.sv"
`include "burst_exceeds_4k_boundary_seq.sv"
`include "disable_descriptor_seq.sv"
`include "error_response_seq.sv"
`include "max_burst_configuration_seq.sv"
`include "multiple_burst_seq.sv"
`include "single_burst_seq.sv"
`include "unaligned_source_transfer_seq.sv"
`include "unaligned_destination_transfer_seq.sv"
`include "multiple_descriptor_configuration_seq.sv"
`include "custom_sequence.sv"
`include "same_descriptor_multiple_configuration_seq.sv"
