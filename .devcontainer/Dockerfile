# ---------- ビルド引数 ----------
ARG IMAGE_NAME=ubuntu:24.04
ARG ROS_DISTRO_NAME=jazzy
ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY

# ---------- ベースイメージ ----------
FROM ${IMAGE_NAME} AS base

# 再度 ARG を宣言（ステージごとに必要）
ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY

# 環境変数としても設定
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}

ENV TZ=Asia/Tokyo
ENV DEBIAN_FRONTEND=noninteractive

# タイムゾーン設定
RUN echo "${TZ}" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# APT proxy 設定（APT のための個別設定）
RUN echo "Acquire::http::Proxy \"${http_proxy}\";" > /etc/apt/apt.conf.d/99proxy && \
    echo "Acquire::https::Proxy \"${https_proxy}\";" >> /etc/apt/apt.conf.d/99proxy

# ロケール・共通ツールのインストール
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends locales && \
    locale-gen ja_JP.UTF-8 && \
    update-locale LC_ALL=ja_JP.UTF-8 LANG=en_US.UTF-8

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONIOENCODING=utf-8

RUN apt-get update && apt-get install -y \
    software-properties-common \
    gnupg \
    x11-apps \
    gnuplot \
    build-essential \
    git \
    curl \
    pkg-config \
    wget \
    zip \
    unzip \
    tzdata \
    lsb-release \
    ca-certificates \
    iputils-ping \
    net-tools \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# ---------- ROS2 ステージ ----------
FROM base AS ros2

# 再定義
ARG ROS_DISTRO_NAME
ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}


# ROS2 GPG キーとリポジトリの追加
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list


# ROS2 インストール
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO_NAME}-desktop \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    python3-argcomplete && \
    rm -rf /var/lib/apt/lists/*

# rosdep 初期化（プロキシが空なら解除してから）
RUN if [ -z "$http_proxy" ] && [ -z "$https_proxy" ]; then \
      unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY; \
    fi && \
    . /opt/ros/${ROS_DISTRO_NAME}/setup.sh && \
    rosdep init && \
    rosdep update

# ROS2 環境変数の設定
# ROS2環境構築後のステージで
RUN echo "source /opt/ros/${ROS_DISTRO_NAME}/setup.bash" >> /root/.bashrc


# ros2ユーザーで作業を続ける場合
USER root
WORKDIR /root


