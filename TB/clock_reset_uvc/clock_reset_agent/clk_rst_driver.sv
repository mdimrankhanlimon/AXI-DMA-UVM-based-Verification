typedef enum {CLK_1, CLK_2, clk} clock_select_t;
typedef enum {RESET_1, RESET_2, rst_n} reset_select_t;

class clk_rst_driver extends uvm_driver #(clk_rst_seq_item);
    `uvm_component_utils(clk_rst_driver)

    // Sequence item
    clk_rst_seq_item item;

    // Virtual interface for APB
    virtual clk_rst_interface clk_rst_intf;

    // Clock select variable
    clock_select_t clock_select;
    reset_select_t reset_select;

    // Other variables
    int clk_pd;

    function new (string name = "clk_rst_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve the virtual interface
        if (!uvm_config_db#(virtual clk_rst_interface)::get(this, "*", "CLK_RST_INTF", clk_rst_intf))
            `uvm_fatal(get_full_name(), "Could not get apb interface from driver")

        // Retrieve the clock select configuration
        if (!uvm_config_db#(clock_select_t)::get(this, "*", "CLOCK_SELECT", clock_select))
            `uvm_fatal(get_full_name(), "Could not get clock select configuration from driver")

        // Retrieve the reset select configuration
        if (!uvm_config_db#(reset_select_t)::get(this, "*", "RESET_SELECT", reset_select))
            `uvm_fatal(get_full_name(), "Could not get reset select configuration from driver")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            `uvm_info(get_name(), "Waiting for sequence item from sequencer", UVM_HIGH)
            seq_item_port.get_next_item(item);

            // Calculate clock period
            if (item.clk_ctrl) begin
                clock_prd(item.frequency);

                // Start clock generation if enabled
                if (item.clk_enb) begin
                    fork
                        clock_gen(item);
                    join_none
                end

                if (!item.clk_enb) disable fork;
            end

            reset_task(item);
            `uvm_info(get_name(), "Sequence item driving done", UVM_HIGH)
            seq_item_port.item_done();
        end
    endtask

    // Clock period calculation
    task clock_prd(int frequency);
        if (!item.frequency) begin
            `uvm_fatal("CLOCK_ERR", "Clock frequency cannot be zero.")
        end else begin
            clk_pd = 1.0 / (item.frequency * 1e6) * 1e9;
            `uvm_info(get_name(), $sformatf("[%0t] clock period is %0d ns", $time, clk_pd), UVM_MEDIUM)
        end
    endtask

    // Clock generation with dynamic clock selection
    task clock_gen(clk_rst_seq_item item);
        `uvm_info(get_name(), "inside clock_gen task", UVM_MEDIUM)

        while(item.clk_enb) begin
            #(clk_pd / 2);

            // Toggle the selected clock based on clock_select
            case (clock_select)
                CLK_1: clk_rst_intf.CLK_1 = ~clk_rst_intf.CLK_1;
                CLK_2: clk_rst_intf.CLK_2 = ~clk_rst_intf.CLK_2;
                clk: clk_rst_intf.clk = ~clk_rst_intf.clk;
            endcase
			//`uvm_info(get_name(), $sformatf("[%0t] value of selected clock = %0d", $stime, (clock_select == ACLK1) ? clk_rst_intf.CLK_1 : clk_rst_intf.CLK_2), UVM_MEDIUM)
        end
    endtask

    // Reset task
    task reset_task(clk_rst_seq_item item);
        `uvm_info(get_name(), "Resetting device...", UVM_MEDIUM)
        case (reset_select)
            RESET_1: clk_rst_intf.RESET_1 = item.reset;
            RESET_2: clk_rst_intf.RESET_2 = item.reset;
            rst_n: clk_rst_intf.rst_n = item.reset;
        endcase
        `uvm_info(get_name(), "Resetting done", UVM_MEDIUM)
    endtask
endclass

