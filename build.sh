#!/bin/sh
set -ex
##############################################################################
#    Open LiteSpeed is an open source HTTP server.                           #
#    Copyright (C) 2013 - 2019 LiteSpeed Technologies, Inc.                  #
#                                                                            #
#    This program is free software: you can redistribute it and/or modify    #
#    it under the terms of the GNU General Public License as published by    #
#    the Free Software Foundation, either version 3 of the License, or       #
#    (at your option) any later version.                                     #
#                                                                            #
#    This program is distributed in the hope that it will be useful,         #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            #
#    GNU General Public License for more details.                            #
#                                                                            #
#    You should have received a copy of the GNU General Public License       #
#    along with this program. If not, see http://www.gnu.org/licenses/.      #
##############################################################################

###    Author: dxu@litespeedtech.com (David Shue)

VERSION=1.0.0

moduledir="modreqparser modinspector uploadprogress "
OS=`uname`
ISLINUX=no


if [ "${OS}" = "FreeBSD" ] ; then
    APP_MGRS="pkg"
elif [ "${OS}" = "Linux" ] ; then
    APP_MGRS="apk"
elif [ "${OS}" = "Darwin" ] ; then
    APP_MGRS="port brew"
else
    echo 'Operating System not Linux, Mac and FreeBSD, quit.'
    exit 1
fi

APP_MGR_CMD=
for APP_MGR in ${APP_MGRS}; do
  APP_MGR_CHECK=`which ${APP_MGR} &>/dev/null`
  if [ $? -eq 0 ] ; then
    APP_MGR_CMD="${APP_MGR}"
    break
  fi
done

echo OS is ${OS}, APP_MGR_CMD is ${APP_MGR_CMD}.
if [ "x${APP_MGR_CMD}" = "x" ] ; then 
    echo 'Can not find package installation command, quit.'
    exit 1
fi


installCmake()
{
    ${APP_MGR_CMD} add git cmake
    if [ $? = 0 ] ; then
        echo cmake installed.
    else
        version=3.14
        build=5
        mkdir cmaketemp
        CURDIR=`pwd`
        cd ./cmaketemp
        wget https://cmake.org/files/v${version}/cmake-${version}.${build}.tar.gz
        tar -xzvf cmake-${version}.${build}.tar.gz
        cd cmake-${version}.${build}/
        
        ./bootstrap
        make -j4
        make install
        cmake --version
        cd ${CURDIR}
    fi
}

installgo()
{
    #${APP_MGR_CMD} add go
    #if [ $? = 0 ] ; then
    #    echo go installed.
    #else
        wget https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
        tar -xvf go1.6.linux-amd64.tar.gz
        mv -f go /usr/local
        export PATH=/usr/local/go/bin:${PATH}
    #fi
}


prepareLinux()
{
        
        apk update
        apk add curl
        apk add make
        
        apk add clang 
        apk add patch 
        apk add expat-dev
        
        #installCmake
        apk add git libtool build-base
        apk add autoconf
        apk add automake 
        #installgo
      
}


commentout()
{
    sed -i -e "s/$1/#$1/g" $2
}



updateSrcCMakelistfile()
{   
    OS=`uname`
    commentout 'add_definitions(-DRUN_TEST)'                 CMakeLists.txt 
    commentout 'add_definitions(-DPOOL_TESTING)'             CMakeLists.txt
    commentout 'add_definitions(-DTEST_OUTPUT_PLAIN_CONF)'   CMakeLists.txt
    commentout 'add_definitions(-DDEBUG_POOL)'   CMakeLists.txt
    
    commentout 'set(libUnitTest'  CMakeLists.txt
    
    commentout 'find_package(ZLIB'  CMakeLists.txt
    commentout 'find_package(PCRE'  CMakeLists.txt
   # commentout 'find_package(EXPAT REQUIRED)'
    commentout 'add_subdirectory(test)'   CMakeLists.txt
    
    
    commentout 'SET (CMAKE_C_COMPILER'  CMakeLists.txt
    commentout 'SET (CMAKE_CXX_COMPILER'   CMakeLists.txt
    
    sed -i -e "s/\${unittest_STAT_SRCS}//g"  src/CMakeLists.txt
    
    commentout  ls_llmq.c  src/lsr/CMakeLists.txt
    commentout  ls_llxq.c  src/lsr/CMakeLists.txt
    
    if [ "${OS}" = "Darwin" ] ; then
        sed -i -e "s/ rt//g" src/CMakeLists.txt
        sed -i -e "s/ crypt//g"  src/CMakeLists.txt
        sed -i -e "s/gcc_eh//g"  src/CMakeLists.txt
        sed -i -e "s/c_nonshared//g"  src/CMakeLists.txt
        sed -i -e "s/gcc//g"  src/CMakeLists.txt
        sed -i -e "s/-Wl,--whole-archive//g"  src/CMakeLists.txt
        sed -i -e "s/-Wl,--no-whole-archive//g"  src/CMakeLists.txt
    fi
    
}

