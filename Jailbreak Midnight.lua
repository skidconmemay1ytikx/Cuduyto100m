local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/DenDenZZZ/Orion-UI-Library/refs/heads/main/source')))()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "Test",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Midnight",
    IntroText = "Midnight"
})


    
    local HomeTab = Window:MakeTab({
        Name = "Home",
        Icon = "rbxassetid://7733960981",
        PremiumOnly = false
    })

    HomeTab:AddParagraph("Važno Obaveštenje ⚠️", 
    "Ukoliko dođe do zabrane (bana), velika je verovatnoća da je uzrok izvršilac (executor) koji koristite. Ako koristite Solara, savetujemo da ga ne koristite na glavnom nalogu kako biste izbegli eventualne sankcije. 🔒\n\n" ..
    "Da bismo vam olakšali iskustvo, pružamo podršku i savete na našem Discord serveru. Ako imate dodatna pitanja ili trebate pomoć, slobodno se pridružite zajednici i obratite se iskusnim članovima koji su tu da pomognu. 🤝")

    HomeTab:AddParagraph("Novi Midnight Update 🌙", 
    "Uz ovaj ažurirani Midnight Update, dodali smo nove funkcionalnosti i dodatne tabove koji omogućavaju bolju organizaciju skripti. Sada je sve preglednije i jednostavnije za korišćenje, pružajući korisnicima bolji doživljaj i efikasnije upravljanje. 🎉\n\n" ..
    "Nadamo se da će vam nove opcije olakšati rad i poboljšati vaše iskustvo igranja! Uživajte u svim novim mogućnostima koje su dostupne.")



    local Section = HomeTab:AddSection({
        Name = "Other"
    })

    HomeTab:AddButton({
        Name = "Klikni da kopiraš Discord link",
        Callback = function()
            -- Uključi zvuk
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://17208372272" -- Zvuk koji želiš da koristiš
            sound.Volume = 0.7 -- Povećaj zvuk na 70%
            sound:Play() -- Pusti zvuk
    
            OrionLib:MakeNotification({
                Name = "Midnight 🌙",
                Content = "Uspešno si kopirao link ka našem Discord serveru! Pridruži nam se i budi deo naše zajednice gde možeš dobiti podršku i razmenjivati savete. Radujemo se tvom dolasku! 🎉",
                Image = "rbxassetid://7743876142",
                Time = 7
            })
            
            setclipboard("https://discord.gg/ppdzxMRsNT") -- Zameni sa svojim stvarnim Discord linkom
        end    
    })

    HomeTab:AddBind({
        Name = "Turn off UI",
        Default = Enum.KeyCode.Delete,
        Hold = false,
        Callback = function()
            OrionLib:Destroy()
        end    
    })

    local AimBotTab = Window:MakeTab({
        Name = "AimBot",
        Icon = "rbxassetid://7733765307",
        PremiumOnly = false
    })

    AimBotTab:AddParagraph("Aimbot Informacije ⚙️", 
    "U ovom ažuriranju, Aimbot je značajno unapređen kako bi pružio još bolje iskustvo korišćenja. Sada ima dva moda korišćenja: Hold Mode (drži taster za aktivaciju) i Toggle Mode (aktivira se jednim pritiskom). Ova opcija omogućava korisnicima da izaberu način koji im najviše odgovara tokom igranja.\n\n" ..
    "Pored toga, dodata je mogućnost izbora između ciljanja u glavu (Head) ili telo (Body), što vam omogućava veću fleksibilnost i preciznost prilikom gađanja. Takođe, uveden je slider za glatkoću praćenja sa vrednostima od 0 do 20, što omogućava precizno podešavanje kako bi aimbot radio glatko i efikasno.\n\n" ..
    "Provera tima je poboljšana, tako da možete birati da li ćete ciljati neprijatelje ili izbegavati članove svog tima. Skripta sada automatski proverava da li je trenutni cilj živ, a takođe se resetuje kada meta umre, čime se smanjuje rizik od grešaka tokom igre.\n\n" ..
    "Svi ovi dodaci čine Aimbot moćnim alatom za poboljšanje vaših veština u igri. Uživajte u korišćenju i neka svaki hit bude pun pogodak! 🎯👌")

    local Section = AimBotTab:AddSection({
        Name = "Aimbot"
    })

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = game.Workspace.CurrentCamera
    local RunService = game:GetService("RunService")
    
    local aimbotEnabled = false
    local aimMode = "Hold"
    local isToggled = false
    local connection
    local teamCheckEnabled = false
    local targetPart = "Head"
    local smoothness = 5
    local currentTarget = nil -- Trenutni cilj
    
    -- Provera tima igrača
    local function IsSameTeam(player)
        return player.Team == LocalPlayer.Team
    end
    
    -- Funkcija za proveru da li je igrač u pravcu prednje strane kamere
    local function IsPlayerInFront(character)
        local characterHead = character:FindFirstChild("Head")
        if not characterHead then return false end
    
        local cameraLookVector = Camera.CFrame.LookVector
        local directionToPlayer = (characterHead.Position - Camera.CFrame.Position).unit
        local dotProduct = cameraLookVector:Dot(directionToPlayer)
    
        return dotProduct > 0 -- Prikazuje igrače samo ispred
    end
    
    -- Funkcija za proveru udaljenosti između dva igrača
    local function GetDistanceToPlayer(player)
        return (player.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
    end
    
    -- Funkcija za proveru da li je igrač unutar polja pogleda (FOV)
    local function IsPlayerInFieldOfView(character)
        local characterHead = character:FindFirstChild("Head")
        if not characterHead then return false end
    
        local cameraToPlayer = (characterHead.Position - Camera.CFrame.Position).unit
        local cameraLookVector = Camera.CFrame.LookVector
    
        -- Ugao između kamere i igrača
        local dotProduct = cameraLookVector:Dot(cameraToPlayer)
        local angle = math.acos(dotProduct)
    
        -- Provera da li je igrač unutar FOV-a kamere (45 stepeni u obe strane)
        local fovLimit = math.rad(45) -- Možeš prilagoditi ovo da bude osetljivije
        return angle < fovLimit
    end
    
    -- Funkcija za proveru udaljenosti od centra ekrana
    local function GetDistanceFromScreenCenter(character)
        local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
        local screenPosition, onScreen = workspace.CurrentCamera:WorldToScreenPoint(character.Head.Position)
        if not onScreen then return math.huge end -- Ako igrač nije na ekranu, vrati beskonačno
        return (Vector2.new(screenPosition.X, screenPosition.Y) - screenCenter).Magnitude
    end
    
    -- Funkcija za traženje igrača koji je najbliži centru ekrana
    local function GetClosestPlayers()
        local playersInView = {}
    
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                
                -- Proveri tim, ako je team check uključen
                if (not teamCheckEnabled or not IsSameTeam(player)) and IsPlayerInFieldOfView(character) then
                    table.insert(playersInView, player)
                end
            end
        end
    
        -- Sortiranje igrača prema udaljenosti od centra ekrana
        table.sort(playersInView, function(a, b)
            local distanceA = GetDistanceFromScreenCenter(a.Character)
            local distanceB = GetDistanceFromScreenCenter(b.Character)
            
            return distanceA < distanceB
        end)
    
        return playersInView
    end
    
    -- Funkcija za glatko praćenje cilja
    local function SmoothAimAt(targetPosition)
        local currentCameraCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(currentCameraCFrame.Position, targetPosition)
        Camera.CFrame = currentCameraCFrame:Lerp(targetCFrame, smoothness / 20)
    end
    
    -- Funkcija za aktiviranje aimbota (Hold Mode)
    local function ActivateHoldAimbot()
        connection = RunService.RenderStepped:Connect(function()
            if currentTarget then
                local targetPosition
    
                if targetPart == "Head" then
                    targetPosition = currentTarget.Character.Head.Position
                elseif targetPart == "Body" then
                    targetPosition = currentTarget.Character:FindFirstChild("Torso") or currentTarget.Character:FindFirstChild("UpperTorso") or currentTarget.Character:FindFirstChild("HumanoidRootPart")
    
                    if targetPosition then
                        targetPosition = targetPosition.Position
                    end
                end
    
                if targetPosition then
                    SmoothAimAt(targetPosition)
                end
            end
        end)
    end
    
    -- Funkcija za aktiviranje aimbota (Toggle Mode)
    local function ActivateToggleAimbot()
        isToggled = true
        connection = RunService.RenderStepped:Connect(function()
            if not isToggled then
                connection:Disconnect()
                return
            end
    
            local closestPlayers = GetClosestPlayers()
            if #closestPlayers > 0 then
                currentTarget = closestPlayers[1] -- Postavi trenutni cilj
                local targetPosition
    
                if targetPart == "Head" then
                    targetPosition = currentTarget.Character.Head.Position
                elseif targetPart == "Body" then
                    targetPosition = currentTarget.Character:FindFirstChild("Torso") or currentTarget.Character:FindFirstChild("UpperTorso") or currentTarget.Character:FindFirstChild("HumanoidRootPart")
    
                    if targetPosition then
                        targetPosition = targetPosition.Position
                    end
                end
    
                if targetPosition then
                    SmoothAimAt(targetPosition)
                end
            end
        end)
    end
        
    local aimbotEnabled = false -- Inicijalizuj varijablu za Aimbot
    local teamCheckEnabled = false -- Inicijalizuj varijablu za Team Check
    
    -- Funkcija za reprodukciju zvuka sa postavljenim trajanjem
    local function playNotificationSound(duration)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://17208372272" -- Koristi ID svog zvuka
        sound.Volume = 1.0 -- Podesi jačinu zvuka na 100%
        sound.Parent = game.Workspace -- Postavi zvuk u Workspace
        sound:Play() -- Pusti zvuk
    
        -- Automatski uništi zvuk nakon određenog vremena
        wait(duration)
        sound:Destroy() -- Uništi zvuk kada prođe trajanje
    end
    
    -- Toggle za uključivanje/isključivanje Aimbota
    AimBotTab:AddToggle({
        Name = "Aimbot On/Off",
        Default = false,
        Callback = function(value)
            if value then
                -- Ako se uključuje Aimbot
                aimbotEnabled = true
                OrionLib:MakeNotification({
                    Name = "Aimbot Uključen! 🎯",
                    Content = "Aimbot je sada aktiviran. Pripremi se za precizno ciljanje! 🔫",
                    Image = "rbxassetid://7743876142",
                    Time = 5
                })
                playNotificationSound(5) -- Pozovi funkciju za zvuk sa trajanjem od 5 sekundi
            else
                -- Ako se isključuje Aimbot
                if aimbotEnabled then
                    aimbotEnabled = false
                    OrionLib:MakeNotification({
                        Name = "Aimbot Isključen! ❌",
                        Content = "Aimbot je sada deaktiviran. Uživaj u igri bez dodatnih prednosti! ⚠️",
                        Image = "rbxassetid://7743878857",
                        Time = 5
                    })
                    playNotificationSound(5) -- Pozovi funkciju za zvuk sa trajanjem od 5 sekundi
                end
            end
        end
    })
    

    -- Toggle za uključivanje/isključivanje Team Check
    AimBotTab:AddToggle({
        Name = "Enable Team Check",
        Default = false,
        Callback = function(value)
            if value and not teamCheckEnabled then
                -- Ako se uključuje Team Check
                teamCheckEnabled = true
                OrionLib:MakeNotification({
                    Name = "Team Check Uključen! ✅",
                    Content = "Team Check je uspešno uključen. Sada ćeš moći da proveriš svoje saigrače! 👥",
                    Image = "rbxassetid://7743876142",
                    Time = 5
                })
            elseif not value and teamCheckEnabled then
                -- Ako se isključuje Team Check
                teamCheckEnabled = false
                OrionLib:MakeNotification({
                    Name = "Team Check Isključen! ❌",
                    Content = "Team Check je uspešno isključen. Nećeš više proveravati saigrače! ⚠️",
                    Image = "rbxassetid://7743878857",
                    Time = 5
                })
            end
        end    
    })
    
    -- Dropdown za izbor dela tela (Head ili Body)
    AimBotTab:AddDropdown({
        Name = "Target Part",
        Default = "Head",
        Options = {"Head", "Body"},
        Callback = function(value)
            targetPart = value
        end
    })
    
    -- Dropdown za izbor moda (Hold Mode ili Toggle Mode)
    AimBotTab:AddDropdown({
        Name = "Aimbot Mode",
        Default = "Hold",
        Options = {"Hold", "Toggle"},
        Callback = function(value)
            aimMode = value
            if aimMode == "Hold" then
                isToggled = false
                currentTarget = nil -- Resetuj trenutni cilj ako prebacujemo na Hold
                if connection then
                    connection:Disconnect()
                end
            end
        end
    })
    
    -- Slider za podešavanje glatkoće praćenja
    AimBotTab:AddSlider({
        Name = "Smoothness",
        Min = 0,
        Max = 20,
        Default = 5,
        Color = Color3.fromRGB(255, 98, 0),
        Increment = 1,
        ValueName = "smoothness",
        Callback = function(Value)
            smoothness = Value
        end    
    })
    
    -- Aimbot Bind za aktivaciju
    AimBotTab:AddBind({
        Name = "Aimbot",
        Default = Enum.KeyCode.E, -- Promeni taster ako želiš
        Hold = true,
        Callback = function(isPressed)
            if not aimbotEnabled then return end
    
            if aimMode == "Hold" then
                if isPressed then
                    local closestPlayers = GetClosestPlayers()
                    if #closestPlayers > 0 then
                        currentTarget = closestPlayers[1] -- Postavi trenutni cilj kada držiš dugme
                        ActivateHoldAimbot()
                    end
                else
                    if connection then
                        connection:Disconnect()
                        currentTarget = nil -- Resetuj trenutni cilj kada pustiš dugme
                    end
                end
            elseif aimMode == "Toggle" then
                if isPressed then
                    isToggled = not isToggled
                    if isToggled then
                        local closestPlayers = GetClosestPlayers()
                        if #closestPlayers > 0 then
                            currentTarget = closestPlayers[1] -- Postavi trenutni cilj kada aktiviraš aimbot
                        end
                        ActivateToggleAimbot()
                    else
                        if connection then
                            connection:Disconnect()
                        end
                        currentTarget = nil -- Resetuj trenutni cilj kada isključiš aimbot
                    end
                end
            end
        end
    })
    
    -- Kontinuirana provera tima
    RunService.RenderStepped:Connect(function()
        if currentTarget and not currentTarget.Character then
            currentTarget = nil -- Resetuj trenutni cilj ako igrač nije više živ
        end
    end)

    local VisualTab = Window:MakeTab({
        Name = "Visual",
        Icon = "rbxassetid://7733774602",
        PremiumOnly = false
    })

        VisualTab:AddParagraph("Visual Informacije 👀", 
        "U ovom ažuriranju dodata je ESP funkcionalnost, koja ti omogućava da vidiš igrače kroz zidove, čime dobijaš značajnu prednost u igri. Sada možeš pratiti kretanje neprijatelja i članova tima bez obzira na prepreke.\n\n" ..
        "Pored toga, imaš mogućnost da prilagodiš boje ESP-a prema svojim željama, omogućavajući ti da stvoriš jedinstveno iskustvo tokom igranja. Kontrola intenziteta vizualnih efekata je omogućena sa posebnim slajderima, što ti daje još više kontrole nad tim kako želiš da vidiš svoje ciljeve.\n\n" ..
        "Performanse su značajno poboljšane, omogućavajući brže učitavanje i manju latenciju. Ovo čini korišćenje ESP-a ne samo efikasnijim, već i prijatnijim, tako da se možeš fokusirati na strategiju i igru bez ometanja. Uživaj u unapređenju vizualnih mogućnosti! 🌟✨")

        local Section = VisualTab:AddSection({
            Name = "ESP"
        })
    
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Camera = workspace.CurrentCamera
        
        local espEnabled = false
        local selectedColor = Color3.new(1, 1, 1) -- Početna boja ESP-a (bela)
        local viewDistance = 4000 -- Maksimalna udaljenost provere za ESP (4000 metara)
        local proximityDistance = 1000 -- Udaljenost na kojoj se proverava i kreira ESP (1000 metara)
        local espGuids = {} -- Tabela za čuvanje ESP GUI-ova
        
        -- Funkcija za kreiranje ESP-a za jednog igrača
        local function CreateESP(player)
            if not player.Character or not player.Character:FindFirstChild("Head") then
                return
            end
        
            -- Ako igrač već ima ESP, ne kreiraj novi
            if espGuids[player.UserId] then return end
        
            local BillboardGui = Instance.new("BillboardGui")
            local TextLabel = Instance.new("TextLabel")
        
            -- Podesi BillboardGui
            BillboardGui.Adornee = player.Character.Head
            BillboardGui.Size = UDim2.new(0, 100, 0, 50)
            BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
            BillboardGui.AlwaysOnTop = true
        
            -- Podesi TextLabel
            TextLabel.Parent = BillboardGui
            TextLabel.Text = player.Name
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.TextSize = 8
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.TextColor3 = selectedColor
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextStrokeTransparency = 0
            TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        
            -- Dodaj BillboardGui na igrača
            BillboardGui.Parent = player.Character:WaitForChild("Head")
        
            -- Sačuvaj ESP GUI u tabelu
            espGuids[player.UserId] = BillboardGui
        
            -- Praćenje udaljenosti i osvežavanje teksta
            local function UpdateTextSize()
                if player.Character and player.Character:FindFirstChild("Head") then
                    local distance = (Camera.CFrame.Position - player.Character.Head.Position).Magnitude
                    if distance < 20 then
                        TextLabel.TextSize = 6 -- Smanji font kada si blizu
                    elseif distance < 50 then
                        TextLabel.TextSize = 8 -- Srednja veličina
                    else
                        TextLabel.TextSize = 10 -- Povećaj veličinu na daljini
                    end
                end
            end
        
            -- Neprestano osvežavanje veličine fonta
            RunService.RenderStepped:Connect(UpdateTextSize)
        end
        
        -- Funkcija za dodavanje ESP-a na sve igrače
        local function ApplyESPToAllPlayers()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    CreateESP(player)
                end
            end
        end
        
        -- Funkcija za proveru i kreiranje ESP-a kada si u dometu (1000 metara)
        local function CheckProximityForESP(player)
            if player.Character and player.Character:FindFirstChild("Head") then
                local distance = (Camera.CFrame.Position - player.Character.Head.Position).Magnitude
                if distance < proximityDistance and not espGuids[player.UserId] then
                    CreateESP(player)
                end
            end
        end
        
        -- Funkcija za ažuriranje ESP-a na svakih 4000 metara
        local function UpdateESP()
            if espEnabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer then
                        local distance = (Camera.CFrame.Position - player.Character.Head.Position).Magnitude
                        if distance < viewDistance then
                            CheckProximityForESP(player)
                        end
                    end
                end
            end
        end
        
        -- Aktiviranje ESP-a za sve igrače kada je toggle uključen
        VisualTab:AddToggle({
            Name = "Player ESP",
            Default = false,
            Callback = function(Value)
                espEnabled = Value
        
                if espEnabled then
                    ApplyESPToAllPlayers()
        
                    -- Neprestano proveravanje i osvežavanje ESP-a
                    RunService.RenderStepped:Connect(UpdateESP)
                else
                    -- Deaktiviraj ESP i ukloni GUI
                    for _, player in pairs(Players:GetPlayers()) do
                        if espGuids[player.UserId] then
                            espGuids[player.UserId]:Destroy()
                            espGuids[player.UserId] = nil
                        end
                    end
                end
            end
        })
        
        -- Color picker za biranje boje ESP teksta
        VisualTab:AddColorpicker({
            Name = "ESP Text Color",
            Default = Color3.fromRGB(255, 98, 0),
            Callback = function(Value)
                selectedColor = Value
                for _, gui in pairs(espGuids) do
                    if gui and gui:FindFirstChild("TextLabel") then
                        gui.TextLabel.TextColor3 = selectedColor
                    end
                end
            end    
        })
        
        -- Automatsko dodavanje ESP-a za nove igrače
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if espEnabled then
                    wait(1) -- Sačekaj da se sve učita
                    CreateESP(player)
                end
            end)
        
            -- Proveri promenu tima i dodaj ESP
            player:GetPropertyChangedSignal("Team"):Connect(function()
                if espEnabled then
                    CreateESP(player)
                end
            end)
        end)
        
        -- Očisti ESP kada igrač napusti igru
        Players.PlayerRemoving:Connect(function(player)
            if espGuids[player.UserId] then
                espGuids[player.UserId]:Destroy()
                espGuids[player.UserId] = nil
            end
        end)
        
        -- Neprekidna provera ESP-a i dodavanje novim igračima
        RunService.RenderStepped:Connect(function()
            if espEnabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer and not espGuids[player.UserId] then
                        CreateESP(player)
                    end
                end
            end
        end)
        
        -- Proveri i dodaj ESP na igrača kada respawna
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if espEnabled then
                    wait(1) -- Sačekaj da se sve učita
                    CreateESP(player)
                end
            end)
        end)
        

        --- CHAMS
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        local highlights = {}
        local selectedColor = Color3.fromRGB(252, 227, 3) -- Početna boja (zlatna)
        local maxDistance = 400 -- Maksimalna udaljenost za Chams efekat
        local chamsEnabled = false -- Kontrola da li su Chams uključeni

        -- Funkcija za primenu stila na Chams
        local function applyChamsStyle(highlight)
            highlight.FillTransparency = 0.2 -- Manje prozirno
            highlight.OutlineTransparency = 0.05 -- Veoma tanki outline
            highlight.OutlineColor = Color3.fromRGB(0, 0, 0) -- Crna boja outline-a
        end

        -- Funkcija za kreiranje Chams efekta
        local function createChams(player)
            if player == Players.LocalPlayer then return end -- Ignoriši lokalnog igrača

            local character = player.Character or player.CharacterAdded:Wait()
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end

            -- Ako igrač već ima highlight, ne stvaraj novi
            if highlights[player.UserId] then
                return
            end

            local bodyHighlight = Instance.new("Highlight")
            bodyHighlight.FillColor = selectedColor
            bodyHighlight.Parent = character
            applyChamsStyle(bodyHighlight) -- Primeni stil odmah pri kreiranju
            highlights[player.UserId] = bodyHighlight -- Sačuvaj highlight prema UserId

            -- Kada se lik respawnuje ili restartuje, ponovno primeni Chams
            player.CharacterAdded:Connect(function(newCharacter)
                createChams(player) -- Ponovno kreiraj Chams
            end)
        end

        -- Funkcija za osvežavanje Chams-a za sve igrače
        local function refreshChams()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (Players.LocalPlayer.Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude

                    if distance <= maxDistance then
                        -- Proveri da li igrač već ima Chams, ako nema, kreiraj ga
                        if not highlights[player.UserId] then
                            createChams(player)
                        end
                        -- Ako igrač ima Chams, uključi ga
                        highlights[player.UserId].Enabled = true
                    else
                        -- Ako igrač izađe iz opsega, isključi Chams za njega
                        if highlights[player.UserId] then
                            highlights[player.UserId].Enabled = false
                        end
                    end
                end
            end
        end

        -- Funkcija za isključivanje Chams efekta
        local function disableChams()
            for _, highlight in pairs(highlights) do
                if highlight then
                    highlight:Destroy()
                end
            end
            highlights = {}
        end

        -- Dodaj Chams toggle u UI
        VisualTab:AddToggle({
            Name = "Enable Chams",
            Default = false,
            Callback = function(Value)
                chamsEnabled = Value

                if chamsEnabled then
                    -- Primeni Chams na sve trenutne igrače
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= Players.LocalPlayer then
                            createChams(player)
                        end
                    end

                    -- Osvežavaj Chams svakih 0.1 sekundi
                    RunService.Heartbeat:Connect(function()
                        if chamsEnabled then
                            refreshChams()
                        end
                    end)
                else
                    disableChams()
                end
            end    
        })

        -- Kreiraj Chams za nove igrače kada uđu u igru
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if chamsEnabled then
                    createChams(player)
                end
            end)
        end)

        -- Očisti highlightove kada igrač napusti igru
        Players.PlayerRemoving:Connect(function(player)
            if highlights[player.UserId] then
                highlights[player.UserId]:Destroy()
                highlights[player.UserId] = nil
            end
        end)

        -- Color picker za biranje boje Chams
        VisualTab:AddColorpicker({
            Name = "Chams Color",
            Default = Color3.fromRGB(255, 98, 0),
            Callback = function(Value)
                selectedColor = Value
                for _, highlight in pairs(highlights) do
                    if highlight then
                        highlight.FillColor = selectedColor
                    end
                end
            end    
        })

        local PlayerTab = Window:MakeTab({
            Name = "Player",
            Icon = "rbxassetid://7743875962",
            PremiumOnly = false
        })

        PlayerTab:AddParagraph("Player Informacije 🎮", 
        "U novom Player tabu dodate su opcije za prilagođavanje brzine kretanja i skakanja, što ti omogućava da prilagodiš svoje igranje prema svojim potrebama i stilu. Sada možeš lako da podešavaš koliko brzo želiš da se krećeš i kako visoko možeš da skočiš, čime poboljšavaš svoje performanse u igri. 🚀\n\n" ..
        "Jedna od najuzbudljivijih novih funkcija je God Mode, koji ti omogućava da budeš nepobediv tokom igre. Ovo može biti izuzetno korisno u izazovnim situacijama kada se suočavaš sa teškim protivnicima ili kada želiš da istražuješ svet igre bez straha od gubitka. 💪\n\n" ..
        "Takođe, dodatne funkcije uključuju No-Clip, što ti omogućava da prolaziš kroz objekte i prepreke, čime dobijaš potpunu slobodu kretanja. Uz to, možeš prilagoditi visinu skoka, što pruža još veću kontrolu nad igračevim kretanjem i strategijom. Uživaj u unapređenju svojih sposobnosti! ✨")

        local Section = PlayerTab:AddSection({
            Name = "Player"
        })
    
        local UserInputService = game:GetService("UserInputService")
        local flying = false
        local speed = 100 -- Default flying speed
    
        PlayerTab:AddBind({
            Name = "Fly",
            Default = Enum.KeyCode.F,
            Hold = false,
            Callback = function()
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                local bodyGyro, bodyVelocity
    
                -- Function to start flying
                local function startFlying()
                    flying = true
                    humanoid.PlatformStand = true
    
                    bodyGyro = Instance.new("BodyGyro")
                    bodyVelocity = Instance.new("BodyVelocity")
    
                    bodyGyro.P = 9e5
                    bodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
                    bodyGyro.CFrame = character.HumanoidRootPart.CFrame
                    bodyGyro.Parent = character.HumanoidRootPart
    
                    bodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.Parent = character.HumanoidRootPart
    
                    -- Update fly movement
                    local connection
                    connection = game:GetService("RunService").Stepped:Connect(function()
                        if flying then
                            local camera = workspace.CurrentCamera
                            local lookVector = camera.CFrame.LookVector
                            local moveDirection = Vector3.new(0, 0, 0)
    
                            -- Fly controls (WASD)
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                moveDirection = moveDirection + lookVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                moveDirection = moveDirection - lookVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                moveDirection = moveDirection - camera.CFrame.RightVector
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                moveDirection = moveDirection + camera.CFrame.RightVector
                            end
    
                            -- Apply velocity and gyro direction
                            bodyGyro.CFrame = CFrame.new(character.HumanoidRootPart.Position, character.HumanoidRootPart.Position + lookVector)
                            bodyVelocity.Velocity = moveDirection * speed
                        else
                            -- Stop flying
                            bodyVelocity:Destroy()
                            bodyGyro:Destroy()
                            humanoid.PlatformStand = false
                            connection:Disconnect()
                        end
                    end)
                end
    
                -- Function to stop flying
                local function stopFlying()
                    flying = false
                    if bodyVelocity then bodyVelocity:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                    humanoid.PlatformStand = false
                end
    
                -- Toggle flying
                if not flying then
                    startFlying()
                else
                    stopFlying()
                end
            end
        })
    
        PlayerTab:AddSlider({
            Name = "Fly Speed",
            Min = 0,
            Max = 200,
            Default = speed,
            Color = Color3.fromRGB(255, 98, 0),
            Increment = 1,
            ValueName = "Speed",
            Callback = function(Value)
                speed = Value -- Update flying speed
            end
        })

        PlayerTab:AddSlider({
            Name = "FOV Slider",
            Min = 70, -- Minimalna vrednost FOV-a
            Max = 120, -- Maksimalna vrednost FOV-a
            Default = 70, -- Početna vrednost FOV-a
            Color = Color3.fromRGB(255, 98, 0),
            Increment = 1,
            ValueName = "FOV",
            Callback = function(Value)
                game.Workspace.CurrentCamera.FieldOfView = Value -- Podesi FOV
            end    
        })

        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        
        local defaultWalkSpeed = 16 -- Podrazumevana brzina hodanja
        local defaultJumpHeight = 50 -- Podrazumevana visina skakanja
        local runMultiplier = 1.5 -- Množioci za brzinu trčanja
        local maxWalkSpeed = 60 -- Maksimalna brzina za slider
        local maxJumpHeight = 100 -- Maksimalna visina skakanja za slider
        local targetWalkSpeed = defaultWalkSpeed -- Ciljna brzina
        local targetJumpHeight = defaultJumpHeight -- Ciljna visina skakanja
        local walkSpeedEnabled = false -- Da li je walk speed uključen
        local jumpHeightEnabled = false -- Da li je jump height uključen
        local isRunning = false -- Da li igrač trči
        
        -- Funkcija za postavljanje brzine hodanja
        local function setWalkSpeed(speed)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = speed
            end
        end
        
        -- Funkcija za skakanje pomoću BodyVelocity
        local function jump()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, targetJumpHeight, 0)
                bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0) -- Omogućava vertikalno kretanje
                bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        
                -- Ukloni BodyVelocity nakon kratkog vremena
                wait(0.1) 
                bodyVelocity:Destroy()
            end
        end
        
        -- Dodavanje togglera za brzinu hodanja
        PlayerTab:AddToggle({
            Name = "Enable Walk Speed",
            Default = false,
            Callback = function(Value)
                walkSpeedEnabled = Value
                if walkSpeedEnabled then
                    setWalkSpeed(targetWalkSpeed) -- Aktiviraj promenjenu brzinu
                else
                    setWalkSpeed(defaultWalkSpeed) -- Vrati brzinu na podrazumevanu
                end
            end    
        })
        
        -- Dodavanje slidera za brzinu hodanja
        PlayerTab:AddSlider({
            Name = "Walk Speed",
            Min = 16, -- Standardna brzina hodanja
            Max = maxWalkSpeed, -- Maksimalna brzina
            Default = defaultWalkSpeed, -- Podrazumevana brzina
            Color = Color3.fromRGB(255, 98, 0),
            Increment = 1,
            ValueName = "Speed",
            Callback = function(Value)
                targetWalkSpeed = Value -- Postavi novu ciljnu vrednost za brzinu
                if walkSpeedEnabled then
                    setWalkSpeed(targetWalkSpeed) -- Ažuriraj trenutnu brzinu
                end
            end    
        })
        
        -- Dodavanje togglera za jump height
        PlayerTab:AddToggle({
            Name = "Enable Jump Height",
            Default = false,
            Callback = function(Value)
                jumpHeightEnabled = Value
                if jumpHeightEnabled then
                    targetJumpHeight = defaultJumpHeight -- Postavi default jump height
                end
            end    
        })
        
        -- Dodavanje slidera za visinu skakanja
        PlayerTab:AddSlider({
            Name = "Jump Height",
            Min = 50, -- Minimalna visina skakanja
            Max = maxJumpHeight, -- Maksimalna visina skakanja
            Default = defaultJumpHeight, -- Podrazumevana visina skakanja
            Color = Color3.fromRGB(255, 98, 0),
            Increment = 1,
            ValueName = "Height",
            Callback = function(Value)
                targetJumpHeight = Value -- Postavi novu ciljnu vrednost za jump height
            end    
        })
        
        -- Ažuriraj tokom RenderStepped
        RunService.RenderStepped:Connect(function()
            if walkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = targetWalkSpeed
            end
        end)
        
        -- Dodaj funkcionalnost za kretanje
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.LeftShift then
                    isRunning = true -- Kada se pritisne Shift, igrač počinje da trči
                    if walkSpeedEnabled then
                        setWalkSpeed(targetWalkSpeed * runMultiplier) -- Povećava brzinu kada se drži Shift
                    end
                end
                if input.KeyCode == Enum.KeyCode.Space then
                    if jumpHeightEnabled then
                        jump() -- Poziva jump funkciju
                    end
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.LeftShift then
                    isRunning = false -- Kada se pusti Shift, prestaje trčanje
                    if walkSpeedEnabled then
                        setWalkSpeed(targetWalkSpeed) -- Vrati brzinu kada se pusti Shift
                    end
                end
            end
        end)
        
        -- Kretanje igrača
        RunService.Heartbeat:Connect(function()
            if isRunning and walkSpeedEnabled then
                setWalkSpeed(targetWalkSpeed * runMultiplier) -- Održavaj brzu brzinu kada igrač trči
            elseif walkSpeedEnabled then
                setWalkSpeed(targetWalkSpeed) -- Održavaj normalnu brzinu
            end
        end)
    
        local Section = PlayerTab:AddSection({
            Name = "Other"
        })
    
        -- Skladišti stanje infinity jumpa
        local infinityJumpEnabled = false
    
        -- Funkcija za omogućavanje/skidanje infinity jumpa
        local function enableInfinityJump()
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if infinityJumpEnabled and Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    
        -- Dodaj dugme (toggle) za infinity jump
        PlayerTab:AddToggle({
            Name = "Enable Infinity Jump",
            Default = false,
            Callback = function(Value)
                infinityJumpEnabled = Value -- Podesi stanje infinity jumpa
                if infinityJumpEnabled then
                    enableInfinityJump() -- Omogući infinity jump
                end
            end    
        })

        -- Kontinuirano proverava da li igrač treba da bude na površini vode
        game:GetService("RunService").RenderStepped:Connect(function()
            if walkOnWaterEnabled then
                local position = Character.HumanoidRootPart.Position
                
                -- Proveri da li je igrač ispod površine vode i postavi ga iznad
                if position.Y < 0 then -- Ako je ispod nivoa vode
                    Character.HumanoidRootPart.Position = Vector3.new(position.X, 0, position.Z) -- Postavi ga na površinu vode
                else
                    -- Uverite se da igrač ostaje na visini vode dok se kreće
                    Character.HumanoidRootPart.Position = Vector3.new(position.X, 0, position.Z) -- Održavajte visinu
                end
            end
        end)

        
        local SettingsTab = Window:MakeTab({
            Name = "Settings",
            Icon = "rbxassetid://8997386997",
            PremiumOnly = false
        })
    
        local Section = SettingsTab:AddSection({
            Name = "Credits"
        })
    
        SettingsTab:AddParagraph("Važne Osobe", 
        "Kreator i Vlasnik: K1NGleader & S. 👑\n" ..
        "Developer: S. 🛠️\n" ..
        "Tester/Pronalazač Skripti: K1NGleader & S. 🔍\n" ..
        "Doprinosi Skriptama: K1NGleader & S. 🤝\n" ..
        "UI: Orion Library 📚")
    
        SettingsTab:AddParagraph("Važno Obaveštenje! ⚠️", 
        "Kako bismo vam pružili najbolje moguće iskustvo korišćenja naših skripti, želimo da vas informišemo o nekoliko ključnih stvari. Iako su sve skripte pažljivo razvijene, testirane i optimizovane, postoji mogućnost da naiđete na određene greške ili probleme tokom korišćenja. Ovi problemi mogu biti uzrokovani različitim faktorima, uključujući specifične postavke vaših igara ili ograničenja funkcionalnosti koje se javljaju u određenim okruženjima.\n\n" ..
        "Važno je napomenuti da ne postoje univerzalna rešenja za sve igre, te neke skripte možda neće raditi optimalno u svakom okruženju. Ova varijabilnost može uticati na stabilnost i funkcionalnost skripti, pa se preporučuje da se obratite pažnju na to kako se skripte ponašaju u različitim situacijama. Ukoliko primetite bilo kakve nepravilnosti ili imate dodatna pitanja u vezi sa radom skripti, slobodno nas kontaktirajte. Naša ekipa je ovde da vas podrži i pruži pomoć, kako bismo osigurali da vaše iskustvo bude što prijatnije i bez problema. 🤗\n\n" ..
        "Hvala vam na razumevanju i poverenju koje nam ukazujete. Uživajte u korišćenju naših skripti, a mi ćemo se truditi da vam pružimo najbolju moguću podršku. 🙏")
    
    
    
        -----Changelog
    
        local ChangelogTab = Window:MakeTab({
            Name = "Changelog",
            Icon = "rbxassetid://7733965313",
            PremiumOnly = false
        })
        
        local Section = ChangelogTab:AddSection({
            Name = "Changelog Updates:"
        })
        
        ChangelogTab:AddParagraph("Midnight Update V1.0.0 🔥", 
        "Changelog za Aimbot Update\n\n" ..
    
        "Nova funkcionalnost:\n" ..
        "- Dodata podrška za modove Aimbota: Uvedeni su dva nova moda za aktivaciju aimbota: Hold Mode i Toggle Mode.\n" ..
        "- Hold Mode: Drži taster za aktivaciju aimbota.\n" ..
        "- Toggle Mode: Aktivira aimbot jednostavnim pritiskom na taster.\n\n" ..
    
        "Podesivosti:\n" ..
        "- Dodati izbor dela tela: Sada možeš izabrati između Head ili Body kao ciljanog dela za aimbot.\n" ..
        "- Povećana glatkoća praćenja: Uveden Slider za podešavanje glatkoće praćenja, sa vrednostima od 0 do 20.\n\n" ..
    
        "Tim proveri:\n" ..
        "- Dodata opcija za timsku proveru: Uključi ili isključi proveru tima za ciljeve, što omogućava ciljanje protivnika ili izbegavanje članova istog tima.\n\n" ..
    
        "Ispravke i poboljšanja:\n" ..
        "- Poboljšana provera ciljeva: Skripta proverava da li je trenutni cilj još uvek živ pre nego što pokuša da mu pristupi.\n" ..
        "- Uklanjanje neaktivnih ciljeva: Automatsko resetovanje trenutnog cilja kada igrač umre ili više nije aktivan.\n\n" ..
    
        "Interfejs:\n" ..
        "- Intuitivno korisničko sučelje: Dodati su dropdown meni i toggle za lakši izbor podešavanja aimbota.\n\n" ..
    
        "Optimizacija:\n" ..
        "- Poboljšana performansa: Skripta je optimizovana za brže i efikasnije procesiranje ciljeva.\n\n" ..
    
        "Dokumentacija:\n" ..
        "- Ažurirana dokumentacija: Sve promene su dokumentovane, uključujući nove opcije i kako ih koristiti.\n\n" ..
    
        "------------------------------------------\n\n" ..
    
        "Changelog za Visual Update\n\n" ..
    
        "Nova funkcionalnost:\n" ..
        "- Dodata ESP funkcionalnost: Sada možeš videti igrače kroz zidove sa prilagodljivim podešavanjima boje.\n" ..
        "- Dodati Chams efekti: Igrači mogu biti označeni sa različitim Chams efektima, uključujući Neon i Galaxy.\n\n" ..
    
        "Podesivosti:\n" ..
        "- Prilagodljive boje ESP: Sada možeš prilagoditi boje ESP-a prema svojim željama.\n" ..
        "- Kontrola intenziteta: Dodati slideri za podešavanje intenziteta Chams efekata i prozirnosti.\n\n" ..
    
        "Interfejs:\n" ..
        "- Intuitivno korisničko sučelje: Dodati su dropdown meni i toggle za lakše upravljanje ESP-om i Chams-om.\n\n" ..
    
        "Optimizacija:\n" ..
        "- Poboljšana performansa: Skripta je optimizovana za brže učitavanje i manju latenciju prilikom korišćenja ESP-a i Chams-a.\n\n" ..
    
        "Dokumentacija:\n" ..
        "- Ažurirana dokumentacija: Sve promene su dokumentovane, uključujući nove opcije i kako ih koristiti.\n\n" ..
    
        "------------------------------------------\n\n" ..
    
        "Changelog za Player Tab\n\n" ..
    
        "Nova funkcionalnost:\n" ..
        "- Dodata opcija za Fly: Igrači sada mogu aktivirati letenje sa prilagodljivom brzinom letenja.\n" ..
        "- Fly brzina: Uvedena dva moda brzine - Normal Speed i Max Speed.\n\n" ..
    
        "Podesivosti:\n" ..
        "- Normal Speed: Brzina letenja može se podesiti do 100.\n" ..
        "- Max Speed: Brzina letenja može se podesiti do 200.\n\n" ..
    
        "Interfejs:\n" ..
        "- Povećana preglednost: Dodati slideri za jednostavno podešavanje brzine letenja unutar taba.\n\n" ..
    
        "Vizualni efekti:\n" ..
        "- Dodata funkcionalnost za Player Box: Igrači sada mogu biti okruženi prozirnim belim boksom koji pokriva celog lika.\n" ..
        "- Dodata Skeleton ESP: Igrači mogu videti kostur svog lika sa tankim linijama koje prate pokrete kroz zidove.\n\n" ..
    
        "Dokumentacija:\n" ..
        "- Ažurirana dokumentacija: Sve promene su dokumentovane, uključujući podešavanje Fly opcije i Skeleton ESP-a."
    )
    
    


