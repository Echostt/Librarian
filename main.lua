--ItemTextGetText() text on current readable page
--ItemTextGetItem() name of current readable item
--ItemTextHasNextPage() bool for another page available

-- BookObj format
-- title = name of the text item
-- text = text content of the book
-- isRead = bool for encountering book
-- dateFound = date that book was discovered
-- location = area in the world where book is found


--https://www.wowhead.com/book-objects

local TextBorderFrame = CreateFrame("Frame", null, UIParent)
local TextFrame = CreateFrame("Frame", null, scrollframe)
TextFrame:EnableMouseWheel(1)
local BookBorderFrame = CreateFrame("Frame", null, UIParent)
local BookFrame = CreateFrame("Frame", null, bookscrollframe)
BookFrame:EnableMouseWheel(1)
local TextFrameEvents = {}
local BookFrameEvents = {}
local isTextReady = true

local validBookTitles = {
	"A Most Famous Bill of Sale",
	"A Zombie's Guide to Proper Nutrition",
	"Account of the Raising of a Frost Wyrm",
	"Adherent Note",
	"Admiral Barean Westwind",
	"Admiral Taylor",
	"Aegwynn and the Dragon Hunt",
	"Aftermath of the Second War", 
	"Age of a Hundred Kings",
	"Agents of Order",
	"Airbase in a Box Brochure",
	"Airwyn's Journal",
	"Akali",
	"Altar of Zanza",
	"Always Remember",
	"Amber",
	"Ancient Highborne Tome",
	"Ancient Nazmani Tablet",
	"Ancient Neltharion Tablets",
	"Ancient Sap Feeder",
	"Ancient Tidesage Scroll",
	"Another Direhorn Casualty",
	"Apothecary Tins of Yao Firmpaw",
	"Aquarium of Wonders",
	"Aquatic Wonders",
	"Arathor and the Troll Wars",
	"Archavon's Log",
	"Archbishop Alonsus Faol",
	"Archimonde's Return and the Flight to Kalimdor",
	"Archmage Antonidas",
	"Archmage Khadgar of the Kirin Tor",
	"Arellas Fireleaf",
	"Asgrim the Dreadkiller",
	"ATTENTION: Geists",
	"Baelog's Journal",
	"Banner of the Mantid Empire",
	"Barely Legible Scroll",
	"Battlelog of Warlord Bloodhilt",
	"Beasts of Barren Savannas",
	"Beasts of the Sky",
	"Beyond the Dark Portal",
	"Bilgewater Cartel Contract",
	"Binding Raptors",
	"Carelessly Dropped Note",
	"Caruk the Simple",
	"Carved Bronze Mirror",
	"Charge of the Dragonflights",
	"Civil War in the Plaguelands",
	"Coming of Age",
	"Compendium of Fallen Heroes",
	"Corpulous' Mess Hall Rules",
	"Cracked Tablet",
	"Cursed Gravestone",
	"Cycle of the Mantid",
	"Danath Trollbane",
	"Dark Keeper Nameplate",
	"De Gral Kantik",
	"Decorated Gravestone",
	"Decorated Headstone",
	"Desolate Deserts",
	"Devilsaur Calling Tips",
	"Dog-Eared Page",
	"Dominance",
	"Doren's Logs",
	"Dorgar Stoenbrow",
	"Drust Stele: Breath Into Stone",
	"Drust Stele: Conflict",
	"Drust Stele: Constructs",
	"Drust Stele: Protectors of the Forest",
	"Drust Stele: Sacrifice",
	"Drust Stele: The Circle",
	"Drust Stele: The Cycle",
	"Drust Stele: The Flayed Man",
	"Drust Stele: The Ritual",
	"Drust Stele: The Tree",
	"Dusty Journal",
	"Edict of the Thunder King",
	"Edicts of the Thunder King",
	"Embracing the Passions",
	"Empires' Fall",
	"Empty Keg of Brewfather Xin Wo Yin",
	"Engraved Stone Plaque",
	"Etched Note",
	"Exhumer's Journal",
	"Exile of the High Elves",
	"Faded Note",
	"Fellari Swiftarrow",
	"Ferren Marcus",
	"For Council and King",
	"Forestlord and the first Druids",
	"Forgemaster Deng",
	"Fossilized Egg",
	"Fractured Tablet",
	"Frozen Friends",
	"Fur Blanket",
	"Ga'trul's Logs",
	"Garley's Journal",
	"General Jakra'zet",
	"General Lena Stormpike",
	
	"The Guardians of Tirisfal",
	"The Alliance of Lordaeron",
	"The Betrayer Ascendant"
}

