# Guide for UART Transmitter Module

## Overview
This document provides a detailed guide for the `uart_tx` module, a Universal Asynchronous Receiver Transmitter (UART) transmitter implemented in SystemVerilog. The module uses a FIFO buffer and a finite state machine (FSM) to manage serial data transmission efficiently.

---

## Module Interface

### Inputs
- **`clk_i` (logic):** The system clock input.
- **`rst_ni` (logic):** Active-low asynchronous reset input.
- **`baud_div_i` (logic [15:0]):** Configurable baud rate divisor for generating the baud clock.
- **`tx_we_i` (logic):** Write enable signal for the FIFO buffer.
- **`tx_en_i` (logic):** Transmitter enable signal.
- **`din_i` (logic [7:0]):** 8-bit data to be transmitted serially.

### Outputs
- **`full_o` (logic):** Indicates that the FIFO buffer is full.
- **`empty_o` (logic):** Indicates that the FIFO buffer is empty.
- **`tx_bit_o` (logic):** The serial bit output representing the transmitted data.

---

## Design Details

### Parameters
- **`DEPTH`**: Defines the depth of the FIFO buffer. Default is 32.

### Internal Signals
- **`data` (logic [7:0]):** Data read from the FIFO buffer.
- **`frame` (logic [9:0]):** UART frame consisting of a start bit, data bits, and a stop bit.
- **`bit_counter` (logic [3:0]):** Tracks the current bit being transmitted.
- **`baud_counter` (logic [15:0]):** Generates the baud clock based on `baud_div_i`.
- **`baud_clk` (logic):** Indicates when a baud clock tick occurs.
- **`rd_en` (logic):** FIFO read enable signal.

### States
- **`IDLE`**: Waits for data in the FIFO buffer.
- **`LOAD`**: Loads data from the FIFO buffer into the UART frame.
- **`SENDING`**: Transmits the frame bit-by-bit.

---

## Functional Description

### FIFO Buffer
The module uses an instance of the `wbit_fifo` module to manage data buffering. The FIFO interface includes `write_en`, `read_en`, `write_data`, and `read_data` signals. It ensures smooth data flow even when there are delays in transmission.

### State Machine
The module operates based on a three-state FSM:
1. **`IDLE`**:
   - The module remains in this state when the FIFO is empty or the transmitter is disabled.
   - Transitions to `LOAD` when `tx_en_i` is high and `empty_o` is low.
2. **`LOAD`**:
   - Loads data from the FIFO buffer into the `frame` register.
   - Transitions to `SENDING` immediately.
3. **`SENDING`**:
   - Transmits the UART frame bit-by-bit.
   - Transitions to `LOAD` or `IDLE` depending on the FIFO status after completing the frame.

### UART Frame
The UART frame is generated in the `LOAD` state and consists of:
- **Start Bit**: 1'b0.
- **Data Bits**: The 8-bit data from the FIFO.
- **Stop Bit**: 1'b1.

### Baud Clock
The baud clock controls the timing of data transmission. It is derived using a counter (`baud_counter`) that compares against the `baud_div_i` input. A baud clock tick occurs when the counter reaches `baud_div_i - 1`.

---
