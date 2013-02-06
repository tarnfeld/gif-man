# GifMan

A [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php) bundle and skype chat style for inline images/videos and other awesomeness for **Skype 6 Mac**. Credit to [SkypeInlineImage](https://github.com/netpro2k/SkypeImageInline) for the original implementation. A love child born out
of the need for INSTANT GIFS at [Duedil](http://github.com/duedil-ltd).

## Getting started

### Requirements

- Xcode 4 (+ Command Line Tools)


### Building / Installing

You'll need to build the project (both the bundle, and the skype style) before you can use it, there are various `make` targets to help with this. You can do everything by simply running the following;

```bash
git clone git@github.com:tarnfeld/gif-man
cd gif-man
make && make install
```

**Compilation**

The `make` command will clean up any existing build products, and re-build both the bundle and the chat style. You can run each of these actions seperately...

```bash
make clean # Clean products
make clean-style # Clean out the chat style products
make clean-bundle # Clean out the bundle products

make build # Build all the products
make build-style # Build the chat style products
make build-bundle # Build the bundle products
```

**Installation**

The installation process will also attempt to install a working SIMBL agent if there isn't one already running. It will copy a working SIMBL agent into `~/Library/Application Support/SIMBL/SIMBLAgent.app` and also
create a launch agent to make sure it's always running (after a reboot). If you don't want the make file to mess around with any of that, you can install the components seperately...

```bash
make install # Verify / Install SIMBL, the bundle and the style
make install-style # Install the chat style
make install-bundle # Install the bundle
```

**Installing SIMBL**

You can also install SIMBL seperately if you like...

```bash
make simbl
```

