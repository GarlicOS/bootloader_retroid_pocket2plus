# Installing the bootloader
## If you are on Android 9, you will need to update to Android 11 or LineageOS 19.1 first
To install the MicroSD compatible bootloader on Android 11:
1. Unzip the **microsd\_bootloader\_install\_pocket2plus\_stock11.zip** file.
2. Plug your Retroid Pocket 2+ in to your computer and select **File transfer** on the **Use USB for** prompt on the Retroid Pocket 2+.
3. Copy the contents of the unzipped file (**boot.img**, **flash\_microsd\_bootloader.sh**, **restore\_stock\_bootloader.sh**, and **vbmeta.img**) to Internal shared storage. Do not put it in any sub-folder
4. On your Retroid Pocket 2+, open Settings -> Handheld Settings -> Advanced -> Run script as Root and click **Select a Script**.
5. In the file chooser dialog, navigate to **Retroid Pocket 2+** and select **flash\_microsd\_bootloader.sh**
6. In the dialog asking whether you want to run **flash\_microsd\_bootloader.sh**, click **Run**.
7. The flashing process will likely take close to a minute. Do not press any buttons or turn off the device until it is finished. 
8. Once you seet **Run Script Completed**, the install has finished.

To install the MicroSD compatible bootloader on LineageOS 19.1:
1. Install the latest LineageOS build using the built-in Updater in Settings. The bootloader is included in the lastest update.

### Uninstalling the bootloader
To uninstall the MicroSD compatible bootloader on Android 11:
1. Follow the same steps as installation, but run **restore\_stock\_bootloader.sh** instead.

To uninstall the MicroSD compatible bootloader on LineageOS 19.1:
1. There is no need to uninstall it, since it does not impact OTA updates.

# Creating bootable MicroSD cards
To create a bootable MicroSD card:
1. Format it with an **exfat** filesystem
2. Create a **boot** folder on it
3. Copy an OS **init** script of choice into the **boot** folder (ex. [GarlicOS](https://github.com/GarlicOS/init_template/raw/main/init "this one will do for GarlicOS"))
4. Extract an OS **rootfs** file of choice into the **boot** folder with [7zip](https://www.7-zip.org/download.html "7zip") (ex. [GarlicOS](https://github.com/GarlicOS/buildroot/releases/latest "GarlicOS"))

# Booting bootable MicroSD cards
To boot a bootable MicroSD card:
1. Make sure your device is powered off and **not plugged in**
2. Hold down the **power button** and **volume-up button** at the same time
3. Let go of both buttons once the **Retroid logo** is visible on screen. The device should not vibrate if done correctly
