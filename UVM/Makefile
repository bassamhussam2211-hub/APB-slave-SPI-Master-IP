# =============================================================================
# QuestaSim UVM Makefile
# =============================================================================

SIMULATOR ?= questa
SEED      ?= 1
TEST      ?= spi_coverage_reg_test
WAVES     ?= 0

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

PROJ_ROOT ?= ..
HARNESS   ?= $(PROJ_ROOT)/harness

# DUT RTL
DUT_SRCS ?= \
	$(PROJ_ROOT)/golden_rtl/spi_core.sv \
	$(PROJ_ROOT)/golden_rtl/apb_regfile.sv \
	$(PROJ_ROOT)/golden_rtl/spi_master.sv

# Backward compatibility
DUT_SRC ?=

BONUS_TEST ?= ral_hw_reset_test

# -----------------------------------------------------------------------------
# Source Files
# -----------------------------------------------------------------------------

ENV_SRCS = \
	env/apb_agent_pkg.sv \
	env/spi_agent_pkg.sv \
	env/spi_pkg.sv

SEQ_SRCS = \
	sequences/spi_seq_pkg.sv

ASSERT_SRCS = \
	assertions/spi_sva.sv

TEST_SRCS = \
	tests/spi_test_pkg.sv

TB_SRCS = \
	tb/tb_top.sv

# -----------------------------------------------------------------------------
# Include Directories
# -----------------------------------------------------------------------------

INC_DIRS = \
	+incdir+$(HARNESS) \
	+incdir+./env \
	+incdir+./sequences \
	+incdir+./tests \
	+incdir+./tb

# -----------------------------------------------------------------------------
# Regression Tests
# -----------------------------------------------------------------------------

REGRESSION_TESTS = \
	spi_coverage_reg_test \
	spi_stress_interrupt_test \
	spi_timing_features_test

REGRESSION_SEEDS ?= 5

# -----------------------------------------------------------------------------
# Questa Options
# -----------------------------------------------------------------------------

ifeq ($(SIMULATOR),questa)

VLOG_FLAGS = -sv -timescale=1ns/1ps +acc=rn +define+SIM $(INC_DIRS) -L mtiUvm
VSIM_FLAGS = -c -L mtiUvm work.tb_top -voptargs=+acc

# Coverage enabled in compile and runtime
COV_COMPILE = +cover=bcestf
COV_RUN     = -coverage

# Allow grader override
EFF_DUT_SRCS = $(if $(strip $(DUT_SRC)),$(DUT_SRC),$(DUT_SRCS))

# =============================================================================
# Compile
# =============================================================================

compile:
	@mkdir -p build
	vlib work
	vlog $(VLOG_FLAGS) $(COV_COMPILE) \
		$(HARNESS)/apb_if.sv \
		$(HARNESS)/spi_if.sv \
		$(EFF_DUT_SRCS) \
		$(HARNESS)/dut_wrapper.sv \
		$(ENV_SRCS) \
		$(SEQ_SRCS) \
		$(ASSERT_SRCS) \
		$(TEST_SRCS) \
		$(TB_SRCS)

# =============================================================================
# Run Single Test
# =============================================================================

run: compile
	vsim $(VSIM_FLAGS) $(COV_RUN) \
		-do "coverage save -onexit build/cov_$(TEST)_$(SEED).ucdb; run -all; quit -f" \
		+UVM_TESTNAME=$(TEST) \
		+TESTNAME=$(TEST) \
		+SEED=$(SEED) \
		$(if $(filter 1,$(WAVES)),-wlf waves_$(TEST)_$(SEED).wlf,)

# =============================================================================
# Internal Run (No Recompile)
# =============================================================================

run_sim:
	vsim $(VSIM_FLAGS) $(COV_RUN) \
		-do "coverage save -onexit build/cov_$(TEST)_$(SEED).ucdb; run -all; quit -f" \
		+UVM_TESTNAME=$(TEST) \
		+TESTNAME=$(TEST) \
		+SEED=$(SEED)

# =============================================================================
# Bonus RAL Test
# =============================================================================

run_bonus: compile
	vsim $(VSIM_FLAGS) $(COV_RUN) \
		-do "run -all; quit -f" \
		+UVM_TESTNAME=$(BONUS_TEST) \
		+TESTNAME=$(BONUS_TEST) \
		+SEED=$(SEED)

# =============================================================================
# Regression
# =============================================================================

regress: compile
	@mkdir -p build
	@for t in $(REGRESSION_TESTS); do \
		echo "=== Running $$t across $(REGRESSION_SEEDS) seeds ===" ; \
		for s in `seq 1 $(REGRESSION_SEEDS)` ; do \
			echo "Running $$t seed $$s" ; \
			$(MAKE) -s run_sim TEST=$$t SEED=$$s > build/log_$${t}_$${s}.log 2>&1 ; \
		done ; \
	done

	@echo "Merging coverage databases..."
	vcover merge -out build/merged.ucdb build/cov_*.ucdb

# =============================================================================
# Coverage Report
# =============================================================================

cov:
	@if [ -f build/merged.ucdb ]; then \
		vcover report -details build/merged.ucdb > coverage_report.txt ; \
		echo "Coverage report generated." ; \
	else \
		echo "ERROR: merged.ucdb not found." ; \
		exit 1 ; \
	fi

# =============================================================================
# Clean
# =============================================================================

clean:
	rm -rf work build *.wlf *.ucdb *.vstf transcript coverage_report.txt

endif

.PHONY: compile run run_sim regress cov clean run_bonus