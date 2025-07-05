#!/bin/sh
# ###########################################
# SCRIPT : DOWNLOAD AND INSTALL Channel
# ###########################################

# Command:
# wget https://raw.githubusercontent.com/emilnabil/channel-mohamed-goda/main/installer.sh -qO - | /bin/sh

###########################################
TMPDIR='/tmp'
PACKAGE='astra-sm'
MY_URL='https://raw.githubusercontent.com/emilnabil/channel-mohamed-goda/main'

########################
VERSION=$(wget "${MY_URL}/version" -qO- | cut -d "=" -f2-)

########################
BINPATH="/usr/bin"
ETCPATH="/etc"
ASTRAPATH="${ETCPATH}/astra"

BBCPMT="${BINPATH}/bbc_pmt_starter.sh"
BBCPY="${BINPATH}/bbc_pmt_v6.py"
BBCENIGMA="${BINPATH}/enigma2_pre_start.sh"

SYSCONF="${ETCPATH}/sysctl.conf"
ASTRACONF="${ASTRAPATH}/astra.conf"
ABERTISBIN="${ASTRAPATH}/scripts/abertis"

CONFIGpmttmp="${TMPDIR}/bbc_pmt_v6/bbc_pmt_starter.sh"
CONFIGpytmp="${TMPDIR}/bbc_pmt_v6/bbc_pmt_v6.py"
CONFIGentmp="${TMPDIR}/bbc_pmt_v6/enigma2_pre_start.sh"
CONFIGsysctltmp="${TMPDIR}/${PACKAGE}/sysctl.conf"
CONFIGastratmp="${TMPDIR}/${PACKAGE}/astra.conf"
CONFIGabertistmp="${TMPDIR}/${PACKAGE}/abertis"

########################
if [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OSTYPE='Opensource'
    OPKG='opkg update'
    OPKGINSTAL='opkg install'
fi

########################
echo "   >>>>   Removing old channel files   <<<<"
rm -rf /etc/enigma2/lamedb
rm -rf /etc/enigma2/*list
rm -rf /etc/enigma2/*.tv
rm -rf /etc/enigma2/*.radio

########################
install() {
    if grep -qs "Package: $1" "${STATUS}"; then
        echo "   >>>>   $1 already installed   <<<<"
    else
        ${OPKG} >/dev/null 2>&1
        echo "   >>>>   Installing $1   <<<<"
        ${OPKGINSTAL} "$1"
        sleep 1
        clear
    fi
}

########################
if [ "${OSTYPE}" = "Opensource" ]; then
    for i in dvbsnoop "${PACKAGE}"; do
        install "$i"
    done
fi

########################
case $(uname -m) in
    armv7l*) platform="arm" ;;
    mips*) platform="mips" ;;
esac

########################
rm -rf "${ASTRACONF}" "${SYSCONF}"
rm -rf "${TMPDIR}/channels_backup_user_${VERSION}"* astra-* bbc_pmt_v6*

########################
echo
set -e
echo "Downloading and installing channel list... Please wait."
wget "${MY_URL}/channels_backup_by-mohamed-goda.tar.gz" -qP "${TMPDIR}"
tar -zxf "${TMPDIR}/channels_backup_by-mohamed-goda.tar.gz" -C /
sleep 5
set +e

echo
echo "   >>>>   Reloading Services - Please Wait   <<<<"
wget -qO - http://127.0.0.1/web/servicelistreload?mode=0 >/dev/null 2>&1
sleep 2
echo

########################
if [ -f "${BBCPMT}" ] && [ -f "${BBCPY}" ] && [ -f "${BBCENIGMA}" ]; then
    echo "   >>>>   All Config BBC Files found   <<<<"
    sleep 2
else
    set -e
    echo "Downloading and installing BBC config files... Please wait."
    wget "${MY_URL}/bbc_pmt_v6.tar.gz" -qP "${TMPDIR}"
    tar -xzf "${TMPDIR}/bbc_pmt_v6.tar.gz" -C "${TMPDIR}"
    set +e
    chmod -R 755 "${TMPDIR}/bbc_pmt_v6"
    sleep 1
    echo "---------------------------------------------"
fi

########################
if [ "${OSTYPE}" = "Opensource" ]; then
    if [ -f "${ASTRACONF}" ] && [ -f "${ABERTISBIN}" ] && [ -f "${SYSCONF}" ]; then
        echo "   >>>>   All Config ${PACKAGE} Files found   <<<<"
        sleep 2
    else
        set -e
        echo "Downloading ${PACKAGE} config files... Please wait."
        wget "${MY_URL}/astra-${platform}.tar.gz" -qP "${TMPDIR}"
        tar -xzf "${TMPDIR}/astra-${platform}.tar.gz" -C "${TMPDIR}"
        set +e
        chmod -R 755 "${TMPDIR}/${PACKAGE}"
        sleep 1
        echo "---------------------------------------------"
        [ ! -f "${SYSCONF}" ] && cp -f "${CONFIGsysctltmp}" "${ETCPATH}" && echo "[send (sysctl.conf) file]"
        [ ! -f "${ASTRACONF}" ] && cp -f "${CONFIGastratmp}" "${ASTRAPATH}" && echo "[send (astra.conf) file]"
        [ ! -f "${ABERTISBIN}" ] && cp -f "${CONFIGabertistmp}" "${ASTRAPATH}/scripts" && echo "[send (abertis) file]"
        echo "---------------------------------------------"
    fi
fi

########################
rm -rf "${TMPDIR}/channels_backup_by-mohamed-goda.tar.gz"
rm -rf ${TMPDIR}/*astra*
rm -rf ${TMPDIR}/*bbc_pmt_v6*

sync
echo ""
echo ""
echo "*********************************************************"
echo "#       Channel And Config INSTALLED SUCCESSFULLY       #"
echo "#            VERSION: ${VERSION}                         #"
echo "#       Uploaded by >>> EMIL_NABIL                      #"
echo "#        Your Device will RESTART now                   #"
echo "*********************************************************"
sleep 4

if [ "${OSTYPE}" = "Opensource" ]; then
    killall -9 enigma2
else
    systemctl restart enigma2
fi

exit 0


