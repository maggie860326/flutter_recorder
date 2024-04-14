# 語言異常快速篩檢 APP
利用語音辨識模型快速篩檢語言功能異常的手機 APP

<img src="https://hackmd.io/_uploads/S1gK66p0p.gif" height="400" >



## 功能介紹

- 提取自發性語音：讓使用者回答開放性問題，並同時錄音以取得使用者之自發性語音(Spontaneous Speech)。

- 語音轉文字：使用 OpenAI 開發的 Whisper 模型將錄音轉錄為文字。

- 由後端伺服器執行並回傳：
  - 提取語言特徵：使用語言特徵分析技術提取出 15 種語言特徵數據，例如 long pause ratio、lexical density 等。
  - 語言異常的預測：利用深度學習模型進一步分析和學習語言特徵，以建立語言異常的預測模型。

- 視覺化報表：以雷達圖呈現使用者各項語言特徵之分數，以及是否異常的判斷。



## 如何重建此專案
- clone 或下載此專案
```sh
$ git clone https://github.com/maggie860326/flutter_recorder.git
```
- 將 ggml model 放到此專案的 assets/ggml 路徑底下
- 重建後端專案

### 安裝 azkadev/whisper_dart 
- [azkadev/whisper_dart](https://github.com/azkadev/whisper_dart) 是此專案使用到的語音轉文字 library，但是僅 `pub get` 此 library 並不能順利執行它。
- 你必須將 [ggerganov/whisper.cpp](https://github.com/ggerganov/whisper.cpp) 中的 `ggml.c` `ggml.h` `whisper.cpp` `whisper.h` 四個檔案複製到 `whisper_flutter-0.0.5\src\whisper.cpp` 資料夾底下 
  - 在Windows系統中的絕對路徑如下
 
    ```sh
    C:\Users\使用者名稱\AppData\Local\Pub\Cache\hosted\pub.dev\whisper_flutter-0.0.5\src\whisper.cpp
    ```
  

## TODO
- 將雷達圖分數標準化 (統一每個項目的scale)
- 將 normal/abnormal 視覺化 (用紅燈/綠燈表示)
- **ISSUE**: 一次最多只能有 8 個 isolate
  -  當做到第9題時，因為isolate數量超過上限，整個 app freeze。
  -  此問題導致目前題目數量不能超過8題。
  -  預期解法：
     1. 提升isolate數量上限。
     2. 當已經存在8個isolate的時候，後續task必須排隊等候。

  

## 開發團隊
國立成功大學 敏求智慧運算學院
- 計畫負責人：Dr. Ya-Ning Chang, 
- APP 開發：Maggie Chan
- 後端開發：Chih-Hung Chen