updateModuleCMakelistfile()
{
    echo "cmake_minimum_required(VERSION 2.8)" > src/modules/CMakeLists.txt
    echo "add_subdirectory(modgzip)" >> src/modules/CMakeLists.txt
    
    if [ "${OS}" = "Darwin" ] ; then
        echo Mac OS bypass all module right now
    else
        for module in ${moduledir}; do
            echo "add_subdirectory(${module})" >> src/modules/CMakeLists.txt
        done
    fi
    
    if [ "${ISLINUX}" = "yes" ] ; then
        echo "add_subdirectory(pagespeed)" >> src/modules/CMakeLists.txt
        echo "add_subdirectory(modsecurity-ls)" >> src/modules/CMakeLists.txt
    fi
}

preparelibquic()
{
    if [ -e lsquic ] ; then
        ls src/ | grep liblsquic
        if [ $? -eq 0 ] ; then
            echo Need to git download the submodule ...
            rm -rf lsquic
            git clone https://github.com/litespeedtech/lsquic.git
            cd lsquic
            
            LIBQUICVER=`cat ../LSQUICCOMMIT`
            echo "LIBQUICVER is ${LIBQUICVER}"
            git checkout ${LIBQUICVER}
            git submodule update --init --recursive
            cd ..
            
            #cp files for autotool
            rm -rf src/liblsquic
            mv lsquic/src/liblsquic src/
            
            rm include/lsquic.h
            mv lsquic/include/lsquic.h  include/
            rm include/lsquic_types.h
            mv lsquic/include/lsquic_types.h include/
            
        fi
    fi
}

