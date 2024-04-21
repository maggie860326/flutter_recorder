語言異常快速篩檢 APP
===

>目錄
>[TOC]

<!-- {%hackmd WOHxcHoOT_qFht3ohClepw %} -->
<style>
    img{
        margin:auto;
        display:block;
    }
</style>



利用語音辨識模型快速篩檢語言功能異常的手機 APP

<img src="https://hackmd.io/_uploads/S1gK66p0p.gif" height="400" >



# 功能介紹

- 提取自發性語音：
    - 讓使用者回答開放性問題，並同時錄音以取得使用者之自發性語音(Spontaneous Speech)。

- 語音轉文字：
    - 使用 OpenAI 開發的 Whisper 模型將錄音轉錄為文字。

- 由後端伺服器執行 Python script：
  - 提取語言特徵：使用語言特徵分析技術提取出 15 種語言特徵分數，例如 long pause ratio、lexical density 等。
  - 語言異常的預測：利用深度學習模型進一步分析和學習語言特徵，以建立語言異常的預測模型。

- 視覺化報表：
    - 接收後端回傳的語言特徵分數，並以雷達圖呈現，以及是否異常的判斷。



# 如何重建此專案
- clone 或下載此專案
```sh
$ git clone https://github.com/maggie860326/flutter_recorder.git
```
- 將 ggml model 放到此專案的 assets/ggml 路徑底下
- 重建後端專案

## 安裝 azkadev/whisper_dart 
- [azkadev/whisper_dart](https://github.com/azkadev/whisper_dart) 是此專案使用到的語音轉文字 library，但是僅 `pub get` 此 library 並不能順利執行它。
- 你必須將 [ggerganov/whisper.cpp](https://github.com/ggerganov/whisper.cpp) 中的 `ggml.c` `ggml.h` `whisper.cpp` `whisper.h` 四個檔案複製到 `whisper_flutter-0.0.5\src\whisper.cpp` 資料夾底下 
  - 在Windows系統中的絕對路徑如下
 
    ```sh
    C:\Users\使用者名稱\AppData\Local\Pub\Cache\hosted\pub.dev\whisper_flutter-0.0.5\src\whisper.cpp
    ```
  
# 檔案說明
## 功能性檔案
### config.dart
- 用途：設定後端路由、設定題目題型和內容

### function.dart
- 用途：與後端溝通的functions
- functions:
    - `submitWav`: 傳送一個音檔給後端。
    - `submitText`: 合併指定大題中所有小題的轉錄文字，整理成json格式後傳到後端。
    - `_writeJson`: 儲存json數據在手機本地路徑。
    - `readJson`: 從手機本地路徑讀取json數據。
### model.dart
- **PathModel**：只負責處理在整個 app 中共用的數據。
- 包含：
    - userID, testDateTime, appDocPath
    - 音檔、文字檔、報告分數的儲存路徑

### view_model.dart
- **WhisperViewModel**: 集合與 Whisper 相關的所有functions
- 包含：
    - `runWhisper`: 執行錄音檔轉文字的程式，其中 `whisper.request` 會建立新的 isolate 來執行轉錄作業
    - `_saveText`: 儲存轉錄好的字串為 txt file
    - `checkTextSaved`: 確認有沒有已經存好的文字檔，如果有則將其狀態設為 textSaved
    - `ifAllDoneThenSendTextToServer`: 檢查音檔轉錄為文字的進度，如果都完成則傳送文字檔到後端


## View 檔案

### main.dart
- app 主頁面
<img src="https://hackmd.io/_uploads/B1914afWA.jpg" height="400" >

### swipe_test.dart
- 包含整個測驗流程的 PageView，每一頁會顯示一個題目或是指導語。

### user_id_page.dart
- 設定使用者id的頁面

<img src="https://hackmd.io/_uploads/SJLDE0MbA.png" height="400" >

### test_instruction_page.dart
- 測驗指導語頁面，安插在每一大題開始之前

<img src="https://hackmd.io/_uploads/SJtBXpfZ0.jpg" height="400" >
### recorder_page.dart
- 錄音的頁面，包含題目敘述、錄音按鈕、下一題按鈕。

<img src="https://hackmd.io/_uploads/rkApq2GZR.jpg" height="400" >

### test_end_page.dart
- 顯示各題錄音檔轉錄為文字的進度。
- 當全部轉錄完成時，自動將文字檔傳送到後端->請求語言特徵分數->跳轉到報告頁面

<img src="https://hackmd.io/_uploads/By7d_TMZA.jpg" height="400" >


### report_chart_page.dart
- 繪製雷達圖的頁面
<img src="https://hackmd.io/_uploads/r1Y-3pMWA.jpg" height="400" >

### report_list_page.dart
- 以列表顯示手機本地端有儲存的測驗報告

<img src="https://hackmd.io/_uploads/HJzNXCG-R.png" height="400" >


## TODO
- [ ] 將雷達圖分數標準化 (統一每個項目的scale)
- [ ] 將 normal/abnormal 視覺化 (用紅燈/綠燈表示)

## ISSUE: 一次最多只能有 8 個 isolate
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