#!/bin/bash
set -e
SDK=/opt/android-sdk
BT=$SDK/build-tools/34.0.0
AJ=$SDK/platforms/android-34/android.jar
cd "$(dirname "$0")"
rm -rf build && mkdir -p build/classes build/gen build/dex

echo "[1/6] 编译资源"
$BT/aapt2 compile --dir res -o build/res.zip

echo "[2/6] 链接资源"
$BT/aapt2 link -o build/base.apk \
  -I "$AJ" \
  --manifest AndroidManifest.xml \
  --java build/gen \
  --min-sdk-version 24 --target-sdk-version 34 \
  build/res.zip

echo "[3/6] 编译 Java"
javac -nowarn -source 8 -target 8 -encoding UTF-8 \
  -classpath "$AJ" -d build/classes \
  $(find src -name '*.java') $(find build/gen -name 'R.java') 2>&1 | grep -v "bootstrap class path" || true

echo "[4/6] 转 dex"
$BT/d8 --lib "$AJ" --min-api 24 --output build/dex $(find build/classes -name '*.class')

echo "[5/6] 打包"
cp build/base.apk build/unsigned.apk
python3 - <<'PY'
import zipfile, os
src = 'build/unsigned.apk'
dst = 'build/unsigned_full.apk'
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        zout.writestr(item, zin.read(item.filename))
    zout.write('build/dex/classes.dex', 'classes.dex')
    for root, dirs, files in os.walk('assets'):
        for f in files:
            p = os.path.join(root, f)
            zout.write(p, p.replace(os.sep, '/'))
print('packed')
PY

echo "[6/6] 对齐与签名"
$BT/zipalign -f -p 4 build/unsigned_full.apk build/aligned.apk
if [ ! -f keystore.jks ]; then
  keytool -genkeypair -v -keystore keystore.jks -keyalg RSA -keysize 2048 \
    -validity 10000 -alias sandverse -storepass sandverse -keypass sandverse \
    -dname "CN=Sandverse, OU=Studio, O=Sandverse, L=Shenzhen, S=Guangdong, C=CN" >/dev/null 2>&1
  echo "  keystore 已生成"
fi
$BT/apksigner sign --ks keystore.jks --ks-pass pass:sandverse --key-pass pass:sandverse \
  --v1-signing-enabled true --v2-signing-enabled true \
  --out yisha-v1.0.0.apk build/aligned.apk

$BT/apksigner verify --print-certs yisha-v1.0.0.apk | head -5
ls -lh yisha-v1.0.0.apk
echo "构建完成"
