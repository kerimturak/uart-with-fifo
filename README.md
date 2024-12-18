# UART Transmitter Module

## Overview
This repository contains an implementation of a Universal Asynchronous Receiver Transmitter (UART) transmitter module designed in SystemVerilog. The module employs a FIFO buffer and a finite state machine (FSM) to manage data transmission.

## Features
- Configurable baud rate for flexible communication speeds.
- FIFO buffer to handle data storage and manage flow control.
- State machine for efficient data processing.
- Handles start, data, and stop bits as per UART protocol.

## Directory Structure
```
.
├── rtl
│   ├── uart_tx.sv         # UART transmitter implementation
│   ├── fifo.sv            # FIFO buffer implementation
├── tb
│   ├── tb.sv              # Testbench
├── Makefile               # For compiling and simulating with ModelSim
```

## Usage

### Simulation
To simulate the design, use the provided Makefile. Ensure that ModelSim or QuestaSim is installed on your system.

1. **Compile the design and testbench:**
   ```
   make compile
   ```

2. **Run the simulation:**
   ```
   make simulate
   ```

3. **Clean up generated files:**
   ```
   make clean
   ```

### Files
- **`uart_tx.sv`**: The main UART transmitter module.
- **`fifo.sv`**: A parameterized FIFO implementation for buffering data.
- **`tb.sv`**: A testbench that generates stimuli for the UART transmitter's behavior.

## How It Works
1. **FIFO Buffer**:
   - Stores data to be transmitted.
   - Handles flow control with `full_o` and `empty_o` signals.

2. **Finite State Machine (FSM)**:
   - **IDLE**: Waits for data in the FIFO.
   - **LOAD**: Loads data from FIFO into the shift register.
   - **SENDING**: Transmits start, data, and stop bits serially.

3. **Baud Clock**:
   - Derived from `baud_div_i` to control the transmission rate.
