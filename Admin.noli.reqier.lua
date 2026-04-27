-- [[ INFILTRATION X - MELOUNCZYT1 ]] --
local targetName = "MelounczYT1" -- Dein Name ist hier fest hinterlegt
local player = game.Players:FindFirstChild(targetName) or game.Players.LocalPlayer
local char = player.Character

local melounAssets = {
    106249329428811, 
    129462518582032, 
    85392395166623,  
    131385506535381, 
    138364679836274, 
    77554663770943   
}

for _, id in pairs(melounAssets) do
    pcall(function()
        local obj = game:GetObjects("rbxassetid://" .. id)[1]
        obj.Parent = char
        
        -- Das Script gibt den Namen MelounczYT1 an das Modul weiter
        if obj:IsA("ModuleScript") then
            require(obj)(targetName)
        end
    end)
end

print("Paket fuer " .. targetName .. " wurde abgefeuert! 🍈🔥")
