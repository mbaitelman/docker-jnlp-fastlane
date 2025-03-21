ARG agent_version=3192.v713e3b_039fb_e-1
FROM jenkins/inbound-agent:${agent_version}-jdk21

USER root

ARG ANDROID_VERSIONS="platforms;android-30 platforms;android-31 platforms;android-32 platforms;android-33 platforms;android-34"
ARG ANDROID_BUILD_TOOLS_VERSIONS="build-tools;30.0.2 build-tools;30.0.3 build-tools;31.0.0 build-tools;34.0.0"
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
ENV ANDROID_BUILD_TOOLS_VERSION 31.0.0
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/bin

RUN mkdir "$ANDROID_HOME" .android /opt/bundle && chown jenkins /opt/bundle && \
    cd "$ANDROID_HOME" && \
    apt update && apt install -y curl unzip && curl -o sdk.zip $ANDROID_SDK_URL && \
    unzip sdk.zip && \
    rm sdk.zip 
# Download Android SDK
RUN yes | sdkmanager --licenses --sdk_root=$ANDROID_HOME && \
sdkmanager --update --sdk_root=$ANDROID_HOME && \
sdkmanager --sdk_root=$ANDROID_HOME $ANDROID_BUILD_TOOLS_VERSIONS \
    $ANDROID_VERSIONS \
    "platform-tools" \
    "extras;android;m2repository" \
    "extras;google;m2repository" 
# Install Fastlane
RUN apt-get update && \
apt-get install --no-install-recommends -y --allow-unauthenticated build-essential git ruby-full && \
gem install rake && \
gem install fastlane && \
gem install bundler 
#give .android folder permissions to jenkins 
RUN chown jenkins: /home/jenkins/.android
# Clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
apt-get autoremove -y && \
apt-get clean 

USER jenkins

RUN bundle config set --local path /opt/bundle
