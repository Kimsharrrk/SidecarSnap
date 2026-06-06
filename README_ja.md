


<div align="center">

<img src="Assets/app_icon_1024.png" width="128" height="128" alt="SidecarSnap Icon">

# SidecarSnap

**マウスが画面の端に触れると → iPad Sidecarがそちら側に自動配置されます。**
> *Appleが作ってくれないので、もどかしくて自分で作りました。*

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

[🇺🇸 English](README.md) | [🇰🇷 한국어](README_ko.md) | **🇯🇵 日本語**

<!-- DRAG_AND_DROP_YOUR_DEMO_VIDEO_OR_GIF_HERE -->
https://github.com/user-attachments/assets/7e65be61-8682-46ef-acb9-65baf9be9b38

</div>

---

## 🇯🇵 日本語版

### 🤷‍♂️ 問題点

iPadをSidecarでサブディスプレイとして使いながら、iPadをMacBookの反対側に移したとき、毎回 **システム設定 → ディスプレイ → 配置** を開いて小さなアイコンをドラッグしていませんか？

もうそんな面倒な作業は終わりにしましょう。

### 💡 解決策

SidecarSnapはマウスカーソルを追跡します。マウスを画面の**左端または右端**に0.5秒間押し当てると、Sidecarのディスプレイが**自動でそちら側に配置されます。**

```
マウス → 左端 (0.5秒) = iPadが左側へ  ◀
マウス → 右端 (0.5秒) = iPadが右側へ ▶
```

画面の端には**Dynamic Island風の黒いしずく(Blob)**が現れ、タイマーの進行を視覚的に滑らかに表示します。

### ✨ 主な機能

| 機能 | 説明 |
|---|---|
| 🖱️ 自動配置 | マウスの端検出 → Sidecarの即時再配置 |
| 💧 しずくアニメーション | ベゼルから現れる滑らかな視覚的タイマー |
| 🌐 多言語対応 | English、한국어、日本語 — アプリ内で切り替え可能 |
| 👻 アイコン非表示 | ワンクリックでメニューバーアイコンを非表示に！ |
| 🚀 ログイン時起動 | Mac起動時に自動的に実行されます |
| ⚙️ 待機時間の調整 | 0.3秒 / 0.5秒 (デフォルト) / 1.0秒から選択 |

### 📥 インストール方法

**インストール手順 (推奨)**

<a href="https://github.com/Kimsharrrk/SidecarSnap/raw/main/SidecarSnap_v1.1.dmg">
  <img src="Assets/download_badge.png" width="220" alt="macOS向けアプリをダウンロード">
</a>

1. DMGファイルを開き、可愛いクレヨン背景を楽しみながらアプリアイコンを `Applications` フォルダにドラッグします！
3. アプリを起動し、初期設定ガイドに従ってください。

> [!IMPORTANT]
> **初回起動時のセキュリティ警告の解決方法**
> 本アプリは無料のオープンソースプロジェクトであり、有料のApple開発者アカウント（$99/年）で署名されていないため、初回起動時に **「"SidecarSnap"は壊れているため開けません。」** という警告が表示されます。
> 
> **実際にはアプリは壊れていませんのでご安心ください！** ターミナルコマンドを使わずに、10秒で解決する方法は以下の通りです：
> 1. 警告ポップアップで **「キャンセル」** をクリックします。
> 2. Macの **システム設定 ➔ プライバシーとセキュリティ** を開きます。
> 3. 画面を下にスクロールして **「セキュリティ」** セクションを探します。
> 4. ブロックされた「SidecarSnap」の横にある **「このまま開く」** ボタンをクリックします。
> 5. MacのパスワードまたはTouch IDを入力するとすぐに実行され、次回からは警告なしで起動するようになります。

### ⚙️ 初期設定 (30秒で完了)

> **Step 1** — iPadをSidecarで接続します (コントロールセンター → 画面ミラーリング → iPadを選択)
>
> **Step 2** — ポップアップに従って、アクセシビリティの許可を与えてください *(マウスの追跡に必須です)*
>
> **Step 3** — これで完了です！マウスを画面の端へスッと移動させてみてください。

---

### 🙈 メニューバーアイコンを非表示にする

SidecarSnapはメニューバーに小さなアイコンとして常駐します。

**非表示にする方法:**
メニューバーのアイコンをクリックし、**「Hide Menu Bar Icon(メニューバーアイコンを非表示)」**を選択してください。

> *正直に言うと、非表示にすることをおすすめします。  
> アイコンがちょっと不細工なので... 私たちはデザイナーではなく開発者なのです。ごめんなさい。🤷*

*注: アイコンを非表示にした後で設定を変更したくなった場合は、アプリケーションフォルダからSidecarSnapアプリを再度起動するだけでアイコンが復活します！*

---

### 💻 動作環境

- macOS 13 (Ventura) 以降
- SidecarをサポートするiPad (iPad Pro, iPad Air, iPad mini 5+, iPad 6th gen+)
- 両方のデバイスが同じApple IDでサインインしていること

### ⚙️ 動作の仕組み

このアプリはカーネル拡張などは使用せず、**Appleの公開CoreGraphics APIのみ**を使用して安全に構築されています。

---

## ライセンス (License)

Copyright © 2026 Kimsharrrk. All rights reserved.  
個人利用に限り無料で使用できます。無断でのソースコードの修正および再配布は厳しく禁止されています。

---

<div align="center">

システム設定を毎回開くのに疲れたMacBook + iPadユーザーによって作られました。

**もしこれがあなたの時間を節約したなら → ⭐ Starをお願いします！とても励みになります。**

</div>
