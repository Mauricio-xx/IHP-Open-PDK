v {xschem version=3.4.6 file_version=1.2
* VF Transient: RLC bandpass S-param (resonance at 3.16 GHz)
* Tests VF with conjugate pole pairs from a resonant network
* Expected: output shows ringing at ~3.16 GHz after pulse edge
}
G {}
K {}
V {}
S {}
E {}
B 2 510 -650 1070 -350 {flags=graph
y1=-0.3
y2=0.6
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
out"
color="4 7"
dataset=-1
unitx=1
logx=0
logy=0
sim_type=tran
autoload=1}
T {VF S-Parameter Transient Test: RLC Bandpass} 50 -720 0 0 0.4 0.4 {}
T {Series RLC bandpass with resonance at 3.16 GHz.} 50 -680 0 0 0.25 0.25 {layer=8}
T {Output shows ringing from conjugate VF poles.} 50 -660 0 0 0.25 0.25 {layer=8}
N 200 -400 200 -370 {
lab=GND}
N 200 -500 200 -460 {
lab=in}
N 200 -500 300 -500 {
lab=in}
N 300 -500 350 -500 {
lab=in}
N 350 -500 350 -470 {
lab=in}
N 200 -370 200 -350 {
lab=GND}
N 350 -410 350 -350 {
lab=GND}
N 450 -500 500 -500 {
lab=out}
N 500 -500 500 -470 {
lab=out}
N 500 -410 500 -350 {
lab=GND}
C {devices/code_shown.sym} 50 -300 0 0 {name=NGSPICE only_toplevel=true
value="
.options reltol=1e-3 itl4=200
.tran 0.01n 40n
.control
run
write tran_sparam_rlc_bandpass.raw
.endc
"}
C {devices/vsource.sym} 200 -430 0 0 {name=V1 value="PULSE(0 1 1n 0.2n 0.2n 5n 20n)"}
C {devices/gnd.sym} 200 -350 0 0 {name=l1 lab=GND}
C {devices/gnd.sym} 350 -350 0 0 {name=l2 lab=GND}
C {devices/gnd.sym} 500 -350 0 0 {name=l3 lab=GND}
C {devices/res.sym} 350 -440 0 0 {name=R1
value=50
footprint=1206
device=resistor
m=1}
C {devices/res.sym} 500 -440 0 0 {name=R2
value=50
footprint=1206
device=resistor
m=1}
C {devices/title.sym} 160 -30 0 0 {name=l5 author="Copyright 2024 IHP PDK Authors"}
C {devices/lab_pin.sym} 300 -500 0 0 {name=p1 sig_type=std_logic lab=in}
C {devices/lab_pin.sym} 500 -500 0 1 {name=p2 sig_type=std_logic lab=out}
C {sg13g2_pr/sparam_2port.sym} 400 -490 0 0 {name=S1
file=\{tcleval($::PDK_ROOT/$::PDK/libs.tech/ngspice/touchstone/rlc_bandpass.s2p)\}
r_ref=50
n_poles=0
vf_tol=1e-3
vf_maxiter=10
name_mod=bandpass_model
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
