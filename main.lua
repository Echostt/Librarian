--ItemTextGetText() text on current readable page
--ItemTextGetItem() name of current readable item
--ItemTextHasNextPage() bool for another page available

-- BookObj format
-- title = name of the text item
-- text = text content of the book
-- isRead = bool for encountering book
-- dateFound = date that book was discovered
-- location = area in the world where book is found

local TextBorderFrame = CreateFrame("Frame", null, UIParent)
local TextFrame = CreateFrame("Frame", null, scrollframe)
TextFrame:EnableMouseWheel(1)
local BookFrame = CreateFrame("Frame", null, UIParent)
local TextFrameEvents = {}
local BookFrameEvents = {}
local bookCount
local validBookTitles = {
	"Aftermath of the Second War", 
	"The Guardians of Tirisfal",
	"The Alliance of Lordaeron"
}

--MAIN TEXT FRAME
function TextFrameEvents:ITEM_TEXT_BEGIN(...)
	if BookObjs == nil then
		BookObjs = {}
	end
	
	--parent frame 
	TextBorderFrame:SetSize(500, 500) 
	TextBorderFrame:SetPoint("CENTER") 
	local tex = TextBorderFrame:CreateTexture(nil,"BACKGROUND")
	tex:SetTexture("Interface\\ItemTextFrame\\Book.blp")
	tex:SetAllPoints(TextBorderFrame)
	TextBorderFrame.texture = tex;
	
	--scrollframe 
	scrollframe = CreateFrame("ScrollFrame", nil, TextBorderFrame) 
	scrollframe:SetPoint("TOPLEFT", 0, -25) 
	scrollframe:SetPoint("BOTTOMRIGHT", 0, 35)
	local texture = scrollframe:CreateTexture() 
	texture:SetAllPoints() 
	texture:SetTexture(.5,.5,.5,1) 
	TextBorderFrame.scrollframe = scrollframe 
	
	--scrollbar 
	scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPLEFT", TextBorderFrame, "TOPRIGHT", -10, -20) 
	scrollbar:SetPoint("BOTTOMLEFT", TextBorderFrame, "BOTTOMRIGHT", -10, 35) 
	scrollbar:SetMinMaxValues(1, 700) 
	scrollbar:SetValueStep(1) 
	scrollbar.scrollStep = 1 
	scrollbar:SetValue(0) 
	scrollbar:SetWidth(16) 
	scrollbar:SetScript("OnValueChanged", 
	function (self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end) 
	TextBorderFrame.scrollbar = scrollbar 
	
	--content
	TextFrame:ClearAllPoints()
	TextFrame:SetHeight(1100)
	TextFrame:SetWidth(450)

	TextFrame.text = TextFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal_NoShadow")
	TextFrame.text:SetTextColor(0, 0, 0, 1)
	TextFrame.text:SetAllPoints(TextFrame)
	TextFrame.text:SetPoint("TOPLEFT")
	TextFrame.text:SetJustifyV("TOP")
	TextFrame.text:SetText("\n" .. ItemTextGetItem() .. "\n\n")
	
	scrollframe.content = TextFrame 
	scrollframe:SetScrollChild(TextFrame)

	TextFrame:Show()
	scrollframe:Show()
	TextBorderFrame:Show()
	scrollbar:Show()
end

local bookTextPos = 1
local bookText = {}
local isBookFinished = false
function TextFrameEvents:ITEM_TEXT_READY(...)
	if ItemTextGetText() ~= nil then
		bookText[bookTextPos] = ItemTextGetText() .. " "
		bookTextPos = bookTextPos + 1
		if ItemTextHasNextPage() then
			ItemTextNextPage()
		else
			isBookFinished = true
		end
	end
	if isBookFinished then
		for _ in pairs(bookText) do TextFrame.text:SetText(TextFrame.text:GetText() .. "\n" .. bookText[_]) end
		isBookFinished = false
		bookText = {}
		bookTextPos = 1
	end
end


function TextFrameEvents:PLAYER_STARTED_MOVING(...)
	if TextFrame.text ~= nil then
		bookTextPos = 1
		TextFrame.text:SetText("")
		TextFrame:Hide()
		scrollframe:Hide()
		TextBorderFrame:Hide()
		scrollbar:Hide()
	end
end

TextFrame:SetScript("OnMouseWheel", function(...)
	if select(2, ...) == 1 then
		TextBorderFrame.scrollbar:SetValue(TextBorderFrame.scrollbar:GetValue() - 16)
	else
		TextBorderFrame.scrollbar:SetValue(TextBorderFrame.scrollbar:GetValue() + 16)
	end
end)

TextFrame:SetScript("OnEvent", function(self, event, ...)
	TextFrameEvents[event](self, ...);
end)

for k,v in pairs(TextFrameEvents) do
	TextFrame:RegisterEvent(k);
end

--END MAIN TEXT FRAME


--BOOK FRAME

function BookFrameEvents:ITEM_TEXT_BEGIN(...)
	BookFrame:ClearAllPoints()
	BookFrame:SetBackdrop(StaticPopup1:GetBackdrop())
	BookFrame:SetHeight(500)
	BookFrame:SetWidth(300)

	BookFrame.text = BookFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	BookFrame.text:SetAllPoints()
	BookFrame.text:SetText("Books")
	BookFrame:SetPoint("CENTER", -400, 0)
	BookFrame:Show()
	LoadBookList()
end

function BookFrameEvents:PLAYER_STARTED_MOVING(...)
	if BookFrame.text ~= nil then
		BookFrame.text:SetText("")
		BookFrame:Hide()
	end
end

BookFrame:SetScript("OnEvent", function(self, event, ...)
	BookFrameEvents[event](self, ...);
end);

for k,v in pairs(BookFrameEvents) do
	BookFrame:RegisterEvent(k);
end

--END BOOK FRAME

function LoadBookList()
	local t = "Book\n"
	for _ in pairs(validBookTitles) do t = t .. "\n" .. validBookTitles[_] end
	BookFrame.text:SetText(t)
end




SLASH_LIBCHECK1 = "/lib"
function SlashCmdList.LIBCHECK(msg)
	
	print("slash lib")
	if msg == "clear" then
		print("Clearing books")
		BookObjs = {}
	else
		if BookObjs == nil then
			BookObjs = {}
		end
		
		bookCount = TableLength(BookObjs)
		print("Date: " .. date("%m/%d/%y"))
		
		print("valid book?")
		print(CheckIfValidBook(ItemTextGetItem()))
		print(ItemTextGetMaterial())
		
		print("books: ")
		for i = 1, TableLength(BookObjs), 1 do
			print(BookObjs[i].title)
		end
		
		local bookFoundAt = SearchForBookTitle(ItemTextGetItem())
		if bookFoundAt ~= 0 then
			print("Book " .. ItemTextGetItem() .. " found at: " .. bookFoundAt)
		else
			print("Adding book")
			BookObjs[bookCount + 1] = {title=ItemTextGetItem(), text=GetBookText(), isRead=true}
			bookCount = bookCount + 1
		end
	end
end

--Returns item count of passed table.
function TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

--Returns the position of book object in book objects based on book title. Returns position 0 if not found.
function SearchForBookTitle(bookTitle)
	for i = 1, bookCount, 1 do
		if BookObjs[i].title == bookTitle then
			return i
		end
	end
	return 0
end

--Pass in title of book object to see if it is within the list of acceptable book objects.
function CheckIfValidBook(bookTitle) 
	for _ in pairs(validBookTitles) do 
		if validBookTitles[_] == bookTitle then
			return true
		end
	end
	return false
end
-------------------------------------------------------------------
-----------------------------------------------------------
------------------------------------------------------
----------------------------------------------







