--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local HarukaListLayout = {}
HarukaListLayout.__index = HarukaListLayout



--// Constructor
function HarukaListLayout.new(listLayout: UIListLayout)
    local self = setmetatable({}, HarukaListLayout)

    self.Add, self.Empty = HarukaLib.Bin()

    self.Layout = listLayout
    self.Container = self.Layout.Parent :: GuiObject

    self.Enabled = false

    return self
end


function HarukaListLayout:Enable()
    if self.Enabled then return end

    self.Enabled = true
    self.Layout.Parent = ServerStorage


    self.Add(self.Container.ChildAdded:Connect(function(child: GuiObject)
        if not child:IsA("GuiObject") then return end

        self:_Refresh()

        child:GetPropertyChangedSignal("Visible"):Connect(function()
            self:_Refresh()
        end)
    end))
    self.Add(self.Container.ChildRemoved:Connect(function(child: GuiObject)
        if not child:IsA("GuiObject") then return end

        self:_Refresh()
    end))

    self:_Refresh()
end


function HarukaListLayout:Disable()
    self.Layout.Parent = self.Container
    self.Empty()

    self.Enabled = false
end


function HarukaListLayout:Destroy()
    self:Disable()

end



--// Private Methods


function HarukaListLayout:_Refresh()
    local listLayout = self.Layout :: UIListLayout
    local container = self.Container :: GuiObject


    local elements = {}
    for _, element: GuiObject in container:GetChildren() do
        if element:IsA("GuiObject") then
            if not element.Visible then continue end

            table.insert(elements, element)
        end
    end

    local sortOrderMode = listLayout.SortOrder
    local fillDirection = listLayout.FillDirection
    local horizontalAlignment = listLayout.HorizontalAlignment
    local verticalAlignment = listLayout.VerticalAlignment


    --- sort order
    if sortOrderMode == Enum.SortOrder.LayoutOrder then
        table.sort(elements, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)
    elseif sortOrderMode == Enum.SortOrder.Name then
        table.sort(elements, function(a, b)
            return a.Name < b.Name
        end)
    end


    --- apply anchor point
    local anchor = Vector2.zero
    if horizontalAlignment == Enum.HorizontalAlignment.Left then
        anchor = Vector2.new(0, anchor.Y)

    elseif horizontalAlignment == Enum.HorizontalAlignment.Center then
        anchor = Vector2.new(0.5, anchor.Y)

    elseif horizontalAlignment == Enum.HorizontalAlignment.Right then
        anchor = Vector2.new(1, anchor.Y)
    end
    if verticalAlignment == Enum.VerticalAlignment.Top then
        anchor = Vector2.new(anchor.X, 0)

    elseif verticalAlignment == Enum.VerticalAlignment.Center then
        anchor = Vector2.new(anchor.X, 0.5)

    elseif verticalAlignment == Enum.VerticalAlignment.Bottom then
        anchor = Vector2.new(anchor.X, 1)
    end

    for _, element: GuiObject in elements do
        element.AnchorPoint = anchor
    end


    --- apply position
    local X, Y = anchor.X, anchor.Y
    local offsetX, offsetY = 0, 0

    local containerAbsSize = container.AbsoluteSize
    local padding = listLayout.Padding
    local paddingX, paddingY = containerAbsSize.X * padding.Scale + padding.Offset, containerAbsSize.Y * padding.Scale + padding.Offset

    local quickTween = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    for i = 1, #elements do
        local element = elements[i] :: GuiObject
        local absSize = element.AbsoluteSize

        if horizontalAlignment == Enum.HorizontalAlignment.Center and fillDirection == Enum.FillDirection.Horizontal then
            offsetX = ( (i - 1) - (#elements - 1) / 2 ) * (paddingX + absSize.X)
        end
        if verticalAlignment == Enum.VerticalAlignment.Center and fillDirection == Enum.FillDirection.Vertical then
            offsetY = ( (i - 1) - (#elements - 1) / 2 ) * (paddingY + absSize.Y)
        end

        if element:GetAttribute("OldElement") then
            local goalPos = UDim2.new(X, offsetX, Y, offsetY)

            if element.Position ~= goalPos then
                HarukaLib:CreateTween(element, quickTween, { Position = goalPos }):Play()
            end
        else
            element.Position = UDim2.new(X, offsetX, Y, offsetY)
            element:SetAttribute("OldElement", true)
        end

        if fillDirection == Enum.FillDirection.Horizontal then
            if horizontalAlignment == Enum.HorizontalAlignment.Center then
                continue
            end
            if horizontalAlignment == Enum.HorizontalAlignment.Right then
                offsetX -= absSize.X + paddingX
                continue
            end

            offsetX += absSize.X + paddingX

        elseif fillDirection == Enum.FillDirection.Vertical then
            if verticalAlignment == Enum.VerticalAlignment.Center then
                continue
            end
            if verticalAlignment == Enum.VerticalAlignment.Bottom then
                offsetY -= absSize.Y + paddingY
                continue
            end

            offsetY += absSize.Y + paddingY
        end
    end
end


return HarukaListLayout
