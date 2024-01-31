#unzip $(ls -td YAAP* | head -n1) payload.bin
#./payload-dumper-go payload.bin
folder=$(ls -td extracted_* | head -n1)
# wait for device to enter fastboot mode
#while true; do
#    fastboot devices 2>&1 >/dev/null && break
#    sleep 1
#done

# device is in fastboot mode, execute your code here
echo "Device is in fastboot mode, executing code..."
fastboot devices
fastboot --set-active=a
fastboot flash boot $folder/boot.img
fastboot flash dtbo $folder/dtbo.img
fastboot flash odm $folder/odm.img
fastboot flash system $folder/system.img
fastboot flash vbmeta $folder/vbmeta.img
fastboot flash vendor $folder/vendor.img
fastboot --set-active=b
fastboot flash boot $folder/boot.img
fastboot flash dtbo $folder/dtbo.img
fastboot flash odm $folder/odm.img
fastboot flash system $folder/system.img
fastboot flash vbmeta $folder/vbmeta.img
fastboot flash vendor $folder/vendor.img
fastboot reboot
