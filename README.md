# Time-domain Delay-and-Sum Beamformer (bf_time_pcm)

FPGA implementation of a conventional time-domain Delay-and-Sum (DAS) beamformer for [Terasic DE1-SoC](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836) using [Beaglebone Black Microphone Array board](https://github.com/marcelodaher/memsarray).

## Dependencies

Following is the list of dependencies and the expected location paths:

- Avalon-ST JTAG (1.2.0): ../ip/avalon_st_jtag 
- MIC-IF (1.4.1): ../ip/mic_if
- bf_tester (1.2.0): ../bf_tester

### Additional dependencies for a full compilation

In addition to testing dependencies:

- Terasic IPs (1.1.0): ../ip_terasic/ 

## Connection

See the connection diagram [here](doc/bbb2de1soc.svg).

## Running the 3D camera

!. Clone dependencies in paths mentioned above.
2. In de1-soc/ folder execute ./program.sh
3. Start the server executing ./run_server in ../ip/avalon_st_jtag/system-console folder.
4. Start the 3D viewer executing ./mic_plot_3d.py In ../bf_tester folder.

## Re-compiling FPGA images

Clone additional dependencies and in de1-soc/ folder execute ./compile.sh