FROM ubuntu:22.04

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TOOLS_PATH=/opt/gcc-arm-none-eabi
ARG ARM_VERSION=14.2.rel1
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata
ARG SSH_PRIVATE_KEY

RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM" > /log

# Prep basic packages to build STM32 CMake project
RUN apt-get update && apt-get install -y \
	build-essential \
	cmake ninja-build \
	git gnupg2 \
	stlink-tools \
	xz-utils curl \
        sudo \
        usbutils \
        pkg-config \
        libusb-* \
        make \
        automake \
        autoconf \
        texinfo \
  tzdata \
    ninja-build \
    ca-certificates \
    udev

#ARG SSH_PRIVATE_KEY
#  RUN mkdir ~/.ssh/ \
#  && echo “${SSH_PRIVATE_KEY}” > ~/.ssh/id_dsa \
#  && chmod 600 ~/.ssh/id_dsa \
#  && ssh-keyscan github.com >> ~/.ssh/known_hosts 

# Get ARM Toolchain
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then export ARM_ARCH=x86_64; \
	else export ARM_ARCH=aarch64; \
	fi \
	&& echo "Downloading ARM GNU GCC for Platform: $ARM_ARCH" \
	&& mkdir ${TOOLS_PATH} \
	&& curl -Lo gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VERSION}/binrel/arm-gnu-toolchain-${ARM_VERSION}-${ARM_ARCH}-arm-none-eabi.tar.xz" \
	&& tar xf gcc-arm-none-eabi.tar.xz --strip-components=1 -C ${TOOLS_PATH} \
	&& rm gcc-arm-none-eabi.tar.xz \
	&& rm ${TOOLS_PATH}/*.txt \
	&& rm -rf ${TOOLS_PATH}/share/doc \
	&& echo "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VERSION}/binrel/arm-gnu-toolchain-${ARM_VERSION}-${ARM_ARCH}-arm-none-eabi.tar.xz"




#RUN LOCAL_USER_NAME=$(whoami)
#RUN useradd -ms /bin/bash $LOCAL_USER_NAME \
#    && echo "$LOCAL_USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
#    && usermod -aG pkgdev $LOCAL_USER_NAME

# Add Toolchain to PATH
ENV PATH="$PATH:${TOOLS_PATH}/bin"

# Add Entrypoint script
ADD build.sh /usr/local/bin/build.sh
ENTRYPOINT ["/usr/local/bin/build.sh"]
