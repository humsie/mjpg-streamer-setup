# Update apt-get

sudo apt-get update

# install dependencies

sudo apt-get install -y git ffmpeg libjpeg8-dev imagemagick libv4l-dev v4l-utils make gcc git cmake g++

#

git clone https://github.com/jacksonliam/mjpg-streamer.git

cd mjpg-streamer/mjpg-streamer-experimental
cmake -G "Unix Makefiles"
make
sudo make install

sudo mkdir -p /usr/share/mjpg_streamer
sudo cp -r www /usr/share/mjpg_streamer
sudo cp -r plugins /usr/share/mjpg_streamer
sudo chown -R octoprint: /usr/share/mjpg_streamer


SERVICE=/lib/systemd/system/mjpg_streamer@.service
DEFAULTSFILE=/etc/default/mjpg_streamer-default

OUT=$(cat <<EOF | sudo tee $SERVICE
[Unit]
Description=A Linux-UVC streaming application with Pan/Tilt
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=-/etc/default/mjpg_streamer-default
EnvironmentFile=-/etc/default/mjpg_streamer-%i
Type=simple
User=octoprint
ExecStart=/usr/local/bin/mjpg_streamer -o "${MJPG_OUTPUT}" -i "${MJPG_INPUT}"

[Install]
WantedBy=multi-user.target
EOF
)

sudo systemctl daemon-reload


OUT=$(cat <<EOF | sudo tee $DEFAULTSFILE
LD_LIBRARY_PATH=/usr/share/mjpg_streamer
MJPG_OUTPUT="output_http.so -w /usr/share/mjpg_streamer/www -p 8080"
MJPG_INPUT="input_uvc.so -r 1920x1080"

EOF
)