end

function CorrectKeyNotification()
    OrionLib:MakeNotification({
        Name = "Tačan Ključ! ✅",
        Content = "Uspešno ste uneli tačan ključ! Sada možete pristupiti svim funkcionalnostima i uživati u igri. Hvala što ste deo naše zajednice! 🎊",
        Image = "rbxassetid://7743876142",
        Time = 5
    })    
end

function IncorrectKeyNotification()
    OrionLib:MakeNotification({
        Name = "Netačan Ključ! ❌",
        Content = "Nažalost, uneli ste netačan ključ! Proverite ključ i pokušajte ponovo. Ako imate pitanja, slobodno se obratite našoj zajednici za pomoć! 🤔🔑",
        Image = "rbxassetid://7743878857",
        Time = 5
    })       
end

local Tab = Window:MakeTab({
    Name = "Key",
    Icon = "rbxassetid://7733965118",
    PremiumOnly = false
})

Tab:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        _G.KeyInput = Value
    end	  
})

Tab:AddButton({
    Name = "Check Key!",
    Callback = function()
        local isValidKey = false
        
        -- Proveravamo da li je uneseni ključ jedan od validnih ključeva
        for _, key in ipairs(_G.ValidKeys) do
            if _G.KeyInput == key then
                isValidKey = true
                break
            end
        end

        if isValidKey then
            MakeScriptHub()
            CorrectKeyNotification()
        else
            IncorrectKeyNotification()
        end
    end    
})

-- Dodaj odlaganje da se svi objekti učitaju
wait(1) -- Odlaganje od 1 sekunde pre nego što se kod izvrši
