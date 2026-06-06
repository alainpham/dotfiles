
echo downloading https://install.speedtest.net/app/cli/ookla-speedtest-$SPEEDTEST_VERSION-linux-x86_64.tgz
curl -L -o /tmp/sptest/speedtest.tgz https://install.speedtest.net/app/cli/ookla-speedtest-$SPEEDTEST_VERSION-linux-x86_64.tgz
tar -xzf /tmp/sptest/speedtest.tgz -C /tmp/sptest
cp /tmp/sptest/speedtest /usr/local/bin/speedtest
chmod 755 /usr/local/bin/speedtest
rm -f /tmp/sptest.tgz