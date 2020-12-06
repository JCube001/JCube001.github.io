---
layout: post
title: How to Set Up a Raspberry Pi Development Environment
date: 2015-07-06 00:00:00 -0400
tags:
  - raspberry-pi
  - linux
  - eclipse
  - how-to
---

**DEPRECATED** I wrote this guide while toying with the idea of using Eclipse as an IDE for Raspberry Pi development. I now use CMake to configure and build most of my C and C++ projects, and I use Visual Studio Code as my primary text editor.

A how-to guide for getting a Linux host system setup for developing Raspberry Pi kernel modules and applications. This guide will walk through installing the necessary tools and dependencies for building the official Raspberry Pi Linux kernel as well as setting up Eclipse 4.5 Mars as a C/C++ IDE for writing systems code.

## Test System Specs

I performed the instructions laid out in this document on my laptop. I am running Linux Mint 17.2 64-bit.

## Installation

Begin by obtaining the tools and materials necessary to cross compile for your Raspberry Pi.

### Prerequisites

If you are running a Debian or Ubuntu based system, then you may use the commands given here to apt-get all of the prerequisite packages at once. If you are running some other system, you will need to adapt these commands and package names to those recognized by your system.

```bash
sudo apt-get update && sudo apt-get install bc git libncurses5-dev \
openssh-client
```

An explanation of what each package is needed for is given in the following table.

| Package         | Rationale                                                                               |
|-----------------|-----------------------------------------------------------------------------------------|
| bc              | A numeric processing language interpreter which is required to build the kernel.        |
| git             | Source control software used to create a local client of the Raspberry Pi repositories. |
| libncurses5-dev | ncurses development library used by the Linux kernel to generate its menuconfig.        |
| openssh-client  | Needed to make the remote connection with the target board.                             |
| qemu            | Useful for debugging cross compiled kernels and kernel modules.                         |

A serial terminal should also be installed to provide a way to communicate with the Raspberry Pi target board via a serial console. I recommend GNU Screen for this but other tools such as moserial, gtkterm, and, of course, minicom are just as useful when it comes to providing simple serial access. Choose whichever one works best for you.

### Java

The version of Eclipse this document will go over installing is 4.5, codenamed Mars. The [recommended JREs][1] for this version of Eclipse are either Oracle Java 8u45 or Oracle Java 7u80. The simplest way to get an up-to-date version of Oracle's own JRE (and JDK) onto your system is to use the PPA provided by [Web UPD8][2]. I have provided the commands below for installing Java 8.

```bash
sudo add-apt-repository ppa:webudp8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
```

Use `java -version` to verify you have Java 1.8 (aka 8) installed. Note that if need to switch which version of Java your system uses, you can do so by using `update-java-alternatives`.

### Eclipse

As mentioned in the Java section, we will be installing Eclipse 4.5 Mars. Manually downloading and unpacking Eclipse is trivial. Simply navigate to the [Eclipse website][3] and download the [Eclipse IDE for C/C++ Developers][4]. Be sure to download the version for your OS and CPU architecture. Once downloaded, verify the download using some checksum, then unpack the archive to any location which makes sense to you on your system. Eclipse is now installed. You may now create any desktop shortcuts or menu entries for launching the eclipse binary.

### Raspberry Pi Kernel and Tools

The Linux kernel and ARM toolchain for Raspberry Pi systems are hosted on [GitHub][5]. Use the following commands to checkout just the latest versions of these repositories into your Raspberry Pi workspace.

```bash
cd /path/to/your/preferred/workspace
git clone --depth=1 https://github.com/raspberrypi/tools.git
git clone --depth=1 https://github.com/raspberrypi/linux.git
```

## Configuration

Now that everything is installed, you will need to configure your system so the development tools behave as expected.

### Update Path

Start by creating `~/.profile` if you don't have this file already. We'll set the user's per session PATH variable in this file because display managers often source `~/.profile` on login. See the [Ubuntu page on environment variables][6] for more details. Now modify or add the following to your `~/.profile`.

32-bit host:
```bash
export PATH=$PATH:/path/to/your/preferred/workspace/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin
```

64-bit host:
```bash
export PATH=$PATH:/path/to/your/preferred/workspace/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin
```

### Eclipse and Pixel Spacing

There is now some extra work which needs to be done in order to get Eclipse to look good on a modern Linux system running GTK+ 3. What happens is Eclipse uses Java's SWT to draw widgets which look and feel like native widgets on the host system. However, the default properties of most GTK+ 3 widgets make them look large and clunky. The problem has to do with pixel spacing and, thankfully, a number of solutions have been posted online by other Eclipse users.

I have included the solution which worked best for me below. Create the file `~/.gtkrc-2.0` and add the following into it. This solution came from [FabienBK's Blog][7].

```conf
style "compact"
{
GtkButton::default_border={0,0,0,0}
GtkButton::default_outside_border={0,0,0,0}
GtkButtonBox::child_min_width=0
GtkButtonBox::child_min_heigth=0
GtkButtonBox::child_internal_pad_x=0
GtkButtonBox::child_internal_pad_y=0
GtkMenu::vertical-padding=1
GtkMenuBar::internal_padding=1
GtkMenuItem::horizontal_padding=4
GtkToolbar::internal-padding=1
GtkToolbar::space-size=1
GtkOptionMenu::indicator_size=0
GtkOptionMenu::indicator_spacing=0
GtkPaned::handle_size=4
GtkRange::trough_border=0
GtkRange::stepper_spacing=0
GtkScale::value_spacing=0
GtkScrolledWindow::scrollbar_spacing=0
GtkExpander::expander_size=10
GtkExpander::expander_spacing=0
GtkTreeView::vertical-separator=0
GtkTreeView::horizontal-separator=0
GtkTreeView::expander-size=12
GtkTreeView::fixed-height-mode=TRUE
GtkWidget::focus_padding=0

font_name="Liberation Sans,Sans Regular 8"
text[SELECTED] = @selected_text_color
}
class "GtkWidget" style "compact"
style "compact2"
{
xthickness=1
ythickness=1
}
class "GtkButton" style "compact2"
class "GtkToolbar" style "compact2"
class "GtkPaned" style "compact2"
```

You will now need to adjust the environment variable `SWT_GTK3` in order to prevent Eclipse from using SWT with GTK+ 3. To do this, you can simply add `export SWT_GTK3=0` to your `~/.profile`. Start or restart Eclipse and it should now have better looking pixel spacing around all of the tabs, toolbars, and buttons.

[1]: http://www.eclipse.org/eclipse/development/readme_eclipse_4.5.html#TargetOperatingEnvironments
[2]: http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html
[3]: https://www.eclipse.org/home/index.php
[4]: http://www.eclipse.org/downloads/packages/eclipse-ide-cc-developers/marsr
[5]: https://github.com/raspberrypi
[6]: https://help.ubuntu.com/community/EnvironmentVariables
[7]: http://fbksoft.com/6-tips-to-make-eclipse-lighter-prettier-and-more-efficient/
