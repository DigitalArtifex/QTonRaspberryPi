FROM qtcrossbuild-env:latest

# Set up project directory
RUN mkdir /build/project
COPY project /build/project

# Build the project using Qt for Raspberry Pi
RUN { \
    cd /build/project && \
    /build/qt6/pi/bin/qt-cmake . && \
    cmake --build .; \
} 2>&1 | tee -a /build.log
