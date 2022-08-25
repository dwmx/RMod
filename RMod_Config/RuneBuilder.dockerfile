FROM amd64/ubuntu:latest AS tmp

# -------------------------------------------
# Install dependencies
# -------------------------------------------
RUN apt update
RUN apt install -y wget
RUN apt install -y p7zip-full
RUN apt install -y git
RUN apt install -yqq ssh

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
# Run
# -------------------------------------------
CMD [ "bash", "-c", \
"\
git clone $REPOSITORY /RuneBase/Repository && \
export RUNE_PATH=/RuneBase/Rune && \
export REPOSITORY_PATH=/RuneBase/Repository && \
/RuneBase/Repository/$BUILDSCRIPT \
"\
]
