# Google 評論爬蟲 (Google Comments Crawler)

<br>此程式碼抓取使用者所輸入之關鍵字，並根據目前使用者位置去選擇最接近之搜尋結果，進行該店家評論爬取</br>
主要是希望可以透過 Google 評論來獲取已標籤的語料資源(評論星級)，提供情緒分析所需的資料

![script snapshot](https://i.imgur.com/5PbR3rP.png)

### MATLAB工具箱需求 (MATLAB Toolbox Requirement)
* 無 None

#### 參數說明 :
    - searchToken: 目標抓取店家
    - storeCode: 目標店家之代碼
    - storeChosen: 店家名稱(檢查用)
    - commentResult: 爬取之評論結果
    - iter: 抓取次數
#### MATLAB 支援版本
    - R2020b
    - R2021a
    - R2021b
