ARG agent_version=4.10-3
FROM jenkins/inbound-agent:${agent_version}-jdk11

USER root

ARG ANDROID_VERSIONS= "platforms;android-30" "platforms;android-31" 
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
ENV ANDROID_BUILD_TOOLS_VERSION 31.0.0
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/bin

RUN mkdir "$ANDROID_HOME" .android && \
    cd "$ANDROID_HOME" && \
    apt update && apt install curl unzip && curl -o sdk.zip $ANDROID_SDK_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
# Download Android SDK
yes | sdkmanager --licenses --sdk_root=$ANDROID_HOME && \
sdkmanager --update --sdk_root=$ANDROID_HOME && \
sdkmanager --sdk_root=$ANDROID_HOME "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    $ANDROID_VERSIONS \
    "platform-tools" \
    "extras;android;m2repository" \
    "extras;google;m2repository" && \
# Install Fastlane
apt-get update && \
apt-get install --no-install-recommends -y --allow-unauthenticated build-essential git ruby-full && \
gem install rake && \
gem install fastlane && \
gem install bundler && \
# Clean up
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
apt-get autoremove -y && \
apt-get clean

USER jenkins
