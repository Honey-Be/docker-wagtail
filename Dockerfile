FROM honeybe/alpine-pypy:latest

RUN echo "ipv6" >> /etc/modules

ENV CC=clang
ENV CXX=clang++

# Add Edge and bleeding repos
RUN echo -e '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories


# Install permanent system depdencies
RUN apk add --update --no-cache \
    libpng \
    libjpeg \
    bash \
    yaml \
    gettext \
    gsl \
    jasper \
    jasper-libs \
    tiff \
    libwebp \
    libavc1394 \
    libdc1394 \
    imagemagick \
    libpq \
    libtbb@testing \
    zlib \
    ffmpeg \
    ffmpeg-libs \
    openexr \
    openexr-tools \
    clang-dev \ 
    ffmpeg-dev \
    openexr-dev

# Define some versions
ENV OPENCV_VERSION 3.2.0
ENV WAGTAIL_VERSION 1.9
ENV DJANGO_VERSION 1.10.0

# Define compilers
ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

# Alpine store some headers into /lib/
ENV LIBRARY_PATH=/lib:/usr/lib

# Compile and install OpenCV for Python 3 and wagtail
# Temporary install build dependencies
RUN apk add --no-cache --virtual .build-deps  \
        python3-dev \
        jasper-dev \
        curl \
        cmake \
        pkgconf \
        unzip \
        build-base \
        libavc1394-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libdc1394-dev \
        tiff-dev \
        libwebp-dev \
        imagemagick-dev \
        zlib-dev \
        postgresql-dev \
        libtbb@testing \
        libtbb-dev@testing \
        linux-headers \
    # Fix numpy compilation
    && ln -s /usr/include/locale.h /usr/include/xlocale.h \
    # Enable some numpy optimization
    && pip3 install cython \
    && pip3 install numpy \
    # Build OpenCV
    && mkdir /opt && cd /opt \
    && curl -OsSL https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
    && unzip ${OPENCV_VERSION}.zip \
    && cd /opt/opencv-${OPENCV_VERSION} \
    && mkdir build && cd build \
    && cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        # Gain some space and time by disabling some features
        -D INSTALL_C_EXAMPLES=OFF \
    	-D INSTALL_PYTHON_EXAMPLES=OFF \
    	-D BUILD_EXAMPLES=OFF \
        -D WITH_FFMPEG=YES \
        -D WITH_IPP=NO \
        -D WITH_OPENEXR=YES \
        .. \
    && VERBOSE=1 make && make install \
    && cd && rm -fr /opt \
    # Install Wagtail and some depdencies
    && pip3 install django==$DJANGO_VERSION wagtail==$WAGTAIL_VERSION django-redis psycopg2 wand \
    # Cleanup
    && apk del .build-deps && rm -r /root/.cache
