v {xschem version=3.4.6 file_version=1.2
* VF Transient: Two cascaded S-param blocks
* Tests multiple VF instances in same circuit
* Two RC lowpass sections in series => steeper rolloff
* Expected: v(mid) filtered, v(out) more filtered (double filtering)
}
G {}
K {}
V {}
S {}
E {}
B 2 510 -650 1070 -350 {flags=graph
y1=-0.1
y2=0.55
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=4e-08
divx=5
subdivx=1
node="in
mid
out"
color="4 14 7"
dataset=-1
unitx=1
logx=0
logy=0
sim_type=tran
autoload=1}
T {VF S-Parameter Transient Test: Cascade} 50 -720 0 0 0.4 0.4 {}
T {Two cascaded RC lowpass S-param blocks.} 50 -680 0 0 0.25 0.25 {layer=8}
T {v(out) is more filtered than v(mid) (double lowpass).} 50 -660 0 0 0.25 0.25 {layer=8}
N 150 -400 150 -370 {
lab=GND}
N 150 -500 150 -460 {
lab=in}
N 150 -500 250 -500 {
lab=in}
N 250 -500 280 -500 {
lab=in}
N 280 -500 280 -470 {
lab=in}
N 150 -370 150 -350 {
lab=GND}
N 280 -410 280 -350 {
lab=GND}
N 380 -500 430 -500 {
lab=mid}
N 430 -500 460 -500 {
lab=mid}
N 560 -500 610 -500 {
lab=out}
N 610 -500 610 -470 {
lab=out}
N 610 -410 610 -350 {
lab=GND}
C {devices/code_shown.sym} 50 -300 0 0 {name=NGSPICE only_toplevel=true
value="
.options reltol=1e-3 itl4=200
.tran 0.01n 40n
.control
run
write tran_sparam_cascade.raw
.endc
"}
C {devices/vsource.sym} 150 -430 0 0 {name=V1 value="PULSE(0 1 1n 0.2n 0.2n 5n 20n)"}
C {devices/gnd.sym} 150 -350 0 0 {name=l1 lab=GND}
C {devices/gnd.sym} 280 -350 0 0 {name=l2 lab=GND}
C {devices/gnd.sym} 610 -350 0 0 {name=l4 lab=GND}
C {devices/res.sym} 280 -440 0 0 {name=R1
value=50
footprint=1206
device=resistor
m=1}
C {devices/res.sym} 610 -440 0 0 {name=R2
value=50
footprint=1206
device=resistor
m=1}
C {devices/title.sym} 160 -30 0 0 {name=l5 author="Copyright 2024 IHP PDK Authors"}
C {devices/lab_pin.sym} 250 -500 0 0 {name=p1 sig_type=std_logic lab=in}
C {devices/lab_pin.sym} 430 -500 0 0 {name=p2 sig_type=std_logic lab=mid}
C {devices/lab_pin.sym} 610 -500 0 1 {name=p3 sig_type=std_logic lab=out}
C {sg13g2_pr/sparam_2port.sym} 330 -490 0 0 {name=S1
file=\{tcleval($::PDK_ROOT/$::PDK/libs.tech/ngspice/touchstone/rc_lowpass.s2p)\}
r_ref=50
n_poles=0
vf_tol=1e-3
vf_maxiter=10
name_mod=lp_stage1
}
C {sg13g2_pr/sparam_2port.sym} 510 -490 0 0 {name=S2
file=\{tcleval($::PDK_ROOT/$::PDK/libs.tech/ngspice/touchstone/rc_lowpass.s2p)\}
r_ref=50
n_poles=0
vf_tol=1e-3
vf_maxiter=10
name_mod=lp_stage2
}
C {devices/launcher.sym} 720 -310 0 0 {name=h1
descr="Load waves"
tclcommand="
xschem raw_read $netlist_dir/[file rootname [file tail [xschem get current_name]]].raw tran
xschem setprop rect 2 0 fullxzoom
"
}
C {launcher.sym} 720 -340 0 0 {name=h2
descr=Simulate
tclcommand="
set_sim_defaults
set sim(spice,1,cmd) \{ngspice  \\"$N\\" -a\}
set sim(spice,default) 0
xschem netlist
simulate
"}
