FROM amd64/ubuntu:latest AS tmp

# -------------------------------------------
# Install dependencies
# -------------------------------------------
RUN apt update
RUN apt install -y wget
RUN apt install -y p7zip-full
RUN apt install -y git

# -------------------------------------------
# Install Wine
# -------------------------------------------
RUN dpkg --add-architecture i386 && apt update
RUN apt install -y wine wine32 wine64 libwine libwine:i386 fonts-wine

# -------------------------------------------
# Download Rune
# -------------------------------------------
RUN mkdir /RuneBase/
RUN mkdir /RuneBase/RuneArtifacts/
RUN wget https://s3.us-east-2.wasabisys.com/rune/Rune106.min.7z -O /RuneBase/RuneArtifacts/Rune106.min.7z

# -------------------------------------------
# Install Rune
# -------------------------------------------
RUN mkdir /RuneBase/Rune/
RUN cd ~
RUN 7z x /RuneBase/RuneArtifacts/Rune106.min.7z -o/RuneBase/Rune/

# -------------------------------------------
# Clone RMod and run the build setup script
# -------------------------------------------
RUN git clone https://github.com/dwmx/rmod /RuneBase/RMod/
RUN /RuneBase/RMod/RMod_Config/RModBuildSetup.sh /RuneBase/RMod/ /RuneBase/Rune/

# -------------------------------------------
# Build RMod packages
# -------------------------------------------
RUN wine /RuneBase/Rune/Rune106/System/UCC.exe make -ini=/RuneBase/RMod/RMod_Config/RModBuild.ini

# -------------------------------------------
# Build
# -------------------------------------------
CMD [ "bash", "-c", "cd /RuneBase/ && ls -la && cd /RuneBase/RuneArtifacts/ && ls -la && cd /RuneBase/Rune/Rune106/System/ && ls -la" ]