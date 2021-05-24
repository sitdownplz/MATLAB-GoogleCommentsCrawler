%% Google 評論爬蟲 Google Comments Crawler 
% 版本號 Version Dev.0
% (測試版本 R2021a)
% ============================
% 工具箱需求 Toolbox Requirement: 
%      None
% ============================
%  參數說明 (Parameters) :
%       searchToken: 目標抓取店家
%       storeCode: 目標店家之代碼
%       storeChosen: 店家名稱(檢查用)
%       commentResult: 爬取之評論結果
%       iter: 抓取次數
%  ============================
% 
%% 輸入搜尋店家或關鍵字 Search term 
searchToken = '饗饗';
searchTerm = urlencode(searchToken);
%% 獲取使用者當下位置以搜尋相關結果 Get user location to gather related result
[latitude,longitude] = getUserLocation;
%% 建構搜尋條件與目標網址 Construct parameters with search url
searchURL = ['https://www.google.com.tw/search?tbm=map&authuser=0&hl=zh-TW&gl=tw&pb=!4m9!1m3!1d1858071.018126',...
    '!2d',longitude,...
    '!3d',latitude,...
    '!2m0!3m2!1i406!2i762!4f13.1!7i20!10b1!12m8!1m1!18b1!2m3!5m1!6e2!20e3!10b1!16b1!19m4!2m3!1i360!2i120!4i8!20m65!2m2!1i203!2i100!3m2!2i4!5b1!6m6!1m2!1i86!2i86!1m2!1i408!2i240!7m50!1m3!1e1!2b0!3e3!1m3!1e2!2b1!3e2!1m3!1e2!2b0!3e3!1m3!1e3!2b0!3e3!1m3!1e8!2b0!3e3!1m3!1e3!2b1!3e2!1m3!1e10!2b0!3e3!1m3!1e10!2b1!3e2!1m3!1e9!2b1!3e2!1m3!1e10!2b0!3e3!1m3!1e10!2b1!3e2!1m3!1e10!2b0!3e4!2b1!4b1!9b0!22m6!1sBrqTYIG1CLLTmAXT-azADw%3A2!2s1i%3A0%2Ct%3A11886%2Cp%3ABrqTYIG1CLLTmAXT-azADw%3A2!7e81!12e5!17sBrqTYIG1CLLTmAXT-azADw%3A76!18e15!24m54!1m16!13m7!2b1!3b1!4b1!6i1!8b1!9b1!20b1!18m7!3b1!4b1!5b1!6b1!9b1!13b1!14b0!2b1!5m5!2b1!3b1!5b1!6b1!7b1!10m1!8e3!14m1!3b1!17b1!20m2!1e3!1e6!24b1!25b1!26b1!29b1!30m1!2b1!36b1!43b1!52b1!54m1!1b1!55b1!56m2!1b1!3b1!65m5!3m4!1m3!1m2!1i224!2i298!89b1!26m4!2m3!1i80!2i92!4i8!30m0!34m17!2b1!3b1!4b1!6b1!8m5!1b1!3b1!4b1!5b1!6b1!9b1!12b1!14b1!20b1!23b1!25b1!26b1!37m1!1e81!42b1!47m0!49m1!3b1!50m4!2e2!3m2!1b1!3b1!65m1!1b1!67m2!7b1!10b1!69i556',...
    '&q=',searchTerm,...
    '&oq=',searchTerm,...
    '&gs_l=maps.3..38i39i111i426k1.127976.137501.1.143238.20.20.0.0.0.0.315.1499.8j3j1j1.17.0....0...1ac.1j4.64.maps..3.17.2417.2..38i39k1j38i426k1j38i376k1j115i144k1j38i442i426k1j38i72k1.12.&tch=1&ech=1&psi=BrqTYIG1CLLTmAXT-azADw.1620294152153.1'];
opt = weboptions('ContentType','text');
rawMapInfo = webread(searchURL,opt);
rawMapInfo = regexprep(rawMapInfo,'\/\*""\*\/','');
MapInfo = jsondecode(rawMapInfo);
%% 擷取店家代號 Decode JSON result and extract store code 
commentRaw = MapInfo.d;
rawData_search = regexprep(commentRaw,")]}\'",'');
jsonData_search = jsondecode(rawData_search);
if length(jsonData_search{1}{2}{1})<15
    % 如果搜尋為關鍵字，選擇相關性第一之店家
    storeCode = jsonData_search{1}{2}{2}{15}{73}{1}{1}{30};
    storeChosen = jsonData_search{1}{2}{2}{15}{12};
    fprintf('搜尋為關鍵字，選擇最相關之結果爬取: %s\n',storeChosen)
else
    storeCode = jsonData_search{1}{2}{1}{15}{73}{1}{1}{30};
    storeChosen = jsonData_search{1}{2}{1}{15}{12};
    fprintf('爬取搜尋內容: %s\n',storeChosen)
end
%% 根據店家代號抓取評論 Gather comments base on store code
commentResult = [];
for iter = 0:10:1000 % 10 comments per page
    % Wait for page load idf needed
    %     pause(0.5)
    iter = num2str(iter);
    commentURL = ['https://www.google.com/maps/preview/review/listentitiesreviews?authuser=0&hl=zh-TW&gl=tw&pb=!1m2',...
        '!1y',storeCode{1},...
        '!2y',storeCode{2},...
        '!2m2!1i',...
        iter,...
        '!2i10!3e1!4m5!3b1!4b1!5b1!6b1!7b1!5m2!1s_52TYKO3CNDr-QaSwqvYDQ!7e81'];
    rawData = webread(commentURL,opt);
    rawData = regexprep(rawData,")]}\'",'');
    jsonData = jsondecode(rawData);
    
    extractData = jsonData{3};
    
    if iscell(extractData)
        commentInfo = cellfun(@DataFormatting,extractData,'UniformOutput',false);
        tempResult = vertcat(commentInfo{:});
        commentResult = [commentResult;tempResult];
    end
end
%% Helper Funcitons

% Construct result from raw data
function info = DataFormatting(raw)
info.username = '';
info.day = '';
info.comment = '';
info.rate = '';

if ~isempty(raw{1}{2})
    info.username = raw{1}{2};
end

if ~isempty(raw{2})
    info.day = raw{2};
end

if ~isempty(raw{4})
    info.comment = raw{4};
end

if ~isempty(raw{5})
    info.rate = raw{5};
end
info = struct2table(info,'AsArray',true);
end

% Get user location through Google Map 
function [latitude,longitude] = getUserLocation
locationURL = 'https://www.google.com.tw/maps';
output = webread(locationURL);
locationInfo = unique(regexp(output,'(center=.*?&amp?)','match'));
location = regexp(locationInfo,'(\d*\.\d*)','match');
latitude = location{1}{1};
longitude = location{1}{2};


if str2double(latitude) >= 0
    lat_postfix = '°N';
else
    lat_postfix = '°S';
end
if str2double(longitude) >= 0
    long_postfix = '°E';
else
    long_postfix = '°W';
end

fprintf('現在位置為: %s%s, %s%s\n',latitude,lat_postfix,longitude,long_postfix)
end