local function LoadTextFrames(...)
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
	scrollbar:SetMinMaxValues(1, 4000) 
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
	TextFrame:SetHeight(8000)
	TextFrame:SetWidth(450)

	TextFrame.text = TextFrame:CreateFontString(nil, "BACKGROUND", "QuestFont_Large")
	TextFrame.text:SetTextColor(0, 0, 0, 1)
	TextFrame.text:SetAllPoints(TextFrame)
	TextFrame.text:SetPoint("TOPLEFT")
	TextFrame.text:SetJustifyV("TOP")
	--TextFrame.text:SetText(ItemTextGetItem())
	
	scrollframe.content = TextFrame 
	scrollframe:SetScrollChild(TextFrame)

	TextFrame:Show()
	scrollframe:Show()
	TextBorderFrame:Show()
	scrollbar:Show()
	
	--////////////////////////////////////////////////////////////
	--//// BEGIN LOADING BOOK FRAME
	--////////////////////////////////////////////////////////////
	--////////////////////////////////////////////////////////////
	
	--parent frame
	BookBorderFrame:SetSize(400, 500)
	BookBorderFrame:SetPoint("CENTER", -450, 0)
	BookBorderFrame:SetBackdrop(StaticPopup1:GetBackdrop())
	
	--scrollframe 
	bookscrollframe = CreateFrame("ScrollFrame", nil, BookBorderFrame) 
	bookscrollframe:SetPoint("TOPLEFT", 0, -25) 
	bookscrollframe:SetPoint("BOTTOMRIGHT", 0, 35)
	
	--scrollbar 
	bookscrollbar = CreateFrame("Slider", nil, bookscrollframe, "UIPanelScrollBarTemplate") 
	bookscrollbar:SetPoint("TOPLEFT", BookBorderFrame, "TOPRIGHT", -15, -20) 
	bookscrollbar:SetPoint("BOTTOMLEFT", BookBorderFrame, "BOTTOMRIGHT", -15, 35) 
	bookscrollbar:SetMinMaxValues(1, 1500) 
	bookscrollbar:SetValueStep(1) 
	bookscrollbar.scrollStep = 1 
	bookscrollbar:SetValue(0) 
	bookscrollbar:SetWidth(16) 
	bookscrollbar:SetScript("OnValueChanged", 
	function (self, value) 
		self:GetParent():SetVerticalScroll(value) 
	end) 
	BookBorderFrame.scrollbar = bookscrollbar 

	--content
	BookFrame:ClearAllPoints()
	BookFrame:SetHeight(2400)
	BookFrame:SetWidth(400)
	BookFrame.text = BookFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	BookFrame.text:SetAllPoints()
	BookFrame.text:SetText("Books")
	BookFrame:SetPoint("CENTER", 0, 0)
	BookFrame.text:SetPoint("TOPLEFT")
	BookFrame.text:SetJustifyV("TOP")
	
	bookscrollframe.content = BookFrame
	bookscrollframe:SetScrollChild(BookFrame)
	
	BookFrame:Show()
	bookscrollframe:Show()
	BookBorderFrame:Show()
	bookscrollbar:Show()
	LoadBookList()
end

local bookTextPos = 1
local bookText = {}
local isBookFinished = false
local bookTextString = ""

function TextFrameEvents:PLAYER_STARTED_MOVING(...)
	CloseAllFrames()
end

function TextFrameEvents:ITEM_TEXT_READY(...)
	if isTextReady == true then 
		isTextReady = false 
		CheckIfValidBookObject() 
	end
end

TextFrame:SetScript("OnMouseWheel", function(...)
	if select(2, ...) == 1 then
		TextBorderFrame.scrollbar:SetValue(TextBorderFrame.scrollbar:GetValue() - 24)
	else
		TextBorderFrame.scrollbar:SetValue(TextBorderFrame.scrollbar:GetValue() + 24)
	end
end)

TextFrame:SetScript("OnEvent", function(self, event, ...)
	TextFrameEvents[event](self, ...);
end)

for k,v in pairs(TextFrameEvents) do
	TextFrame:RegisterEvent(k);
end

--END MAIN TEXT FRAME


BookFrame:SetScript("OnEvent", function(self, event, ...)
	BookFrameEvents[event](self, ...);
end);

for k,v in pairs(BookFrameEvents) do
	BookFrame:RegisterEvent(k);
end

BookFrame:SetScript("OnMouseWheel", function(...)
	if select(2, ...) == 1 then
		BookBorderFrame.scrollbar:SetValue(BookBorderFrame.scrollbar:GetValue() - 24)
	else
		BookBorderFrame.scrollbar:SetValue(BookBorderFrame.scrollbar:GetValue() + 24)
	end
end)

--END BOOK FRAME

