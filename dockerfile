# From Lena with <3
# To build:
# docker build . -t rune
# To run:
# docker run --platform linux/386 --rm rune
FROM amd64/ubuntu:latest AS tmp

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update 

RUN apt-get install -y p7zip-full \
    p7zip-rar \
    bchunk \
    cdrdao \
    libxext-dev:i386 \
    libc6-i386 \
    wget \
    rsync

RUN mkdir /rune
WORKDIR /rune

# ------------------
# Download artifacts
# ------------------
RUN wget https://archive.org/download/Rune_Halls_of_Valhalla_Linux/%5BLinux%5D%20Rune.iso -O rune.iso && \
    wget https://archive.org/download/Rune_Halls_of_Valhalla_Linux/rune_native_hon_1.08_patch.7z -O hon.7z && \
    wget https://icculus.org/~ravage/rune/rune-107-fix.tar.bz2 -O rune107_fix.tar.bz2 && \
    wget https://archive.org/download/Rune_Halls_of_Valhalla_Linux/rhov.tar -O rhov.tar

# ------------------------
# Installation (base game)
# ------------------------
RUN mkdir ~/rune && \
    mkdir rune_base && \
    mv rune.iso rune_base && \
    cd rune_base && \
    7z x rune.iso && \
    tar xf data.tar.gz && \
    mkdir -p ~/rune/Help ~/rune/Maps ~/rune/Meshes ~/rune/Sounds ~/rune/System ~/rune/Textures ~/rune/Web/images && \
    rsync Help/* ~/rune/Help && \ 
    rsync Maps/*.run ~/rune/Maps && \
    rsync Meshes/*.ums ~/rune/Meshes && \
    rsync Sounds/*.uax ~/rune/Sounds && \
    rsync Textures/*.utx ~/rune/Textures && \
    rsync Web/*.uhtm ~/rune/Web && \
    rsync Web/images/* ~/rune/Web/images && \
    rsync License.txt ~/rune/LICENSE && \
    rsync CREDITS Legal.txt License.txt README icon.bmp icon.xpm ~/rune && \
    rsync System/* ~/rune/System && \
    rsync bin/x86/rune ~/rune

# -----------------------
# Installation (1.07 fix)
# -----------------------
RUN mkdir 107_fix && \
    mv rune107_fix.tar.bz2 107_fix && \
    cd 107_fix && \
    7z x rune107_fix.tar.bz2 && \
    tar -xvf rune107_fix.tar && \
    rsync RMenu.* ~/rune/System

# ------------------
# Installation (HoV)
# ------------------
# Note that we "delete" (head command) the audio tracks from cd to make the conversion to cue work.
RUN mkdir hov && \
    mv rhov.tar hov && \
    cd hov && \
    tar -xvf rhov.tar && \
    head -n 7 Rune-HOV.toc > tmp && \
    mv tmp Rune-HOV.toc && \
    toc2cue Rune-HOV.toc Rune-HOV.cue && \
    bchunk Rune-HOV.toc.bin Rune-HOV.cue out && \
    7z x out01.iso && \
    tar xf data-HOV.tar.gz && \
    rsync Maps/*.run ~/rune/Maps && \
    rsync Sounds/*.uax ~/rune/Sounds && \
    rsync System/*.int System/*.u ~/rune/System && \
    rsync Textures/*.utx ~/rune/Textures && \
    rsync README-HOV ~/rune

# ----------
# 1.08 patch
# ----------
RUN mkdir 108 && \
    mv hon.7z 108 && \
    cd 108 && \
    7z x hon.7z && \
    cd rune_native_hon_1.08_patch && \
    rsync System/*.u System/*.int ~/rune/System && \
    rsync Meshes/*.ums ~/rune/Meshes && \
    rsync Maps/*.run ~/rune/Maps && \
    rsync Textures/*.utx ~/rune/Textures && \
    rsync Web/*.uhtm ~/rune/Web && \
    rsync Web/images/* ~/rune/Web/images && \
    chmod -R 644 ~/rune && \
    chmod 755 ~/rune/rune ~/rune/System/rune-bin ~/rune/System/ucc-bin && \
    cd ~/rune/System && \
    rm Core.so && \
    ln -s Core.so.dynamic Core.so && \
    rm ucc && \
    ln -s ucc-bin ucc 
 
# -----------------------
# Apply master server fix
# -----------------------
# The ./rune command here is supposed to crash. It still generates necessary config files in ~/.loki
RUN cd ~/rune && \
    linux32 ./rune 2> /dev/null || true && \
    cd ~/.loki/rune/System && \
    sed -i 's/master.gamespy.com/master.333networks.com/g' Rune.ini && \
    sed -i 's/master0.gamespy.com/master.333networks.com/g' Rune.ini

FROM i386/ubuntu:latest

RUN apt-get update && \
    apt-get install -y xorg

COPY --from=tmp /root/rune /root/rune
COPY --from=tmp /root/.loki /root/.loki

EXPOSE 5580/tcp 7777/udp 7778/udp 7779/udp 7780/udp 7781/udp 8777/udp 27900/tcp 27900/udp
CMD [ "bash", "-c", "cd /root/rune/System/ && ./ucc-bin server DM-Hildir" ]