cpModuleSoFiles()
{
    if [ ! -d dist/modules/ ] ; then
        mkdir dist/modules/
    fi
    
    for module in ${moduledir}; do
        cp -f src/modules/${module}/*.so dist/modules/
    done
}

fixshmdir()
{
    if [ ! -d /dev/shm ] ; then
        mkdir /tmp/shm
        chmod 777  /tmp/shm
        sed -i -e "s/\/dev\/shm/\/tmp\/shm/g" dist/conf/httpd_config.conf.in
    fi
}


cd `dirname "$0"`
CURDIR=`pwd`



    ISLINUX=yes
    #prepareLinux

updateSrcCMakelistfile
updateModuleCMakelistfile
preparelibquic



cd ..
git clone https://github.com/litespeedtech/third-party.git
mv third-party thirdparty
mkdir thirdparty/lib64
cd thirdparty/script/

# Build libmodsec first
#sed -i "s|BUILD_LIBS=.*|BUILD_LIBS='libmodsec brotli zlib bssl expat geoip ip2loc libmaxminddb luajit pcre psol udns unittest-cpp lmdb curl libxml2'|g" build_ols.sh

sed -i -e "s/unittest-cpp/ /g" ./build_ols.sh

if [ "${ISLINUX}" != "yes" ] ; then
    sed -i -e "s/psol/ /g"  ./build_ols.sh
fi

./build_ols.sh

cd ${CURDIR}
STDC_LIB=`g++ -print-file-name='libstdc++.a'`
cp ${STDC_LIB} ../thirdparty/lib64/
cp ../thirdparty/src/brotli/out/*.a          ../thirdparty/lib64/
cp ../thirdparty/src//libxml2/.libs/*.a      ../thirdparty/lib64/
cp ../thirdparty/src/libmaxminddb/include/*  ../thirdparty/include/

#special case modsecurity
cd src/modules/modsecurity-ls
ln -sf ../../../../thirdparty/src/ModSecurity .
cd ../../../
#Done of modsecurity

fixshmdir

cmake .
make
cp src/openlitespeed  dist/bin/

cpModuleSoFiles

#Version >= 1.6.0 which has QUIC need to fix for freebsd
if [ -e src/liblsquic ] ; then 
    freebsdFix
fi

cat >> ./ols.conf <<END 
#If you want to change the default values, please update this file.
#

SERVERROOT=/usr/local/lsws
OPENLSWS_USER=nobody
OPENLSWS_GROUP=nobody
OPENLSWS_ADMIN=admin
OPENLSWS_PASSWORD=123456
OPENLSWS_EMAIL=root@localhost
OPENLSWS_ADMINSSL=yes
OPENLSWS_ADMINPORT=7080
USE_LSPHP7=yes
DEFAULT_TMP_DIR=/tmp/lshttpd
PID_FILE=/tmp/lshttpd/lshttpd.pid
OPENLSWS_EXAMPLEPORT=8088

END


echo Start to pack files.
mv dist/install.sh  dist/_in.sh

cat >> ./install.sh <<END 
#!/bin/sh

SERVERROOT=/usr/local/lsws
OPENLSWS_USER=nobody
OPENLSWS_GROUP=nobody
OPENLSWS_ADMIN=admin
OPENLSWS_PASSWORD=123456
OPENLSWS_EMAIL=root@localhost
OPENLSWS_ADMINSSL=yes
OPENLSWS_ADMINPORT=7080
USE_LSPHP7=yes
DEFAULT_TMP_DIR=/tmp/lshttpd
PID_FILE=/tmp/lshttpd/lshttpd.pid
OPENLSWS_EXAMPLEPORT=8088
CONFFILE=./ols.conf
    
#script start here
cd `dirname "\$0"`

if [ -f \${CONFFILE} ] ; then
    . \${CONFFILE}
fi

cd dist

mkdir -p \${SERVERROOT} >/dev/null 2>&1

ISRUNNING=no

if [ -f \${SERVERROOT}/bin/openlitespeed ] ; then 
    echo Openlitespeed web server exists, will upgrade.
    
    \${SERVERROOT}/bin/lswsctrl status | grep ERROR
    if [ \$? != 0 ]; then
        ISRUNNING=yes
    fi
fi

./_in.sh "\${SERVERROOT}" "\${OPENLSWS_USER}" "\${OPENLSWS_GROUP}" "\${OPENLSWS_ADMIN}" "\${OPENLSWS_PASSWORD}" "\${OPENLSWS_EMAIL}" "\${OPENLSWS_ADMINSSL}" "\${OPENLSWS_ADMINPORT}" "\${USE_LSPHP7}" "\${DEFAULT_TMP_DIR}" "\${PID_FILE}" "\${OPENLSWS_EXAMPLEPORT}" no

cp -f modules/*.so \${SERVERROOT}/modules/
cp -f bin/openlitespeed \${SERVERROOT}/bin/


if [ -f ../needreboot.txt ] ; then
    rm ../needreboot.txt
    echo -e "\033[38;5;203mYou must reboot the server to ensure the settings change take effect! \033[39m"
    echo
    exit 0
fi 

if [ "\${ISRUNNING}" = "yes" ] ; then
    \${SERVERROOT}/bin/lswsctrl start
fi

END

chmod 777 ./install.sh

echo -e "\033[38;5;71mBuilding finished, please run ./install.sh for installation.\033[39m"
echo -e "\033[38;5;71mYou may want to update the ols.conf to change the settings before installation.\033[39m"
echo -e "\033[38;5;71mEnjoy.\033[39m"
