# Li-Lab

# Description
This is a collection of scripts and accompanying example datasets that are intended to be used internally for commonly used bioinformatic pipelines including: antismash, bigscape, genome assembly, local blast, and differential abundance analysis. To use these tools, simply click on the folder and follow the installation and usage instructions in the corresponding README.md file. A folder titled "example_data" is included with each pipeline serving as a test case and example for proper script function.

# Setting-up your environment
## Windows Subsystem for Linux
Almost all bioinformatic programs are created without a graphical user interface (GUI, basically a window) and must be used from the command line interface (CLI). We will use Windows Subsystem for Linux (WSL) to install a Linux virtual machine in Windows thus allowing us to use the CLI to control our bioinformatics programs. This is also more convenient as the Linux file system will be accessible from the Windows File Explorer and vice versa.

Refer to this page for details: [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install)

### Installing WSL
1.	Open the search menu and type "Windows Powershell"
2.	Enter one of these commands to install WSL or WSL and Ubuntu:
```
# This will install the default Linux distribution which is Ubuntu. If you want to use a different distribution see below.
wsl --install

# Use this command to choose a specific Linux distribution, here I am using debian
wsl --install -d Debian
```
Now you should be ready to use Linux on your Windows machine!
