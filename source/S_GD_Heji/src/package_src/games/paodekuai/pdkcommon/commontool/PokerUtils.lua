--
-- Author: Your Name
-- Date: 2017-09-27 15:33:12
-- 扑克工具类
--

local PokerUtils = class("PokerUtils")
local PokerClippingNode = require("package_src.games.paodekuai.pdkcommon.commontool.PokerClippingNode")

--繁体字
local kTradChinese = "汏熋僟噐亾錒皚藹礙愛噯嬡璦曖靄諳銨鵪骯襖奧媼驁鰲壩罷鈀擺敗唄頒辦絆鈑幫綁鎊謗剝飽寶報鮑鴇齙輩貝鋇狽備憊鵯賁錛繃筆畢斃幣閉蓽嗶潷鉍篳蹕邊編貶變辯辮芐緶籩標驃颮飆鏢鑣鰾鱉別癟瀕濱賓擯儐繽檳殯臏鑌髕鬢餅稟撥缽鉑駁餑鈸鵓補鈽財參蠶殘慚慘燦驂黲蒼艙倉滄廁側冊測惻層詫鍤儕釵攙摻蟬饞讒纏鏟產闡顫囅諂讖蕆懺嬋驏覘禪鐔場嘗長償腸廠暢倀萇悵閶鯧鈔車徹硨塵陳襯傖諶櫬磣齔撐稱懲誠騁棖檉鋮鐺癡遲馳恥齒熾飭鴟沖衝蟲寵銃疇躊籌綢儔幬讎櫥廚鋤雛礎儲觸處芻絀躕傳釧瘡闖創愴錘綞純鶉綽輟齪辭詞賜鶿聰蔥囪從叢蓯驄樅湊輳躥竄攛錯銼鹺達噠韃帶貸駘紿擔單鄲撣膽憚誕彈殫賧癉簞當擋黨蕩檔讜碭襠搗島禱導盜燾燈鄧鐙敵滌遞締糴詆諦綈覿鏑顛點墊電巔鈿癲釣調銚鯛諜疊鰈釘頂錠訂鋌丟銩東動棟凍崠鶇竇犢獨讀賭鍍瀆櫝牘篤黷鍛斷緞籪兌隊對懟鐓噸頓鈍燉躉奪墮鐸鵝額訛惡餓諤堊閼軛鋨鍔鶚顎顓鱷誒兒爾餌貳邇鉺鴯鮞發罰閥琺礬釩煩販飯訪紡鈁魴飛誹廢費緋鐨鯡紛墳奮憤糞僨豐楓鋒風瘋馮縫諷鳳灃膚輻撫輔賦復負訃婦縛鳧駙紱紼賻麩鮒鰒釓該鈣蓋賅桿趕稈贛尷搟紺岡剛鋼綱崗戇鎬睪誥縞鋯擱鴿閣鉻個紇鎘潁給亙賡綆鯁龔宮鞏貢鉤溝茍構購夠詬緱覯蠱顧詁轂鈷錮鴣鵠鶻剮掛鴰摑關觀館慣貫詿摜鸛鰥廣獷規歸龜閨軌詭貴劊匭劌媯檜鮭鱖輥滾袞緄鯀鍋國過堝咼幗槨蟈鉿駭韓漢闞絎頡號灝顥閡鶴賀訶闔蠣橫轟鴻紅黌訌葒閎鱟壺護滬戶滸鶘嘩華畫劃話驊樺鏵懷壞歡環還緩換喚瘓煥渙奐繯鍰鯇黃謊鰉揮輝毀賄穢會燴匯諱誨繪詼薈噦澮繢琿暉葷渾諢餛閽獲貨禍鈥鑊擊機積饑跡譏雞績緝極輯級擠幾薊劑濟計記際繼紀訐詰薺嘰嚌驥璣覬齏磯羈蠆躋霽鱭鯽夾莢頰賈鉀價駕郟浹鋏鎵蟯殲監堅箋間艱緘繭檢堿鹼揀撿簡儉減薦檻鑒踐賤見鍵艦劍餞漸濺澗諫縑戔戩瞼鶼筧鰹韉將漿蔣槳獎講醬絳韁膠澆驕嬌攪鉸矯僥腳餃繳絞轎較撟嶠鷦鮫階節潔結誡屆癤頜鮚緊錦僅謹進晉燼盡勁荊莖巹藎饉縉贐覲鯨驚經頸靜鏡徑痙競凈剄涇逕弳脛靚糾廄舊鬮鳩鷲駒舉據鋸懼劇詎屨櫸颶鉅鋦窶齟鵑絹錈鐫雋覺決絕譎玨鈞軍駿皸開凱剴塏愾愷鎧鍇龕閌鈧銬顆殼課騍緙軻鈳錁頷墾懇齦鏗摳庫褲嚳塊儈鄶噲膾寬獪髖礦曠況誆誑鄺壙纊貺虧巋窺饋潰匱蕢憒聵簣閫錕鯤擴闊蠐蠟臘萊來賴崍徠淶瀨賚睞錸癩籟藍欄攔籃闌蘭瀾讕攬覽懶纜爛濫嵐欖斕鑭襤瑯閬鋃撈勞澇嘮嶗銠鐒癆樂鰳鐳壘類淚誄縲籬貍離鯉禮麗厲勵礫歷瀝隸儷酈壢藶蒞蘺嚦邐驪縭櫪櫟轢礪鋰鸝癘糲躒靂鱺鱧倆聯蓮連鐮憐漣簾斂臉鏈戀煉練蘞奩瀲璉殮褳襝鰱糧涼兩輛諒魎療遼鐐繚釕鷯獵臨鄰鱗凜賃藺廩檁轔躪齡鈴靈嶺領綾欞蟶鯪餾劉瀏騮綹鎦鷚龍聾嚨籠壟攏隴蘢瀧瓏櫳朧礱樓婁摟簍僂蔞嘍嶁鏤瘺耬螻髏蘆盧顱廬爐擄鹵虜魯賂祿錄陸壚擼嚕閭瀘淥櫨櫓轤輅轆氌臚鸕鷺艫鱸巒攣孿灤亂臠孌欒鸞鑾掄輪倫侖淪綸論圇蘿羅邏鑼籮騾駱絡犖玀濼欏腡鏍驢呂鋁侶屢縷慮濾綠櫚褸鋝嘸媽瑪碼螞馬罵嗎嘜嬤榪買麥賣邁脈勱瞞饅蠻滿謾縵鏝顙鰻貓錨鉚貿麼沒鎂門悶們捫燜懣鍆錳夢瞇謎彌覓冪羋謐獼禰綿緬澠靦黽廟緲繆滅憫閩閔緡鳴銘謬謨驀饃歿鏌謀畝鉬吶鈉納難撓腦惱鬧鐃訥餒內擬膩鈮鯢攆輦鯰釀鳥蔦裊聶嚙鑷鎳隉蘗囁顢躡檸獰寧擰濘苧嚀聹鈕紐膿濃農儂噥駑釹諾儺瘧歐鷗毆嘔漚謳慪甌盤蹣龐拋皰賠轡噴鵬紕羆鈹騙諞駢飄縹頻貧嬪蘋憑評潑頗釙撲鋪樸譜鏷鐠棲臍齊騎豈啟氣棄訖蘄騏綺榿磧頎頏鰭牽釬鉛遷簽謙錢鉗潛淺譴塹僉蕁慳騫繾槧鈐槍嗆墻薔強搶嬙檣戧熗錆鏘鏹羥蹌鍬橋喬僑翹竅誚譙蕎繰磽蹺竊愜鍥篋欽親寢鋟輕氫傾頃請慶撳鯖瓊窮煢蛺巰賕蟣鰍趨區軀驅齲詘嶇闃覷鴝顴權勸詮綣輇銓卻鵲確闋闕愨讓饒擾繞蕘嬈橈熱韌認紉飪軔榮絨嶸蠑縟銣顰軟銳蜆閏潤灑薩颯鰓賽傘毿糝喪騷掃繅澀嗇銫穡殺剎紗鎩鯊篩曬釃刪閃陜贍繕訕姍騸釤鱔墑傷賞坰殤觴燒紹賒攝懾設厙灄畬紳審嬸腎滲詵諗瀋聲繩勝師獅濕詩時蝕實識駛勢適釋飾視試謚塒蒔弒軾貰鈰鰣壽獸綬樞輸書贖屬術樹豎數攄紓帥閂雙誰稅順說碩爍鑠絲飼廝駟緦鍶鷥聳慫頌訟誦擻藪餿颼鎪蘇訴肅謖穌雖隨綏歲誶孫損筍蓀猻縮瑣鎖嗩脧獺撻闥鉈鰨臺態鈦鮐攤貪癱灘壇譚談嘆曇鉭錟頇湯燙儻餳鐋鏜濤絳討韜鋱騰謄銻題體屜緹鵜闐條糶齠鰷貼鐵廳聽烴銅統慟頭鈄禿圖釷團摶頹蛻飩脫鴕馱駝橢籜鼉襪媧膃彎灣頑萬紈綰網輞韋違圍為濰維葦偉偽緯謂衛諉幃闈溈潿瑋韙煒鮪溫聞紋穩問閿甕撾蝸渦窩臥萵齷嗚鎢烏誣無蕪吳塢霧務誤鄔廡憮嫵騖鵡鶩錫犧襲習銑戲細餼鬩璽覡蝦轄峽俠狹廈嚇硤鮮纖賢銜閑顯險現獻縣餡羨憲線莧薟蘚峴獫嫻鷴癇蠔秈躚廂鑲鄉詳響項薌餉驤緗饗蕭囂銷曉嘯嘵瀟驍綃梟簫協挾攜脅諧寫瀉謝褻擷紲纈鋅釁興陘滎兇洶銹繡饈鵂虛噓須許敘緒續詡頊軒懸選癬絢諼鉉鏇學謔澩鱈勛詢尋馴訓訊遜塤潯鱘壓鴉鴨啞亞訝埡婭椏氬閹煙鹽嚴巖顏閻艷厭硯彥諺驗厴贗儼兗讞懨閆釅魘饜鼴鴦楊揚瘍陽癢養樣煬瑤搖堯遙窯謠藥軺鷂鰩爺頁業葉靨謁鄴曄燁醫銥頤遺儀蟻藝億憶義詣議誼譯異繹詒囈嶧飴懌驛縊軼貽釔鎰鐿瘞艤蔭陰銀飲隱銦癮櫻嬰鷹應纓瑩螢營熒蠅贏穎塋鶯縈鎣攖嚶瀅瀠瓔鸚癭頦罌喲擁傭癰踴詠鏞優憂郵鈾猶誘蕕銪魷輿魚漁娛與嶼語獄譽預馭傴俁諛諭蕷崳飫閾嫗紆覦歟鈺鵒鷸齬鴛淵轅園員圓緣遠櫞鳶黿約躍鑰粵悅閱鉞鄖勻隕運蘊醞暈韻鄆蕓惲慍紜韞殞氳雜災載攢暫贊瓚趲鏨贓臟駔鑿棗責擇則澤賾嘖幘簀賊譖贈綜繒軋鍘閘柵詐齋債氈盞斬輾嶄棧戰綻譫張漲帳賬脹趙詔釗蟄轍鍺這謫輒鷓貞針偵診鎮陣湞縝楨軫賑禎鴆掙睜猙爭幀癥鄭證諍崢鉦錚箏織職執紙摯擲幟質滯騭櫛梔軹輊贄鷙螄縶躓躑觶鐘終種腫眾鍾謅軸皺晝驟紂縐豬諸誅燭矚囑貯鑄駐佇櫧銖專磚轉賺囀饌顳樁莊裝妝壯狀錐贅墜綴騅縋諄準著濁諑鐲茲資漬諮緇輜貲眥錙齜鯔蹤總縱傯鄒諏騶鯫詛組鏃鉆纘躦鱒翺並蔔沈醜澱叠鬥範幹臯矽櫃後夥稭傑訣誇裏淩麽黴撚淒扡聖屍擡塗窪餵汙鍁鹹蠍彜湧遊籲禦願嶽雲竈紮劄築於誌註雕訁譾郤猛氹阪壟堖垵墊檾蕒葤蓧蒓菇槁摣咤唚哢噝噅撅劈謔襆嶴脊仿僥獁麅餘餷饊饢楞怵懍爿漵灩混濫瀦淡寧糸絝緔瑉梘棬案橰櫫軲軤賫膁腖飈糊煆溜湣渺碸滾瞘鈈鉕鋣銱鋥鋶鐦鐧鍩鍀鍃錇鎄鎇鎿鐝鑥鑹鑔穭鶓鶥鸌癧屙瘂臒襇繈耮顬蟎麯鮁鮃鮎鯗鯝鯴鱝鯿鰠鰵鱅鞽韝齇麽獣"

