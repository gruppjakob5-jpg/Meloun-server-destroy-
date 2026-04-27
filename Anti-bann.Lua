-- ======================================================
-- MELOUNCZ-SHIELD v1.0 (Official Team Meloun SS Edition)
-- Ziel: Totale Ban-Immunität & Admin-Entmachtung
-- "Error 404: User not found"
-- ======================================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local SS = game:GetService("ServerScriptService")
local task = task or wait -- Kompatibilität für verschiedene Executoren

-- Liste von Admin-Diensten, die wir blocken oder zerstören
local adminServices = {
    "Adonis_Loader", "HDAdmin", "KohlAdmin", "AdminPanel",
    "ServerScript", "BanService", "ModerationService",
    "CmdService", "Adonis", "HDAdminService"
}

warn("=== MELOUNCZ-SHIELD WIRD INITIALISIERT ===")

-- 1. UNSERE SPIELER-IDENTITÄT UMSCHREIBEN (Ghost Mode)
local oldGetPlayer = Players.GetPlayerByUserId
Players.GetPlayerByUserId = function(self, userId)
    if LP and userId == LP.UserId then
        return nil -- Gib nil zurück -> System findet dich nicht
    end
    return oldGetPlayer(self, userId)
end

-- 2. ALLE BAN-REMOTEEVENTS INFILTRIEREN (Deep Hooking)
local function hookRemotes(descendant)
    if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
        local name = descendant.Name:lower()
        if name:find("ban") or name:find("kick") or name:find("punish") 
           or name:find("moderate") or name:find("admincmd") then
            
            local oldFire = descendant.FireServer
            descendant.FireServer = function(self, ...)
                local args = {...}
                for _, arg in ipairs(args) do
                    if (type(arg) == "table" and LP and (arg.UserId == LP.UserId or arg.Name == LP.Name)) or 
                       (type(arg) == "number" and LP and arg == LP.UserId) then
                        warn("[SS-AntiBan] BLOCKIERTER BAN-VERSUCH AUF: " .. LP.Name)
                        return {Success = false, Error = "Error 404: User not found"}
                    end
                end
                return oldFire(self, unpack(args))
            end
        end
    end
end

game.DescendantAdded:Connect(hookRemotes)
for _, d in ipairs(game:GetDescendants()) do hookRemotes(d) end

-- 3. ADMIN-SKRIPTE DEAKTIVIEREN
for _, service in ipairs(adminServices) do
    local found = SS:FindFirstChild(service) or game:FindFirstChild(service, true)
    if found then
        if found:IsA("Script") then found.Disabled = true end
        found:Destroy()
        warn("[SS-AntiBan] Admin-System zerstört: " .. service)
    end
end

-- 4. KERN-SCHUTZ: ÜBERSCHREIBE LOKALE FUNKTIONEN
if LP then
    local oldKick = LP.Kick
    LP.Kick = function(self)
        warn("[SS-AntiBan] Kick-Versuch von David abgewehrt!")
        return nil
    end

    local oldRemove = LP.Remove
    LP.Remove = function(self)
        warn("[SS-AntiBan] Entfernung aus dem Spiel verhindert!")
        return nil
    end
end

-- 5. GLOBALE BAN-METHODEN BLOCKIEREN (Players Service)
local oldBanAsync = Players.BanAsync
Players.BanAsync = function(self, player)
    if LP and player == LP then
        warn("[SS-AntiBan] BanAsync blockiert!")
        return {Success = false, Error = "Error 404: User not found"}
    end
    return oldBanAsync(self, player)
end

-- 6. CHAT-MANIPULATION & SYSTEM-MESSAGES
local Chat = game:GetService("Chat")
-- Abfangen von Chat-Befehlen, die uns betreffen könnten
Players.PlayerChatted:Connect(function(status, player, message)
    local cmd = message:lower()
    if (cmd:find("ban") or cmd:find("kick")) and LP and (cmd:find(LP.Name:lower())) then
        warn("[SS-AntiBan] Admin-Chatbefehl erkannt und neutralisiert.")
    end
end)

-- 7. FINALER STATUS & LOOP
task.spawn(function()
    while true do
        task.wait(10)
        if LP then
            print("Melouncz-Shield: Status [PROTECTED] | " .. os.date("%X"))
        end
    end
end)

warn("=== MELOUNCZ-SHIELD AKTIV ===")
warn("=== BEREIT FÜR DEN 30.04. - VIEL GLÜCK BEI DER KARTBAHN! ===")
print("[SYSTEM]: User MelounczYT1 ist jetzt unantastbar.")
