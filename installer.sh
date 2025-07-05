#!/bin/sh
# ###########################################
# SCRIPT : DOWNLOAD AND INSTALL Channel
# ###########################################
# Command:
# wget https://raw.githubusercontent.com/emilnabil/channel-mohamed-goda/main/installer.sh -qO - | /bin/sh

TMPDIR='/tmp'
PACKAGE='astra-sm'
MY_URL='https://raw.githubusercontent.com/emilnabil/channel-mohamed-goda/main'

VERSION=$(wget "${MY_URL}/version" -qO- | cut -d "=" -f2-)

if [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OSTYPE='Opensource'
fi

echo ">>> Removing old channel files..."
rm -rf /etc/enigma2/lamedb
rm -rf /etc/enigma2/*list
rm -rf /etc/enigma2/*.tv
rm -rf /etc/enigma2/*.radio

echo
echo ">>> Downloading and installing channel list... Please wait."
wget "${MY_URL}/channels_backup_by-mohamed-goda.tar.gz" -qP "${TMPDIR}"
tar -zxf "${TMPDIR}/channels_backup_by-mohamed-goda.tar.gz" -C /
sleep 2

echo
echo ">>> Reloading Services - Please wait..."
wget -qO - http://127.0.0.1/web/servicelistreload?mode=0 >/dev/null 2>&1
sleep 2

rm -rf "${TMPDIR}/channels_backup_by-mohamed-goda.tar.gz"
sync

echo ""
echo "*********************************************************"
echo "#     Channel And Config INSTALLED SUCCESSFULLY        #"
echo "#           VERSION: ${VERSION}                        #"
echo "#     Uploaded by >>> EMIL_NABIL                       #"
echo "#     Your Device will RESTART now                     #"
echo "*********************************************************"
sleep 4

if [ "${OSTYPE}" = "Opensource" ]; then
    killall -9 enigma2
else
    systemctl restart enigma2
fi

exit 0