-------------------------------------
--@desc 将金币转换为带汉字单位和小数点的字符串
-------------------------------------
function  PokerUtils:formatCoin(curMoney)
	local suffix = "" --   字符串后缀： 空串表示没有，"wan" 表示万  "yi"表示亿 
    local moneyStr = nil;
    local curMoneyTmp = tonumber(curMoney);

    if not curMoneyTmp then
        return curMoney, "";
    end

    local maxLen = 5  --格式化后字符串最大长度
    local endMaxLen = 3 --格式化后字符串小数点后面的位数
    local money = curMoneyTmp .. "";
    local length = #money;

    if length <= 4 then
        return money;
    elseif length <= 8 then
    	local startLen = length - 4
        local startStr = string.sub(money, 1, startLen);
        local endLen = (maxLen - startLen) <  endMaxLen and  (maxLen - startLen) or endMaxLen
        local endStr1 = string.sub(money, startLen + 1, endLen + startLen );
        while endStr1 ~= "" do
        	if string.sub(endStr1, #endStr1 ) == "0" then
        		endStr1 = string.sub(endStr1, 1, #endStr1 - 1)
        	else
        		break
        	end
        end

        if endStr1 ~= "" then
            moneyStr = startStr .. "." .. endStr1 
        else
            moneyStr = startStr
        end
        suffix="wan"
    elseif length >= 9 then
    	local startLen = length - 8
        local startStr = string.sub(money, 1, startLen);
        local endLen = (maxLen > startLen) and  (maxLen - startLen) or endMaxLen
        local endStr1 = string.sub(money, startLen + 1, endLen + startLen);

        while endStr1 ~= "" do
        	if string.sub(endStr1, #endStr1 ) == "0" then
        		endStr1 = string.sub(endStr1, 1, #endStr1 - 1)
        	else
        		break
        	end
        end
        if endStr1 ~= "" then
            moneyStr = startStr .. "." .. endStr1;
        else
            moneyStr = startStr;
        end
        suffix="yi"
    end

    return moneyStr, suffix
end

-------------------------------------------------------
-- @desc 将纯数字转换为筹码显示的格式  1000 -> 1千
-------------------------------------------------------
function  PokerUtils:formatChip(curMoney)
    -- Log.i("PokerUtils:formatChip ",curMoney)
    local suffix = "" --   字符串后缀： 空串表示没有，"W" 表示万  "Q"表示千
    local moneyStr = nil;
    local curMoneyTmp = tonumber(curMoney);

    if not curMoneyTmp then
        return curMoney, "";
    end

    local maxLen = 5  --格式化后字符串最大长度
    local endMaxLen = 3 --格式化后字符串小数点后面的位数
    local money = curMoneyTmp .. "";
    local length = #money;

    if length <= 3 then
        return money;
    elseif length <= 4 then
        local startLen = length - 3
        local startStr = string.sub(money, 1, startLen);
        local endLen = (maxLen - startLen) <  endMaxLen and  (maxLen - startLen) or endMaxLen
        local endStr1 = string.sub(money, startLen + 1, endLen + startLen );
        while endStr1 ~= "" do
            if string.sub(endStr1, #endStr1 ) == "0" then
                endStr1 = string.sub(endStr1, 1, #endStr1 - 1)
            else
                break
            end
        end

        if endStr1 ~= "" then
            moneyStr = startStr .. "." .. endStr1 
        else
            moneyStr = startStr
        end
        suffix="Q"
    else
        local startLen = length - 4
        local startStr = string.sub(money, 1, startLen);
        local endLen = (maxLen > startLen) and  (maxLen - startLen) or endMaxLen
        local endStr1 = string.sub(money, startLen + 1, endLen + startLen);

        while endStr1 ~= "" do
            if string.sub(endStr1, #endStr1 ) == "0" then
                endStr1 = string.sub(endStr1, 1, #endStr1 - 1)
            else
                break
            end
        end
        if endStr1 ~= "" then
            moneyStr = startStr .. "." .. endStr1;
        else
            moneyStr = startStr;
        end
        suffix="W"
    end

    -- Log.i("PokerUtils:formatChip moneyStr .. suffix", moneyStr .. suffix)

    return moneyStr .. suffix
end

---------------------------------------------------------------
-- @desc        更新头像
-- @fileName    文件名
-- @url         图片网络地址
-- @stencil     头像切割模板
-- @useScale    是否缩放
-- @customSize  大小
-- @parent      父节点
-----------------------------------------------------------------------
function PokerUtils:updateHead(fileName, url, stencil, customSize, parent, head, tag, pos)
   local savePath = fileName;
    Log.i("PokerUtils.updateHead", "-------url = " .. url);
    Log.i("PokerUtils.updateHead", "-------fileName = ".. fileName);
    local onReponseNetworkImage = function (event)
        if event == nil or tolua.isnull(parent) then
            return;
        end
        local ok = (event.name == "completed")
        if not ok then
            return
        end

        local request = event.request;
        local code = request:getResponseStatusCode();
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
            Log.i("------onReponseNetworkImage code", code);
            return;
        end

        --CACHEDIR = device.writablePath
        local savePath = CACHEDIR .. fileName;
        Log.i("------onReponseNetworkImage savePath1:", savePath);
        request:saveResponseData(savePath);
        imgName = cc.FileUtils:getInstance():fullPathForFilename(savePath);
        
        if io.exists(savePath) then
            Log.i("****************************************************************************stencilPath = ",stencil)
            local head = PokerClippingNode.new(stencil, savePath, customSize)
            head:setPosition( pos or cc.p(parent:getContentSize().width/2-2, parent:getContentSize().height/2))
            head:setTag(tag)
            parent:addChild(head) 
        end
    end
    --
    local request = network.createHTTPRequest(onReponseNetworkImage, url, "GET");
    request:start();
end

--判断是否网络头像
function PokerUtils:isNetWorkHeadUrl(headUrl)
    if headUrl and string.find(headUrl, "http") then
        return true
    end
    return false
end

function PokerUtils:CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1
    end 
    return enumtbl 
end 

--本地时间格式
function PokerUtils:getLocalTimeStr()
    local data = os.date("*t", os.time());
    local hour = data.hour .. "";
    local min = data.min .. "";
    if data.hour < 10 then
        hour = "0" .. hour;
    end
    if data.min < 10 then
        min = "0" .. min;
    end
    return hour .. ":" .. min;
end

function PokerUtils:checkChinese(str)
    local f = '[\194-\244][\128-\191]*'

    for v in str:gfind(f) do
        local isCon = string.find(kTradChinese, v)
        if isCon ~= nil then
            return true
        end
    end

    return false
end

function PokerUtils:updateNickName(label, str, fontSize, color)
    if label ~= nil and (tolua.type(label) == "cc.Label" or tolua.type(label) == "ccui.Text") then
        str = str and str or ""
        if not fontSize then
            if tolua.type(label) == "ccui.Text" then
                fontSize = label:getFontSize()
            end
        end

        if self:checkChinese(str) then
            if tolua.type(label) == "cc.Label" then
                label:setSystemFontName("Helvetica-Bold")
                if fontSize then label:setSystemFontSize(fontSize) end
            elseif tolua.type(label) == "ccui.Text" then
                label:setFontName("Helvetica-Bold")
                if fontSize then label:setFontSize(fontSize) end
            end
        end

        label:setString(str)
        if color then label:setColor(color) end
    end
end

--[[
    截断字符串，会按照utf8截断，size对应，
    一个中文一个size，
    一个大写英文一个size，
    两个小写英文一个size
]]
function PokerUtils:subUtfStrByCn(str, index, size, endStr)
    if not str then
        return "";
    end
    if not index then
        return str;
    end
    if index > string.len(str) then
        return "";
    end
    local i = 1;
    local j = 1;

    local z = 1;

    local si = 1;
    local ei = 1;
    while true do
        j = i;
        local a = string.byte(string.sub(str, i) or "");
        local k = 1;
        if a then
            if a >= 252 then -- 六个字节编码
                k = 6;
            elseif a >= 248 then -- 五个字节编码
                k = 5;
            elseif a >= 240 then -- 四个字节编码
                k = 4;
            elseif a >= 224 then -- 三个字节编码
                k = 3;
            elseif a >= 192 then -- 两个字节编码
                k = 2;
            elseif a >= 64 and a <= 90 then --一个字节编码
                k = 1;
            else
                k = 1;
                local b = string.byte(string.sub(str,i+1) or "");
                if b then
                    if b < 64 or (b > 90 and b < 192) then
                        k = 2;
                    end
                else
                    k = 2;
                end
            end
        end

        if z == index then
            si = j;
        end
        i = i + k;

        if z >= (index + size) then
            ei = i - k - 1;
            break;
        end

        if i > string.len(str) then
            ei = string.len(str);
            break;
        end
        z = z + 1;
    end
    local tmp = string.sub(str, si, ei);
    if tmp and string.len(tmp) < string.len(str) then
        tmp = tmp .. endStr;
    end
    return tmp;
end

----------------------------------------------------
-- @desc shader置灰
----------------------------------------------------
function PokerUtils:setGrey(node,index)
   local vertDefaultSource = [[

            attribute vec4 a_position;
            attribute vec2 a_texCoord;
            attribute vec4 a_color;  

            #ifdef GL_ES
                varying lowp vec4 v_fragmentColor;
                varying mediump vec2 v_texCoord;
            #else
                varying vec4 v_fragmentColor;
                varying vec2 v_texCoord;
            #endif 

            void main()
            {
                gl_Position = CC_PMatrix * a_position; 
                v_fragmentColor = a_color;
                v_texCoord = a_texCoord;
            }

            ]]

    local pszFragSource = [[

        #ifdef GL_ES 
                        precision mediump float;
                #endif 
                varying vec4 v_fragmentColor; 
                varying vec2 v_texCoord; 

                void main(void) 
                { 
                    vec4 c = texture2D(CC_Texture0, v_texCoord);
                    gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b);
                    gl_FragColor.w = c.w; 
                }

                ]]

    local psRemoveGrayShader = [[
       #ifdef GL_ES
        precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;
        void main(void)
        {
            gl_FragColor = texture2D(CC_Texture0, v_texCoord);
        } 
    ]]
    local pProgram = nil
    if index == 1 then
        pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)
    else
        pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, psRemoveGrayShader)
    end
--    if index == 1 then
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
--    else
--        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
--        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
--        pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_TEX_COORD)
--    end
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram) 
end

-----------------------------------------------------------
-- @desc 替换查找符号信息
-----------------------------------------------------------
function PokerUtils:replaceFindInfo(text,findFlag,replaceDataList)
	local retText=nil
	local bTrue=true
	local bFind=nil
    local bFind2 = nil
	local index=1
    local startIndex = 1
    local strs = {}
	while bTrue do
		bFind, bFind2 = string.find(text,findFlag, startIndex)
		if(bFind==nil or index>#replaceDataList) then
            local sub = string.sub(text, startIndex, string.len(text))
            table.insert(strs, sub)
		    return table.concat(strs)
		end

        local sub = string.sub(text, startIndex, bFind - 1)
        startIndex = bFind2 + 1

        table.insert(strs, sub)
        table.insert(strs, replaceDataList[index])

		index = index +1   
	end 	
end

function PokerUtils:setGreyAll(node, ok)
    self:setGrey(node, ok)
    for i,v in ipairs(node:getChildren()) do
        self:setGreyAll(v, ok)
    end
end

function PokerUtils:debugDraw(node, color)
	local drawNode = cc.DrawNode:create()
	local size = node:getContentSize()
	local poses = {cc.p(0, 0), cc.p(size.width, 0), cc.p(size.width, size.height), cc.p(0, size.height)}
	if color == nil then
		color = cc.c4f(0, 1, 0, 0.5)
	end
	drawNode:drawSolidPoly(poses, 4, color)
	drawNode:setPosition(cc.p(0, 0))
	node:addChild(drawNode, 1000)
end

function PokerUtils:disOrderTable(t)
    if type(t)~="table" then
        return
    end
    local l=#t
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

return PokerUtils