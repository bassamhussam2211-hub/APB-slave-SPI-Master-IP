file mkdir build
if {[file exists work]} {vdel -lib work -all}
vlib work
vlog -sv -timescale=1ns/1ps +acc=rn +define+SIM +UVM_NO_RELNOTES -L mtiUvm +cover=bcestf -f questa_files.f
set tests {
  
    randomized_stress_test
}
foreach test $tests {
    puts "=== Running $test ==="
    vsim -coverage -L mtiUvm work.tb_top +UVM_TESTNAME=$test +TESTNAME=$test +SEED=1 +UVM_NO_RELNOTES
    onfinish stop
    run -all
    coverage save build/cov_${test}_1.ucdb
}
set ucdbs [glob -nocomplain build/cov_*.ucdb]
if {[llength $ucdbs] > 0} {
    vcover merge -out build/merged.ucdb {*}$ucdbs
    vcover report -details build/merged.ucdb > coverage_report.txt
}
