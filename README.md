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
3. Restart your computer to complete the installation
   
Now you should be ready to use Linux on your Windows machine!

## Windows Terminal
To access the Linux distribution we just installed, we will need a CLI program (Terminal).
1.	In the Windows search bar, type "Microsoft Store"
2.	In the Microsoft Store, search for "Windows Terminal" and install it
3.	Open Windows Terminal and click the dropdown menu (downward arrow)
–	You should see Ubuntu (or whatever Linux distribution you installed) listed here
4.	Click on Ubuntu, you have now opened your first Linux terminal (shell)

I highly suggest you play around here to get used to using the CLI to navigate your file system. For example, the command  `ls` will **l**i**s**t all of the files in your current directory. To **m**a**k**e a new **dir**ectory (folder), type `mkdir new_dir` where "new_dir" is the name of the new directory. Then if you type `ls` again, you will see your new directory. Then you can use `cd new_dir` to **c**hange **d**irectory to that directory.

In this new directory, if you type `ls` again, you will not see any files because we haven't added any files here. To make a file, use `touch new_file` to make a new file with name "new_file" and `nano new_file` to edit that file. We can also change the name of the file using `mv new_file new_name`. Then `ls` again will show that the file now has a new name. Note that the `mv` command is actually used to **m**o**v**e files. So, we can use `mv new_file ~` to move the file to the home directory (denoted by the variable `~`). Then if we type `ls ~` we can see the new file in our home directory. 

See the link below for a more in depth tutorial on basic shell commands.

[Linux Basics by UChicago](https://uchicago-cs.github.io/student-resource-guide/tutorials/linux-basics.html)

## Setting up Linux
1. Use the command `sudo apt update` to refresh the list of isntalled and installable packages
2. Use the command `sudo apt upgrade` to update all installed packages
3. To run these commands together, use `sudo apt update && sudo apt upgrade`. You should do this before installing any new packages to ensure you have the most up-to-date versions available.

## Setting up Conda
Miniconda is a minimal installer for Conda, Python, their dependencies and a small collection of packages. It is the most commonly used environment manager for Python-based programs and is heavily used in almost all bioinformatics tools. We will be installing Miniconda3 to manage our Python virtual environments. To isntall Miniconda, follow these instructions provided by the University of British Columbia: [Miniconda installation tutorial by UBC](https://educe-ubc.github.io/conda.html).

Conda is a very well-documented program, for a list of common conda commands, see this [cheatsheet](https://docs.conda.io/projects/conda/en/4.6.0/_downloads/52a95608c49671267e40c689e0bc00ca/conda-cheatsheet.pdf).

## Installing a text editor
Text editors are essential to writing scripts. I prefer to use [Sublime Text](https://www.sublimetext.com/) but any rich text editor will do (i.e. notepad++, VSCode, Atom, etc.)
