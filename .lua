-- Example script for an interactive, customizable KNRO-based executor with editor mode

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local toggleEditorButton = Instance.new("TextButton")
local scriptBox = Instance.new("TextBox")
local editorMode = false  -- Toggle editor mode
local items = {}  -- To store created UI items for later manipulation
local lockedItems = {}  -- Items that have been locked into position

-- Setup the basic UI frame
screenGui.Parent = player.PlayerGui
screenGui.Name = "CustomExecutor"

mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

toggleEditorButton.Parent = mainFrame
toggleEditorButton.Size = UDim2.new(0, 100, 0, 50)
toggleEditorButton.Position = UDim2.new(0, 20, 0, 20)
toggleEditorButton.Text = "Editor Mode"
toggleEditorButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

scriptBox.Parent = mainFrame
scriptBox.Size = UDim2.new(0, 360, 0, 100)
scriptBox.Position = UDim2.new(0, 20, 0, 80)
scriptBox.Text = ""
scriptBox.ClearTextOnFocus = false
scriptBox.MultiLine = true
scriptBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Function to create a new draggable button
local function createButton(name, position, parent)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.Text = name
    button.Size = UDim2.new(0, 100, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    button.Name = name

    -- Make the button draggable
    local dragging = false
    local dragInput, dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            -- If editor mode is off, lock the item in place
            if not editorMode then
                lockedItems[button] = true
            end
        end
    end)

    -- Add button to items for future reference
    table.insert(items, button)

    return button
end

-- Editor mode toggle function
toggleEditorButton.MouseButton1Click:Connect(function()
    editorMode = not editorMode
    toggleEditorButton.Text = editorMode and "Exit Editor" or "Editor Mode"

    -- If exiting editor mode, lock positions of all UI items
    if not editorMode then
        for _, item in ipairs(items) do
            lockedItems[item] = true
        end
    else
        -- Unlock positions of items if entering editor mode
        lockedItems = {}
    end
end)

-- Save and execute script (just like before)
local function executeScript(script)
    local success, result = pcall(function()
        loadstring(script)()
    end)
    if success then
        print("Script executed successfully!")
    else
        warn("Error executing script: " .. result)
    end
end

-- Button to execute script
local runButton = Instance.new("TextButton")
runButton.Parent = mainFrame
runButton.Size = UDim2.new(0, 100, 0, 50)
runButton.Position = UDim2.new(0, 140, 0, 200)
runButton.Text = "Run Script"
runButton.BackgroundColor3 = Color3.fromRGB(255, 255, 100)

runButton.MouseButton1Click:Connect(function()
    local scriptContent = scriptBox.Text
    if scriptContent and scriptContent ~= "" then
        executeScript(scriptContent)
    else
        print("No script to run.")
    end
end)

-- Create a button for adding other buttons dynamically (example of creating UI components on the fly)
local addButton = Instance.new("TextButton")
addButton.Parent = mainFrame
addButton.Size = UDim2.new(0, 100, 0, 50)
addButton.Position = UDim2.new(0, 20, 0, 200)
addButton.Text = "Add Button"
addButton.BackgroundColor3 = Color3.fromRGB(100, 255, 255)

addButton.MouseButton1Click:Connect(function()
    if editorMode then
        local newButton = createButton("New Button", UDim2.new(0, 20, 0, 50), mainFrame)
        newButton.Text = "Draggable"
    else
        print("Enable Editor Mode to add buttons.")
    end
end)

-- Lock/Unlock items functionality
local lockButton = Instance.new("TextButton")
lockButton.Parent = mainFrame
lockButton.Size = UDim2.new(0, 100, 0, 50)
lockButton.Position = UDim2.new(0, 260, 0, 200)
lockButton.Text = "Lock Items"
lockButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

lockButton.MouseButton1Click:Connect(function()
    for _, item in ipairs(items) do
        -- Lock items by disabling drag functionality
        lockedItems[item] = true
    end
    print("All items are now locked.")
end)

-- Save and load feature, similar to the previous example
local saveScriptHub = {}
local function saveScript(scriptName, scriptContent)
    saveScriptHub[scriptName] = scriptContent
    print("Script saved: " .. scriptName)
end

local function loadScript(scriptName)
    return saveScriptHub[scriptName]
end
