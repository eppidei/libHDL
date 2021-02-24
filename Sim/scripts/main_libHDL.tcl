onerror {abort}
if ![info exists ::env(MODELSIMINI)] { 
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!ERROR -> PLEASE SET MODELSIMINI ENVIRONMENT VARIABLE ......."
}
if ![info exists ::env(LIBHDL_HOME)] { 
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!ERROR -> PLEASE SET LIBHDL_HOME ENVIRONMENT VARIABLE ......."
  echo "please use slash(/) and not back-slash(\) as path separator"
} elseif { [ string match "" $::env(LIBHDL_HOME) ] } { 
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!ERROR -> PLEASE FILL LIBHDL_HOME ENVIRONMENT VARIABLE ......."
  echo "please use slash(/) and not back-slash(\) as path separator"
} else {

set LIBHDL_HOME_TCL    $::env(LIBHDL_HOME)
set LIBHDL_SIM_FOLDER  $LIBHDL_HOME_TCL/Sim
set LIBHDL_SCRIPTS     $LIBHDL_SIM_FOLDER/scripts
set LIBHDL_OBJ         $LIBHDL_SIM_FOLDER/obj
set LIBHDL_MAP         $LIBHDL_SIM_FOLDER/map
set LIBHDL_SRC         $LIBHDL_HOME_TCL/src
set LIBHDL_PKGS        $LIBHDL_SRC/packages
set LIBHDL_BASEIP      $LIBHDL_SRC/BaseIP
set LIBHDL_OUTPUTS $LIBHDL_SIM_FOLDER/products
set VCOMOPT "-2008 -fsmverbose btw -l $LIBHDL_OUTPUTS/transcript -lint "
#set VLOGOPT ""

#set SIMINI $LIBHDL_SIM_FOLDER/modelsim.ini
#set LOCALINI $LIBHDL_SCRIPTS/modelsim.ini

set LibHdlPackages "
$LIBHDL_PKGS/Constants/Constants_Dpkg.vhd 
$LIBHDL_PKGS/Misc/Utilities_Dpkg.vhd 
$LIBHDL_PKGS/Misc/Utilities_Bpkg.vhd 
$LIBHDL_PKGS/Protocols/Amba2_Dpkg.vhd 
$LIBHDL_PKGS/Protocols/Amba2_Bpkg.vhd 
$LIBHDL_PKGS/Protocols/AXI4_Dpkg.vhd 
$LIBHDL_PKGS/Protocols/Axis_Dpkg.vhd 
$LIBHDL_PKGS/Protocols/FabricBus_Dpkg.vhd 
$LIBHDL_PKGS/Protocols/FabricBus_Bpkg.vhd"

set LibHdlBaseIP "
$LIBHDL_BASEIP/Counters/Counter.vhd 
$LIBHDL_BASEIP/Registers/FFs/FFRegisters.vhd 
$LIBHDL_BASEIP/Registers/APB/APBFFArray.vhd 
$LIBHDL_BASEIP/Registers/AXI/AXIFFArray.vhd 
$LIBHDL_BASEIP/ShiftRegisters/ShiftRegisterFixedLength.vhd 
$LIBHDL_BASEIP/AmbaHandlers/AXILiteSlaveHandler.vhd"

}



# ----------------------------------------
# PROCEDURES
# -----------------------------------------

proc ensure_lib { lib } { 
echo "ensuring $lib"
if ![file isdirectory $lib] { 
vlib $lib } else {

echo " lib $lib already exist "
}
}
proc delete_lib { lib } { 
echo "deleting $lib"
if [file isdirectory $lib] { 
vdel -all -lib $lib } else {

echo " lib $lib 2 delete not found"
}
}

#vmap -modelsimini $ini $lib $map} else {
proc map_lib { libtargetdir lib map} { 
echo "$lib $map "
set libpath $libtargetdir/$lib
if [file isdirectory $libpath] { 
vmap $lib $map} else {
echo "no lib to map found"

} 
}

#vmap -modelsimini $ini -del $lib} else {
proc unmap_lib { libtargetdir lib  } { 
echo "$lib "
if [file isdirectory $libtargetdir] { 
vmap -del $lib} else {
echo "no lib to unmap found"

}
}

proc comp_vhdl_lib { src libpath lib opt} { 
echo "$src $lib $opt"
set objlib $libpath/$lib
set locallib $lib
if [file isdirectory $objlib] { 
eval vcom $opt $src  -work  $objlib
#ensure_lib $locallib
#map_lib $libpath $lib $objlib
} else {

echo "even if not strictly necessary before compiling create empty lib $lib using create_obj aliases"

}
}

proc proc_libhdl_lib {FOLD COMMAND} {

echo "${FOLD} $COMMAND"

if [string match $COMMAND "create"] {
echo "creating libhdl_lib"
ensure_lib ${FOLD}/libHDL

} elseif [string match $COMMAND "delete"] {
echo "deleting libhdl_lib"
delete_lib ${FOLD}/libHDL

}

}

