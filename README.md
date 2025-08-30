# UART Protocol with FIFO Buffers

This project implements a **Universal Asynchronous Receiver/Transmitter (UART) protocol** in Verilog, featuring **8-bit transmitter and receiver modules** with integrated **FIFO buffers**.  
The design enables **reliable, high-speed serial communication** with configurable baud rates up to **921,600 bps**, while ensuring robust data handling through buffering and flow control.

---

## Features

- **Parameterizable UART** supporting flexible data width and baud rates.  
- **Baud Rate Generator** with **32× oversampling** for precise timing.  
- **Transmitter (TX) & Receiver (RX) Modules**
  - TX: Serializes 8-bit parallel data into asynchronous format.  
  - RX: Deserializes incoming serial stream back to parallel data.  
- **FIFO Buffers**
  - 8-depth **TX FIFO** ensures smooth data transmission.  
  - 8-depth **RX FIFO** prevents data loss during reception.  
- **Flow Control & Status Registers**
  - Indicates FIFO full/empty states.  
  - Provides ready/busy flags for handshake with external modules.  
- **Performance**
  - Achieves baud rates up to **921,600 bps**.  
  - Post-synthesis power analysis shows **1.143 W total on-chip power**.  

---

## Implementation Details

### Baud Rate Generator  
- Divides the input clock into a **baud tick** using a programmable divisor.  
- Supports multiple baud rates by changing the divisor parameter.  
- Uses **32× oversampling** in the receiver for accurate start/stop bit detection.  

### Transmitter (TX) Module  
- Accepts 8-bit parallel data from the TX FIFO.  
- Appends **start bit (0)**, data bits (LSB first), optional **parity**, and **stop bit (1)**.  
- Shifts data out serially at the selected baud rate.  
- Provides **TX busy flag** to indicate transmission in progress.  

### Receiver (RX) Module  
- Monitors the serial input line for the **start bit**.  
- Uses oversampling to align sampling at the middle of each bit.  
- Extracts 8-bit data, validates stop bit, and optionally parity.  
- Pushes received data into the RX FIFO.  

### FIFO Buffers  
- **TX FIFO**: Buffers outgoing data to avoid transmission stalls.  
- **RX FIFO**: Buffers incoming data to prevent data loss if CPU/logic is delayed.  
- Depth: 8 entries each (configurable).  
- Provides **full/empty flags** and **overflow/underflow protection**.  


---

## How It Works

1. **Data Transmission**
   - CPU/logic writes 8-bit data into TX FIFO.  
   - TX module fetches data when available, frames it (start + data + stop), and shifts it out.  

2. **Data Reception**
   - RX module continuously listens to the serial line.  
   - When valid data arrives, it reconstructs the 8-bit word and stores it into RX FIFO.  
   - CPU/logic reads data from RX FIFO at its convenience.  

3. **Flow Control**
   - TX and RX FIFOs expose status flags (`empty`, `full`) to prevent overflow/underflow.  
   - Ensures reliable high-speed communication.  

---

## 📖 Example Configuration

- **System Clock:** 50 MHz  
- **Baud Rate:** 115,200 bps (divisor = 27)  
- **FIFO Depth:** 8 entries (default)  
- **Max Baud Rate:** 921,600 bps with oversampling  

---

## 🛠️ Tools & Environment

- **Language**: Verilog HDL  
- **Simulation & Synthesis**: Xilinx Vivado  
## Usage

1. Clone the repository to your local machine:
    
    ```
    git clone <https://github.com/eshav-23/UART-Protocol-with-FIFO-Buffer>
    
    ```
    
2. Open XILINX Vivado and create a new project.
3. Add the Verilog source files from the cloned repository to your project.
4. Synthesize and implement the design.
---





