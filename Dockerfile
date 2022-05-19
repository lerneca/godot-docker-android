FROM lerneca/godot:v1.0.1

ENV GODOT_VERSION "3.4.4"
ENV CLI_TOOLS_VERSION "7583922_latest"

RUN mkdir -p /opt/staging/build-templates
RUN mkdir -p /opt/staging/android-sdk

WORKDIR /opt/staging/build-templates

RUN wget --quiet https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz
RUN unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz
RUN pwd
RUN ls -l

WORKDIR /opt/staging/android-sdk

RUN wget --quiet https://dl.google.com/android/repository/commandlinetools-linux-${CLI_TOOLS_VERSION}.zip
RUN unzip commandlinetools-linux-${CLI_TOOLS_VERSION}.zip -d cmdline-tools

FROM lerneca/godot:v1.0.0

ENV GODOT_VERSION "3.4.4"

RUN apk update && apk add --no-cache openjdk11 bash

RUN mkdir -p /root/.cache
RUN mkdir -p /root/.android
RUN mkdir -p /root/.config/godot
RUN mkdir -p /root/.local/share/godot/templates/${GODOT_VERSION}.stable
RUN mkdir -p /usr/lib/android-sdk
RUN mkdir -p /root/godot

COPY --from=0 /opt/staging/build-templates/templates/android_debug.apk /root/.local/share/godot/templates/${GODOT_VERSION}.stable/android_debug.apk
COPY --from=0 /opt/staging/build-templates/templates/android_release.apk /root/.local/share/godot/templates/${GODOT_VERSION}.stable/android_release.apk
COPY --from=0 /opt/staging/build-templates/templates/android_source.zip /root/.local/share/godot/templates/${GODOT_VERSION}.stable/android_source.zip
COPY --from=0 /opt/staging/android-sdk/cmdline-tools /usr/lib/android-sdk

ENV ANDROID_HOME "/usr/lib/android-sdk"
ENV PATH "${ANDROID_HOME}/cmdline-tools/bin:${PATH}"

RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404"

WORKDIR /root/.android/
RUN keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999

RUN godot -e -q
RUN echo 'export/android/android_sdk_path = "/usr/lib/android-sdk"' >> /root/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore = "/root/.android/debug.keystore"' >> /root/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore_user = "androiddebugkey"' >> /root/.config/godot/editor_settings-3.tres
RUN echo 'export/android/debug_keystore_pass = "android"' >> /root/.config/godot/editor_settings-3.tres
RUN echo 'export/android/force_system_user = false' >> /root/.config/godot/editor_settings-3.tres
RUN echo 'export/android/timestamping_authority_url = ""' >> /root/.config/godot/editor_settings-3.tres
RUN echo 'export/android/shutdown_adb_on_exit = true' >> /root/.config/godot/editor_settings-3.tres

WORKDIR /root/godot
