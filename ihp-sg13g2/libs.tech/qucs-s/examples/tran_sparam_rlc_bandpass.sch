<Qucs Schematic 24.4.1>
<Properties>
  <View=-50,200,1500,1000,1,0,0>
  <Grid=10,10,1>
  <DataSet=tran_sparam_rlc_bandpass.dat>
  <DataDisplay=tran_sparam_rlc_bandpass.dpl>
  <OpenDisplay=0>
  <Script=tran_sparam_rlc_bandpass.m>
  <RunScript=0>
  <showFrame=3>
  <FrameText0=VF S-Parameter Transient: RLC Bandpass>
  <FrameText1=Drawn By:IHP PDK Authors>
  <FrameText2=Date:2024>
  <FrameText3=Revision:1>
</Properties>
<Symbol>
</Symbol>
<Components>
  <INCLSCR INCLSCR1 1 130 400 -60 16 0 0 ".options reltol=1e-3 itl4=200\n" 1 "" 0 "" 0>
  <GND * 1 160 790 0 0 0 0>
  <GND * 1 290 790 0 0 0 0>
  <GND * 1 550 790 0 0 0 0>
  <R R1 1 290 730 15 -26 0 1 "50 Ohm" 1 "" 0 "" 0 "" 0 "" 0 "" 0>
  <R R2 1 550 730 15 -26 0 1 "50 Ohm" 1 "" 0 "" 0 "" 0 "" 0 "" 0>
  <.TR TR1 1 130 470 0 71 0 0 "lin" 1 "0" 1 "40n" 1 "4001" 1 "Trapezoidal" 0 "2" 0 "1 ns" 0 "1e-16" 0 "150" 0 "0.001" 0 "1 pA" 0 "1 uV" 0 "26.85" 0 "1e-3" 0 "1e-6" 0 "1" 0 "CroutLU" 0 "no" 0 "yes" 0 "0" 0>
  <Vpulse V1 1 160 700 18 -26 0 1 "0 V" 1 "1 V" 1 "1 ns" 1 "0.2 ns" 1 "0.2 ns" 1 "5 ns" 1 "20 ns" 1 "0" 0>
  <Lib S1 1 420 640 50 -26 0 0 "$HOME/<qucs_workspace>/user_lib/IHP_PDK_sparam_vf" 0 "sparam_2port" 0 "rlc_bandpass.s2p" 1 "50" 1 "0" 1 "1e-3" 1 "10" 1>
</Components>
<Wires>
  <160 600 160 670 "" 0 0 0 "">
  <160 730 160 790 "" 0 0 0 "">
  <290 760 290 790 "" 0 0 0 "">
  <550 760 550 790 "" 0 0 0 "">
  <160 600 290 600 "in" 240 580 0 "">
  <290 600 290 700 "" 0 0 0 "">
  <290 600 380 600 "" 0 0 0 "">
  <380 600 380 630 "" 0 0 0 "">
  <380 650 380 700 "" 0 0 0 "">
  <460 630 550 630 "" 0 0 0 "">
  <460 650 550 650 "" 0 0 0 "">
  <550 630 550 700 "" 0 0 0 "">
  <550 630 550 630 "out" 560 610 0 "">
  <550 650 550 700 "" 0 0 0 "">
  <380 700 380 700 "" 0 0 0 "">
</Wires>
<Diagrams>
  <Rect 700 850 500 400 3 #c0c0c0 1 00 1 0 1e-8 4e-8 1 -0.3 0.2 0.6 1 -1 0.2 1 315 0 225 1 0 0 "" "" "">
	<"ngspice/v(in)" #0000ff 0 3 0 0 0>
	<"ngspice/v(out)" #ff0000 0 3 0 0 0>
  </Rect>
</Diagrams>
<Paintings>
</Paintings>
