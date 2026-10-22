# 一沙

写一句话，它长成一片陆地。

一沙是一个离线的世界引擎：任意一句话作为种子，确定性地生成一片可以走进去的陆地——海岸、沙滩、草甸、林线、岩脊、雪冠，以及散落其间的遗迹与一段自带的编年史。

同样的种子永远长出同样的陆地；换一句话，就是另一个世界。

## 下载

最新安装包见 [Releases](https://github.com/zachshi-ai/yisha/releases/latest)。

- 包名 `com.sandverse.app`，minSdk 24（Android 7.0+）
- 不申请网络权限，全部运算在本机完成
- 世界存档写在本机，卸载即清空

## 玩法

- 拖动屏幕行走（也可用方向键 / WASD）
- 轻点地图查看地形
- 靠近地标会记入「见闻录」
- 底部「俯瞰 / 近观」切换视角，「新世界」换种子或读回保存过的世界

## 结构

```
assets/index.html        世界引擎（地形生成、点阵渲染、编年史、交互）
src/.../MainActivity.java   WebView 外壳 + 存档持久化
build.sh                 aapt2 → javac → d8 → zipalign → apksigner 的构建脚本
```
