-- 認証不要で使える翻訳API。1リクエストあたり500バイトまで
local translateApiUrl = "https://api.mymemory.translated.net/get"
local translateByteLimit = 500

-- 英単語が3つ以上並ぶ行だけを説明文とみなす。インデントされたコードや
-- flask_admin.model.base のようなドット区切りの識別子は翻訳しない
local function isEnglishSentence(line)
    if #line >= translateByteLimit or line:match("^    ") or line:match("%w%.%w+%.%w") then
        return false
    end
    local wordCount = 0
    for _ in line:gmatch("%a%a+") do
        wordCount = wordCount + 1
    end
    return wordCount >= 3
end

local function translateToJapanese(englishLine, onFinished)
    vim.system({
        "curl",
        "-s",
        "-G",
        translateApiUrl,
        "--data-urlencode",
        "q=" .. englishLine,
        "--data-urlencode",
        "langpair=en|ja",
    }, { text = true }, function(command)
        local isDecoded, response = pcall(vim.json.decode, command.stdout or "")
        local translatedText = isDecoded and type(response.responseData) == "table" and response.responseData.translatedText
        -- 翻訳できなかった時は英語の警告文が返るので、日本語を含む時だけ採用する
        if type(translatedText) == "string" and translatedText:match("[\128-\255]") then
            onFinished(translatedText)
        else
            onFinished(nil)
        end
    end)
end

-- 説明文を和訳に置き換える。翻訳できなかった行は原文のまま残す
local function replaceWithJapanese(originalLines, japaneseLines)
    local displayLines = {}
    for lineNumber, line in ipairs(originalLines) do
        table.insert(displayLines, japaneseLines[lineNumber] or line)
    end
    return displayLines
end

local function openHoverWindow(lines)
    vim.lsp.util.open_floating_preview(lines, "markdown", {
        border = "rounded",
        wrap = true,
        max_width = 100,
        focus_id = "hover-translate",
    })
end

-- ```で囲まれたコードブロックの中は翻訳対象から外す
local function collectEnglishLineNumbers(lines)
    local englishLineNumbers = {}
    local isInCodeBlock = false
    for lineNumber, line in ipairs(lines) do
        if line:match("^%s*```") then
            isInCodeBlock = not isInCodeBlock
        elseif not isInCodeBlock and isEnglishSentence(line) then
            table.insert(englishLineNumbers, lineNumber)
        end
    end
    return englishLineNumbers
end

local function showTranslatedHover(hoverTexts)
    local lines = {}
    for _, hoverText in ipairs(hoverTexts) do
        vim.list_extend(lines, vim.split(hoverText, "\n"))
    end

    local englishLineNumbers = collectEnglishLineNumbers(lines)
    if #englishLineNumbers == 0 then
        vim.schedule(function()
            openHoverWindow(lines)
        end)
        return
    end

    local japaneseLines = {}
    local restCount = #englishLineNumbers
    for _, lineNumber in ipairs(englishLineNumbers) do
        translateToJapanese(lines[lineNumber], function(japaneseLine)
            japaneseLines[lineNumber] = japaneseLine
            restCount = restCount - 1
            if restCount == 0 then
                vim.schedule(function()
                    openHoverWindow(replaceWithJapanese(lines, japaneseLines))
                end)
            end
        end)
    end
end

-- hoverの内容を取得して和訳を添えて出す。取れなければ通常のhoverに戻す
function TranslateHoverDocumentation()
    if vim.fn["coc#rpc#ready"]() == 0 or vim.fn.CocAction("hasProvider", "hover") == 0 then
        CocShowDocumentation()
        return
    end
    vim.fn.CocActionAsync("getHover", function(err, hoverTexts)
        if err ~= vim.NIL or type(hoverTexts) ~= "table" or #hoverTexts == 0 then
            vim.schedule(CocShowDocumentation)
            return
        end
        showTranslatedHover(hoverTexts)
    end)
end
