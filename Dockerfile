# Use Debian 12 (Bookworm) as the base image
FROM debian:bookworm

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN { \
    set -e && \
    apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    make \
    cmake \
    rsync \
    sed \
    libclang-dev \
    ninja-build \
    gcc \
    bison \
    python3 \
    gperf \
    pkg-config \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-util-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libatspi2.0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    libssl-dev \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    libpq-dev \
    flex \
    gawk \
    texinfo \
    libisl-dev \
    zlib1g-dev \
    libtool \
    autoconf \
    automake \
    libgdbm-dev \
    libdb-dev \
    libbz2-dev \
    libreadline-dev \
    libexpat1-dev \
    liblzma-dev \
    libffi-dev \
    libsqlite3-dev \
    libbsd-dev \
    perl \
    patch \
    m4 \
    libncurses5-dev \
    gettext  \
    gcc-12-aarch64-linux-gnu \
    g++-12-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    libc6-arm64-cross \
    libc6-dev-arm64-cross \
    glibc-source \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-0 \
    libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-tools \
    gstreamer1.0-pipewire \
    gstreamer1.0-qt6 \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-libcamera \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-libav \
    gstreamer1.0-vaapi \
    zlib1g \
    zlib1g-dev; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
} 2>&1 | tee -a /build.log

# Set the working directory to /build
WORKDIR /build

# Create sysroot directory
RUN mkdir sysroot sysroot/usr sysroot/opt

# Copy base Raspberry Pi sysroot tarball (if available)
COPY sysroot-base.tar.gz /build/sysroot-base.tar.gz
RUN tar xvfz /build/sysroot-base.tar.gz -C /build/sysroot

# Copy extended Raspberry Pi sysroot tarball (if available)
# This is useful for adding binaries produced with this image to the sysroot
COPY sysroot-ext.tar.gz /build/sysroot-ext.tar.gz
RUN tar xvfz /build/sysroot-ext.tar.gz -C /build/sysroot

# Copy the toolchain file
COPY toolchain.cmake /build/

# Build and install CMake from source
RUN { \
    echo "Building CMake from source" && \
    mkdir cmakeBuild && cd cmakeBuild && \
    git clone https://github.com/Kitware/CMake.git && \
    cd CMake && \
    ./bootstrap && make -j$(nproc) && make install && \
    echo "CMake build completed"; \
} 2>&1 | tee -a /build.log

RUN { \
    set -e && \
    echo "Fix symbollic link" && \
    wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py && \
    chmod +x sysroot-relativelinks.py && \
    python3 sysroot-relativelinks.py /build/sysroot && \
    mkdir -p qt6 qt6/host qt6/pi qt6/host-build qt6/pi-build qt6/src && \
    cd qt6/src && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtbase-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qt5compat-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtmultimedia-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtwebsockets-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtvirtualkeyboard-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtgraphs-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtcharts-everywhere-src-6.8.1.tar.xz && \
    wget https://download.qt.io/official_releases/qt/6.8/6.8.1/submodules/qtimageformats-everywhere-src-6.8.1.tar.xz && \
    cd ../host-build && \
    tar xf ../src/qtbase-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qt5compat-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtmultimedia-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtwebsockets-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtvirtualkeyboard-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtgraphs-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtcharts-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtimageformats-everywhere-src-6.8.1.tar.xz && \
    echo "Compile qtbase for host" && \
    cd qtbase-everywhere-src-6.8.1 && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/build/qt6/host && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile shader for host" && \
    cd ../qtshadertools-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile declerative for host" && \
    cd ../qtdeclarative-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile Qt5Compat for host" && \
    cd ../qt5compat-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile multimedia for host" && \
    cd ../qtmultimedia-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile websockets for host" && \
    cd ../qtwebsockets-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile virtual keyboard for host" && \
    cd ../qtvirtualkeyboard-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile graphs for host" && \
    cd ../qtgraphs-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile charts for host" && \
    cd ../qtcharts-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile image formats for host" && \
    cd ../qtimageformats-everywhere-src-6.8.1 && \
    /build/qt6/host/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    cd ../../pi-build && \
    tar xf ../src/qtbase-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qt5compat-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtmultimedia-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtwebsockets-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtvirtualkeyboard-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtgraphs-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtcharts-everywhere-src-6.8.1.tar.xz && \
    tar xf ../src/qtimageformats-everywhere-src-6.8.1.tar.xz && \
    echo "Compile qtbase for rasp" && \
    cd qtbase-everywhere-src-6.8.1 && \
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DINPUT_opengl=es2 \
        -DQT_BUILD_EXAMPLES=OFF -DQT_BUILD_TESTS=OFF \
        -DQT_HOST_PATH=/build/qt6/host \
        -DCMAKE_STAGING_PREFIX=/build/qt6/pi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_FEATURE_xcb=ON -DFEATURE_xcb_xlib=ON \
        -DFEATURE_sql_psql=ON \
        -DQT_FEATURE_xlib=ON && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile shader for rasp" && \
    cd ../qtshadertools-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile declerative for rasp" && \
    cd ../qtdeclarative-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile Qt5Compat for rasp" && \
    cd ../qt5compat-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile QtMultimedia for rasp" && \
    cd ../qtmultimedia-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile websockets for rasp" && \
    cd ../qtwebsockets-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile virtual keyboard for rasp" && \
    cd ../qtvirtualkeyboard-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile graphs for rasp" && \
    cd ../qtgraphs-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile charts for rasp" && \
    cd ../qtcharts-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compile image formats for rasp" && \
    cd ../qtimageformats-everywhere-src-6.8.1 && \
    /build/qt6/pi/bin/qt-configure-module . && \
    cmake --build . --parallel 4 && \
    cmake --install . && \
    echo "Compilation is finished"; \
} 2>&1 | tee -a /build.log

RUN tar -czvf qt-host-binaries.tar.gz -C /build/qt6/host .
RUN tar -czvf qt-pi-binaries.tar.gz -C /build/qt6/pi .

# Cleanup tarballs
RUN rm ../src/qtbase-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtshadertools-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtdeclarative-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qt5compat-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtmultimedia-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtwebsockets-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtvirtualkeyboard-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtgraphs-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtcharts-everywhere-src-6.8.1.tar.xz && \
    rm ../src/qtimageformats-everywhere-src-6.8.1.tar.xz && \
