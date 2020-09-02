![](https://raw.githubusercontent.com/asineth/checkn1x/master/icon.png)
# checkn1x

Linux-based distribution for jailbreaking iOS devices w/ checkra1n.

## Usage

* If you are unsure which one to download, use the ``amd64`` one.
1. Download [Etcher](https://etcher.io) (P.S. I have tried writing the built ISO using Rufus only to encounter a grub rescue screen when booting from the USB.)
2. Open the ``.iso`` you downloaded.
3. Write it to your USB drive.
4. Reboot and enter your BIOS's boot menu.
5. Select the USB drive.

## Building

Edit ``ARCH`` and the corresponding ``CRSOURCE``.

Add something to the ``VERSION`` string if you want to redistribute your image, i.e. ``1.0.6-foo``.

```sh
# debian-based systems
sudo ./build.sh

# docker containers
docker run -it -v $(pwd):/app --rm --privileged debian:sid "cd /app && /app/build.sh"
```