# ----------------------------------------
# ALIASES
# -----------------------------------------

# create
alias create_libhdl_obj_lib {
echo "\[exec\] create_libhdl_obj_lib"
proc_libhdl_lib $LIBHDL_OBJ "create"
}

alias create_libhdl_map_lib {
echo "\[exec\] create_libhdl_map_lib"
proc_libhdl_lib $LIBHDL_MAP "create"
}



#delete

alias delete_libhdl_obj_lib {
echo "\[exec\] delete_libhdl_obj_lib"
proc_libhdl_lib $LIBHDL_OBJ "delete"
}

alias delete_libhdl_map_lib {
echo "\[exec\] delete_libhdl_map_lib"
proc_libhdl_lib $LIBHDL_MAP "delete"
}

#map

alias map_libhdl {
echo "\[exec\] map_libhdl"                          $SIMINI
map_lib  $LIBHDL_MAP libHDL  ${LIBHDL_OBJ}/libHDL  

}

alias unmap_libhdl {
echo "\[exec\] unmap_libhdl"
unmap_lib  $LIBHDL_MAP libHDL                                

}

alias tbvhd_com {
echo "\[exec\] tbvhd_com"

}

alias compile_libhdl_pkgs {
echo "\[exec\] compile packages"

foreach i $LibHdlPackages {
comp_vhdl_lib $i ${LIBHDL_OBJ} libHDL $VCOMOPT
}
}

alias compile_libhdl_BaseIp {
echo "\[exec\] compile packages"

foreach i $LibHdlBaseIP {
comp_vhdl_lib $i ${LIBHDL_OBJ} libHDL $VCOMOPT
}
}

alias compile_libhdl {
echo "\[exec\] compile_libhdl"
compile_libhdl_pkgs    
compile_libhdl_BaseIp                                                       
}

alias create_libs {
echo "\[exec\] create_libs"
 create_libhdl_obj_lib
 create_libhdl_map_lib
}

alias delete_libs {
echo "\[exec\] delete_libs"
 delete_libhdl_obj_lib
 delete_libhdl_map_lib
}

alias map_libs {
echo "\[exec\] map_libs"
map_libhdl
}

alias unmap_libs {
echo "\[exec\] unmap_libs"
unmap_libhdl
}

alias cleanlib {
echo "\[exec\] cleanlib"
delete_libs

}

alias buildlib {
echo "\[exec\] buildlib"
create_libs
compile_libhdl
map_libs

}

alias rebuildlib {
echo "\[exec\] rebuildlib"
cleanlib
buildlib
}

alias elab_vhdltb {

echo "\[exec\] elab_vhdltb"
onerror { abort; cd $LIBHDL_SCRIPTS; }
onElabError { abort; cd $LIBHDL_SCRIPTS; }
set _BACK [pwd]
cd ${LIBHDL_SIM_FOLDER}
#vsim libHDL.elibHDL_ip_tb  -fsmdebug -msgmode both -displaymsgmode both  -L pll_altera_iopll_161 -L altera_ver  -L altera_mf_ver -L altera_lnsim_ver -L altera_lnsim -L DDR3_tb_altera_merlin_slave_translator_161  -L DDR3_tb_altera_merlin_master_translator_161 -L DDR3_tb_altera_reset_controller_161 -L DDR3_tb_altera_mm_interconnect_161 -L DDR3_tb_altera_avalon_onchip_memory2_161 -L DDR3_tb_altera_avalon_mm_bridge_161 -L DDR3_tb_altera_emif_cal_slave_nf_161 -L DDR3_tb_altera_emif_arch_nf_161 -L DDR3_tb_altera_emif_161 -L twentynm_ver -l transcript.txt -wlf $LIBHDL_WLFPATH/libHDLvhdl.wlf -t ps
}

alias run_vhdltb {

echo "\[exec\] run_vhdltb"
rebuildlib
elab_vhdltb

}

alias mquit {

quit -sim;
cd $LIBHDL_SCRIPTS;

}

proc set_msimpath {gg} {

setenv MODELSIMINI $gg
}

alias  setmodelsimini { 

set_msimpath 
}
# ----------------------------------------
# Print out user commmand line aliases
alias _help {
  echo "List Of Command Line Aliases"
  echo
  echo "run_vhdltb                   -- run vhdl testbench recompiling altera libs"
  echo
  echo "rebuildlib                   -- clean all build all"
  echo
  echo "cleanlib                     -- delete all libs"
  echo
  echo "setmodelsimini               -- set reference .modelsimini"
  echo
  echo "mquit                        -- quit simulation and return to script folder"
  echo
  echo "_help                        -- shows this help"
  echo
  echo "List Of Variables"
  echo
  echo "LIBHDL_HOME                -- Environment variable to be set to define project tree root"
}
_help