--Sets Book Frame's text to available books
function LoadBookList()
	local t = "Book\n"
	local yOff = 0
	for _ in pairs(validBookTitles) do
		local Button = CreateFrame("Button", validBookTitles[_], BookFrame, "GameMenuButtonTemplate")
		if BookObjs[SearchForBookTitle(Button:GetName())] ~= nil and BookObjs[SearchForBookTitle(Button:GetName())].isRead == true then
			print("Loaded Discovered Book")
			Button = CreateFrame("Button", validBookTitles[_], BookFrame, "GameMenuButtonTemplate")
		elseif BookObjs[SearchForBookTitle(Button:GetName())] ~= nil then
			print("Loaded Undiscovered Book")
			Button = CreateFrame("Button", validBookTitles[_], BookFrame, "UIPanelButtonTemplate")
		else
			print("Loaded Unavaialable Book")
			Button = CreateFrame("Button", validBookTitles[_], BookFrame, "UIPanelButtonTemplate")
		end
		Button:SetWidth(150)
		Button:SetHeight(25)
		Button:SetPoint("TOP", 0, yOff)
		Button:SetText(Button:GetName())
		Button:RegisterForClicks("AnyUp")
		Button:SetScript("OnClick", function()
			print(Button:GetName())
			if SearchForBookTitle(Button:GetName()) ~= 0 
			and
			BookObjs[SearchForBookTitle(Button:GetName())].isRead == true then
			
				TextFrame.text:SetText(
					Button:GetName() .. "\n\n" ..
					BookObjs[SearchForBookTitle(Button:GetName())].text
				)
				print("Inner Book Setting: " .. BookObjs[SearchForBookTitle(Button:GetName())].title)
			else
				--TextFrame.text:SetText("Found at: " + BookObjs[SearchForBookTitle(Button:GetName())].location)
				TextFrame.text:SetText(Button:GetName() .. "\n\n" .. "Found at: DEFAULT LOADBOOKLIST")
			end
		end )
		yOff = yOff - 20
	end
end


SLASH_LIBCHECK1 = "/lib"
function SlashCmdList.LIBCHECK(msg)
	if bookCount == nil then
		bookCount = 0
	end
	if msg == "clear" then
		print("Clearing books")
		BookObjs = {}
		bookCount = 0
	elseif msg == "books" then
		print("books: ")
		print("Date: " .. date("%m/%d/%y"))
		for i = 1, TableLength(BookObjs), 1 do
			bookCount = TableLength(BookObjs)
			print(BookObjs[i].title)
		end
	elseif msg == "check" then
		CheckIfValidBookObject()
	else
		if BookObjs == nil then
			BookObjs = {}
		end		
	
		LoadTextFrames()
		
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
			--print("Title: " .. BookObjs[i].title .. " found at: " .. i)
			return i
		end
	end
	return 0
end

--Close all open frames
function CloseAllFrames()
	if TextFrame.text ~= nil then
		bookTextPos = 1
		TextFrame.text:SetText("")
		TextFrame:Hide()
		scrollframe:Hide()
		TextBorderFrame:Hide()
		scrollbar:Hide()
		bookscrollbar:Hide()
		BookBorderFrame:Hide()
	end
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

function CheckIfValidBookObject()
	print("check")
	if bookCount == nil then 
		bookCount = 0
	end
	local bookFoundAt = SearchForBookTitle(ItemTextGetItem())
	local isBookFinished = false
	print(CheckIfValidBook(ItemTextGetItem()))
	if CheckIfValidBook(ItemTextGetItem()) == true then
		if bookFoundAt ~= 0 then
			print("Book " .. ItemTextGetItem() .. " found at: " .. bookFoundAt)
		else
			bookText = {}
			while isBookFinished == false do
				bookText[bookTextPos] = ItemTextGetText() .. " \n"
				bookTextPos = bookTextPos + 1
				if ItemTextHasNextPage() then
					ItemTextNextPage()
				else
					isBookFinished = true
				end
			end
			bookTextString = ""
			for _ in pairs(bookText) do bookTextString = bookTextString .. bookText[_] end
			print("Book Text String: ")
			print(bookText)
			print("Adding book")
			-- BookObj format
				-- title = name of the text item
				-- text = text content of the book
				-- isRead = bool for encountering book
				-- dateFound = date that book was discovered
				-- location = area in the world where book is found
			BookObjs[bookCount + 1] = {
				title=ItemTextGetItem(),
				text=bookTextString,
				isRead=true,
				dateFound=date("%m/%d/%y"),
				location="DEFAULT LOCATION"
			}
			bookCount = bookCount + 1
			isTextReady = true
		end
	else
		print("Not a valid book")
	end
	isTextReady = true
end
-------------------------------------------------------------------
-----------------------------------------------------------
------------------------------------------------------
----------------------------------------------







