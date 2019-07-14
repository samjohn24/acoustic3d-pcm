# Time-domain Delay-and-Sum Beamformer (bf_time_pcm)

FPGA implementation of a conventional time-domain Delay-and-Sum (DAS) beamformer for Terasic DE1-SoC using Beaglebone Black Microphone Array board.

## Dependencies

Following is the list of dependencies and the expected location path:

### For testing

- Avalon-ST JTAG (1.2.0): ../ip/avalon_st_jtag 
- MIC-IF (1.3.0): ../ip/mic_if
- bf_tester (1.0.0): ../../software/bf_tester

### For FPGA compilation

In addition to testing dependencies:

- Terasic IPs (1.1.0): ../ip_terasic/ 

## Instructions

### For testing

1. In de1-soc/ folder execute ./program.sh
2. Start the server executing ./run_server in ../ip/avalon_st_jtag/system-console folder.
3. Start the 3D viewer executing ./mic_plot_3d.py In ../../software/bf_tester/tests folder.

### For FPGA compilation

In de1-soc/ folder execute ./compile.sh


