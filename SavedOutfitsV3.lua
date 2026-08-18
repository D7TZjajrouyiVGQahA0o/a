script = realcso_script
local LocalPlayer = game.Players.LocalPlayer;
local Outfits = viewedfits
local CatalogModule = require(game.ReplicatedStorage.CatalogModule);
local ItemDetailsFetcher = require(game.ReplicatedStorage.CatalogModule.ItemDetailsFetcher);
local AvatarViewportFactory = require(game.ReplicatedStorage.CatalogModule.AvatarViewportFactory);
local NumbersUtil = require(game.ReplicatedStorage.Modules.Util.NumbersUtil);
local AssetButtonFactory = require(game.ReplicatedStorage.CatalogModule.AssetButtonFactory);
local SavedOutfitsRemote = game.ReplicatedStorage.Events:WaitForChild("SavedOutfitsRemote");
local u1 = "All";
local u2 = false;
local CollectionService = game:GetService("CollectionService");
local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
local TextService = game:GetService("TextService");
game:GetService("HttpService");
local RunService = game:GetService("RunService");
local OpenSavedOutfits = LocalPlayer.PlayerGui:WaitForChild("Buttons"):WaitForChild("Right"):WaitForChild("OpenSavedOutfits");
local Holder = script.Parent:WaitForChild("Holder");
local AvatarPreview = Holder:WaitForChild("AvatarPreview");
local EquippedItems = Holder:WaitForChild("EquippedItems");
local ShortcutMenu = Holder:WaitForChild("ShortcutMenu");
local CreateNewOutfit = Holder:WaitForChild("CreateNewOutfit");
local OutfitFolderSelector = Holder:WaitForChild("OutfitFolderSelector");
local FolderConfigs = Holder:WaitForChild("FolderConfigs");
local Main = Holder:WaitForChild("Main");
local Outfits2 = Main:WaitForChild("Outfits");
local LoadingOverlay = Main:WaitForChild("LoadingOverlay");
local ViewOutfitDetails2 = Main:WaitForChild("ViewOutfitDetails");
local OutfitDetails = ViewOutfitDetails2:WaitForChild("List"):WaitForChild("OutfitDetails");
local SearchBox = Outfits2:WaitForChild("SearchBox");
local FoldersList = Outfits2:WaitForChild("FoldersList");
local List = Outfits2:WaitForChild("List");
local SortFilterSelection = Outfits2:WaitForChild("SortFilterSelection");
local BottomLeftButtons = Outfits2:WaitForChild("BottomLeftButtons");
local BottomRightButtons = Outfits2:WaitForChild("BottomRightButtons");
local CreateNew = List:WaitForChild("CreateNew");
local u3 = {};

function ClearViewOutfitDetailsFrame()
    -- upvalues: u3 (ref)
    for _, v in pairs(u3) do
        v:Disconnect();
    end;

    u3 = {};
end;

function ExitOutfitDetailsScreen()
    -- upvalues: ViewOutfitDetails2 (copy)
    ViewOutfitDetails2.Visible = false;
    ClearViewOutfitDetailsFrame();
end;

function ViewOutfitDetails(u4)
    -- upvalues: ViewOutfitDetails2 (copy), CatalogModule (copy), OutfitDetails (copy), LocalPlayer (copy), AvatarViewportFactory (copy), ItemDetailsFetcher (copy), AssetButtonFactory (copy), NumbersUtil (copy), Holder (copy), u3 (ref), SavedOutfitsRemote (copy), OutfitFolderSelector (copy)
    ClearViewOutfitDetailsFrame();
    ViewOutfitDetails2.Visible = true;
    ViewOutfitDetails2.List.CanvasPosition = Vector2.new(0, 0);
    local u5 = u4:FindFirstChildOfClass("HumanoidDescription");
    CatalogModule:ValidateHumanDesc(u5);
    OutfitDetails.Info.OutfitName.Text = u4:GetAttribute("OutfitName");
    OutfitDetails.Info.Creator.TextLabel.Text = LocalPlayer.Name;
    OutfitDetails.Info.Creator.ImageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150";

    local function UpdateBeneathOutfitDetailsText() -- Line: 88
        -- upvalues: u4 (copy), ViewOutfitDetails2 (ref)
        local _ = os.time() - (u4:GetAttribute("Created") or 0);
        local v6 = u4:FindFirstChild("Configs") and (u4.Configs:GetAttribute("OutfitFolders") and string.split(u4.Configs:GetAttribute("OutfitFolders"), ",")) or { "None" };
        ViewOutfitDetails2.List.BeneathOutfitDetails.Text = "📆 Created on " .. os.date("%d %b %Y", u4:GetAttribute("Created") or 0) .. "\n" .. "📁 Folders: " .. table.concat(v6, ", ");
    end;

    UpdateBeneathOutfitDetailsText();
    OutfitDetails.ViewportHolder.Holder:ClearAllChildren();
    task.defer(function() -- Line: 98
        -- upvalues: AvatarViewportFactory (ref), u5 (copy), u4 (copy), OutfitDetails (ref)
        AvatarViewportFactory:CreateDraggableVPFNPC(u5, Enum.HumanoidRigType[u4:GetAttribute("RigType") or "R15"]).Parent = OutfitDetails.ViewportHolder.Holder;
    end);

    for _, child in pairs(OutfitDetails.Info.ItemsList:GetChildren()) do
        if child:IsA("GuiButton") then
            child:Destroy();
        end;
    end;

    OutfitDetails.Info.Price.Amount.Text = "";
    task.defer(function() -- Line: 116
        -- upvalues: CatalogModule (ref), u5 (copy), ItemDetailsFetcher (ref), AssetButtonFactory (ref), OutfitDetails (ref), NumbersUtil (ref)
        local v7 = ItemDetailsFetcher:GetBatchItemDetails(CatalogModule:GetEquippedAssetIds(u5), Enum.AvatarItemType.Asset) or {};
        local v8 = 0;
        local v9 = {};

        for _, v in pairs(v7) do
            v8 = v8 + (CatalogModule:GetPriceFromItemDetails(v) or 0);
            local v10 = AssetButtonFactory:CreateAsset(v, true);
            v10.LayoutOrder = CatalogModule:GetLayoutOrderFromAssetType(v.AssetType);

            if v.IsOffSale then
                local v11 = ItemDetailsFetcher:GetBundleIdFromAssetId(v.Id);

                if v11 then
                    local v12 = ItemDetailsFetcher:GetItemDetails(v11, Enum.AvatarItemType.Bundle, 1);

                    if v12 then
                        AssetButtonFactory:UpdateAssetButtonPricing(v10, v12, "*");

                        if v9[v11] == nil and v12.Price then
                            v9[v11] = true;
                            v8 = v8 + (v12.LowestPrice or (v12.Price or 0));
                        end;
                    end;
                end;
            end;

            v10.Parent = OutfitDetails.Info.ItemsList;
        end;

        OutfitDetails.Info.Price.Amount.Text = NumbersUtil:addComas(v8);
    end);
    local v13 = OutfitDetails.Info.Price.SaveToRoblox.Activated:Connect(function() -- Line: 157
        -- upvalues: Holder (ref), u5 (copy), u4 (copy)
        Holder.Visible = false;
        game.ReplicatedStorage.Events.ClientSaveOutfitToRoblox:Fire(u5, { Holder }, Enum.HumanoidRigType[u4:GetAttribute("RigType") or "R15"]);
    end);
    table.insert(u3, v13);
    local v14 = OutfitDetails.Wear.Activated:Once(function() -- Line: 165
        -- upvalues: CatalogModule (ref), u5 (copy), u4 (copy)
        game.ReplicatedStorage.CatalogGuiRemote:InvokeServer({
            Action = "CreateAndWearHumanoidDescription",
            Properties = CatalogModule:ToDictionary(u5),
            RigType = u4:GetAttribute("RigType")
        });
        game.ReplicatedStorage.Events.OnSavedOutfitWorn:FireServer(u4);
    end);
    table.insert(u3, v14);

    local function Update_VOD_Frame_FavoriteButtonImage() -- Line: 180
        -- upvalues: OutfitDetails (ref), u4 (copy)
        OutfitDetails.FavoriteButton.Image = u4:GetAttribute("Favorited") and OutfitDetails.FavoriteButton:GetAttribute("FavoritedImage") or OutfitDetails.FavoriteButton:GetAttribute("UnfavoritedImage");
    end;

    OutfitDetails.FavoriteButton.Image = u4:GetAttribute("Favorited") and OutfitDetails.FavoriteButton:GetAttribute("FavoritedImage") or OutfitDetails.FavoriteButton:GetAttribute("UnfavoritedImage");
    local v15 = OutfitDetails.FavoriteButton.Activated:Connect(function() -- Line: 185
        -- upvalues: SavedOutfitsRemote (ref), u4 (copy), OutfitDetails (ref)
        SavedOutfitsRemote:InvokeServer({
            Action = "ToggleOutfitFavorited",
            GUID = u4:GetAttribute("GUID")
        });
        OutfitDetails.FavoriteButton.Image = u4:GetAttribute("Favorited") and OutfitDetails.FavoriteButton:GetAttribute("FavoritedImage") or OutfitDetails.FavoriteButton:GetAttribute("UnfavoritedImage");
    end);
    table.insert(u3, v15);
    table.insert(u3, ViewOutfitDetails2.List.OutfitActions.DeleteOutfit.Activated:Connect(function() -- Line: 201
        -- upvalues: SavedOutfitsRemote (ref), u4 (copy)
        if game.ReplicatedStorage.ClientPromptYesNoInput:Invoke({
            PromptText = "Are you sure you would like to delete this outfit?"
        }) then
            ExitOutfitDetailsScreen();
            SavedOutfitsRemote:InvokeServer({
                Action = "DeleteOutfit",
                GUID = u4:GetAttribute("GUID")
            });
        end;
    end));
    local ConfirmUpdateOutfit = script.Parent:WaitForChild("ConfirmUpdateOutfit");

    local function ToggleOpenUpdateOutfitFrame(p16) -- Line: 216
        -- upvalues: ConfirmUpdateOutfit (copy), Holder (ref)
        ConfirmUpdateOutfit.BeforeUpdate.ViewportHolder:ClearAllChildren();
        ConfirmUpdateOutfit.AfterUpdate.ViewportHolder:ClearAllChildren();
        Holder.Visible = not p16;
        ConfirmUpdateOutfit.Visible = p16;
    end;

    table.insert(u3, ViewOutfitDetails2.List.OutfitActions.UpdateOutfit.Activated:Connect(function() -- Line: 224
        -- upvalues: ConfirmUpdateOutfit (copy), Holder (ref), AvatarViewportFactory (ref), u5 (copy), u4 (copy), LocalPlayer (ref)
        ConfirmUpdateOutfit.BeforeUpdate.ViewportHolder:ClearAllChildren();
        ConfirmUpdateOutfit.AfterUpdate.ViewportHolder:ClearAllChildren();
        Holder.Visible = false;
        ConfirmUpdateOutfit.Visible = true;
        task.defer(function() -- Line: 227
            -- upvalues: AvatarViewportFactory (ref), u5 (ref), u4 (ref), ConfirmUpdateOutfit (ref)
            AvatarViewportFactory:CreateDraggableVPFNPC(u5, Enum.HumanoidRigType[u4:GetAttribute("RigType") or "R15"]).Parent = ConfirmUpdateOutfit.BeforeUpdate.ViewportHolder;
        end);
        AvatarViewportFactory:CreateDraggableVPFNPC(LocalPlayer.Character.Humanoid:GetAppliedDescription(), LocalPlayer.Character.Humanoid.RigType).Parent = ConfirmUpdateOutfit.AfterUpdate.ViewportHolder;
    end));
    table.insert(u3, ConfirmUpdateOutfit.Cancel.Activated:Connect(function() -- Line: 233
        -- upvalues: ConfirmUpdateOutfit (copy), Holder (ref)
        ConfirmUpdateOutfit.BeforeUpdate.ViewportHolder:ClearAllChildren();
        ConfirmUpdateOutfit.AfterUpdate.ViewportHolder:ClearAllChildren();
        Holder.Visible = true;
        ConfirmUpdateOutfit.Visible = false;
    end));
    table.insert(u3, ConfirmUpdateOutfit.Update.Activated:Connect(function() -- Line: 237
        -- upvalues: ConfirmUpdateOutfit (copy), Holder (ref), SavedOutfitsRemote (ref), u4 (copy)
        ConfirmUpdateOutfit.BeforeUpdate.ViewportHolder:ClearAllChildren();
        ConfirmUpdateOutfit.AfterUpdate.ViewportHolder:ClearAllChildren();
        Holder.Visible = true;
        ConfirmUpdateOutfit.Visible = false;
        SavedOutfitsRemote:InvokeServer({
            Action = "UpdateOutfit",
            GUID = u4:GetAttribute("GUID")
        });
        ViewOutfitDetails(u4);
    end));
    table.insert(u3, ViewOutfitDetails2.List.OutfitActions.RenameOutfit.Activated:Connect(function() -- Line: 250
        -- upvalues: u4 (copy), SavedOutfitsRemote (ref)
        local v17 = game.ReplicatedStorage.ClientPromptTextInput:Invoke({
            PromptText = "What would you like to rename your outfit to?",
            MaxCharacters = 100,
            PlaceholderText = "Unnamed Outfit",
            DefaultText = u4:GetAttribute("OutfitName")
        });

        if v17 then
            SavedOutfitsRemote:InvokeServer({
                Action = "RenameOutfit",
                GUID = u4:GetAttribute("GUID"),
                NewOutfitName = v17
            });
            ViewOutfitDetails(u4);
        end;
    end));
    table.insert(u3, ViewOutfitDetails2.List.OutfitActions.ShareOutfit.Activated:Connect(function() -- Line: 270
        game.ReplicatedStorage.ClientPopupMessage:Fire("Equip this outfit and then publish it to Community Outfits to share it!", 6);
    end));
    table.insert(u3, ViewOutfitDetails2.List.OutfitActions.ModifyFolders.Activated:Connect(function() -- Line: 278
        -- upvalues: u4 (copy), OutfitFolderSelector (ref), SavedOutfitsRemote (ref), UpdateBeneathOutfitDetailsText (copy), u3 (ref)
        UpdateOutfitFolderButtons();
        local Configs = u4:FindFirstChild("Configs");
        local u18 = not (Configs and Configs:GetAttribute("OutfitFolders")) and {} or string.split(Configs:GetAttribute("OutfitFolders"), ",");

        for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
            if child:FindFirstChild("UIStroke") then
                local v19 = table.find(u18, child.Name) ~= nil;
                child.UIStroke.Enabled = v19;
                child.LayoutOrder = v19 and -1 or child.LayoutOrder;
            end;
        end;

        local u20 = nil;
        u20 = OutfitFolderSelector.Back.Activated:Connect(function() -- Line: 298
            -- upvalues: u20 (ref), OutfitFolderSelector (ref), u18 (ref), SavedOutfitsRemote (ref), u4 (ref), UpdateBeneathOutfitDetailsText (ref)
            u20:Disconnect();
            u20 = nil;
            OutfitFolderSelector.Visible = false;
            local v21 = {};

            for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
                if child:FindFirstChild("UIStroke") and child.UIStroke.Enabled then
                    table.insert(v21, child.Name);
                end;
            end;

            table.sort(u18);
            table.sort(v21);

            if table.concat(u18, ",") ~= table.concat(v21, ",") then
                game.ReplicatedStorage.ClientPopupMessage:Fire("Successfully updated outfit folders.");
                SavedOutfitsRemote:InvokeServer({
                    Action = "UpdateOutfitFolders",
                    GUID = u4:GetAttribute("GUID"),
                    OutfitFolders = v21
                });
                UpdateOutfitFolderButtons();
                UpdateBeneathOutfitDetailsText();
            end;
        end);
        table.insert(u3, u20);
        OutfitFolderSelector.Visible = true;
    end));
    pcall(function() -- Line: 380
        -- upvalues: ViewOutfitDetails2 (ref), AssetButtonFactory (ref)
        ViewOutfitDetails2.List.RecommendedItems.Visible = false;

        for _, child in pairs(ViewOutfitDetails2.List.RecommendedItems.List:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy();
            end;
        end;

        local v22 = CatalogSearchParams.new();
        v22.CategoryFilter = Enum.CatalogCategoryFilter.Recommended;
        v22.Limit = 120;
        local v23 = game:GetService("AvatarEditorService"):SearchCatalog(v22):GetCurrentPage();

        for i, v in pairs(v23) do
            local v24 = AssetButtonFactory:CreateAsset(v);
            v24.Size = UDim2.fromScale(0.75, 1);
            v24.SizeConstraint = Enum.SizeConstraint.RelativeYY;
            v24.LayoutOrder = i;
            v24.Parent = ViewOutfitDetails2.List.RecommendedItems.List;
        end;

        ViewOutfitDetails2.List.RecommendedItems.Visible = true;
    end);
end;

local u25 = {};

local function CleanupPreviousList() -- Line: 415
    -- upvalues: CollectionService (copy), u25 (ref)
    for _, v in pairs(CollectionService:GetTagged(script:GetFullName())) do
        v:Destroy();
    end;

    for _, v in pairs(u25) do
        v:Disconnect();
    end;

    u25 = {};
end;

function CreateOutfitButton(u26)
    -- upvalues: u2 (ref), CatalogModule (copy), TweenService (copy), List (copy), UserInputService (copy), u25 (ref), SavedOutfitsRemote (copy), CollectionService (copy)
    local u27 = script.OutfitButton:Clone();
    local u28 = {};
    u27.Name = u26:GetAttribute("GUID") or u26.Name;

    local function UpdateOutfitViewport(p29) -- Line: 433
        -- upvalues: u27 (copy), u26 (copy)
        if not u27.Parent then
            return;
        end;

        u27.ViewportFrame.Holder:ClearAllChildren();
        u27.LoadingShine.Visible = true;
        local v30 = game.Players:CreateHumanoidModelFromDescription(p29 or u26:FindFirstChildOfClass("HumanoidDescription"), Enum.HumanoidRigType[u26:GetAttribute("RigType") or "R15"], Enum.AssetTypeVerification.Always);
        local Humanoid = v30:WaitForChild("Humanoid");
        local HumanoidRootPart = v30:WaitForChild("HumanoidRootPart");
        local Head = v30:WaitForChild("Head");
        v30:WaitForChild("Animate").Disabled = true;

        if not (u27 and u27.Parent) then
            v30:Destroy();

            return;
        end;

        HumanoidRootPart.Anchored = true;
        HumanoidRootPart.CFrame = CFrame.new(0, -50, 0);
        Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
        v30.Parent = workspace;
        u27.ViewportFrame.Target.Value = Head;
        local v31 = v30:WaitForChild("Animate", 2) and v30.Animate:FindFirstChild("idle") and (v30.Animate.idle:FindFirstChild("Animation1") or v30.Animate.idle:FindFirstChildOfClass("Animation"));

        if v31 then
            (Humanoid:FindFirstChild("Animator") or Instance.new("Animator", Humanoid)):LoadAnimation(v31):Play(0, 1, 0);
        end;

        task.wait(0.2);

        if not u27.Parent then
            v30:Destroy();

            return;
        end;

        v30.Parent = u27.ViewportFrame.Holder;
        u27.LoadingShine.Visible = false;
    end;

    local v33 = u26.ChildAdded:Connect(function(p32) -- Line: 474
        -- upvalues: UpdateOutfitViewport (copy)
        if p32:IsA("HumanoidDescription") then
            task.delay(0.2, UpdateOutfitViewport, p32);
        end;
    end);
    table.insert(u28, v33);
    task.defer(UpdateOutfitViewport);
    u27.ConfigOptions.Wear.Activated:Connect(function() -- Line: 485
        -- upvalues: u2 (ref), u27 (copy), CatalogModule (ref), u26 (copy)
        if u2 then
            return;
        end;

        u27:SetAttribute("ConfigsOpen", false);
        u27:SetAttribute("IsFocused", false);
        game.ReplicatedStorage.CatalogGuiRemote:InvokeServer({
            Action = "CreateAndWearHumanoidDescription",
            Properties = CatalogModule:ToDictionary(u26:FindFirstChildOfClass("HumanoidDescription")),
            RigType = Enum.HumanoidRigType[u26:GetAttribute("RigType") or "R15"]
        });
        game.ReplicatedStorage.Events.OnSavedOutfitWorn:FireServer(u26);
    end);
    u27.ConfigOptions.View.Activated:Connect(function() -- Line: 501
        -- upvalues: u27 (copy), u26 (copy)
        u27:SetAttribute("ConfigsOpen", false);
        u27:SetAttribute("IsFocused", false);
        ViewOutfitDetails(u26);
    end);
    u27.MouseButton2Click:Connect(function() -- Line: 508
        -- upvalues: u27 (copy), u26 (copy)
        u27:SetAttribute("ConfigsOpen", false);
        u27:SetAttribute("IsFocused", false);
        ViewOutfitDetails(u26);
    end);

    local function UpdateButtonOverlays() -- Line: 518
        -- upvalues: u27 (copy), u2 (ref), TweenService (ref)
        local v34 = u27:GetAttribute("IsFocused");
        local v35 = u27:GetAttribute("ConfigsOpen");
        local v36 = not u2;

        if v36 then
            if v34 then
                v34 = not v35;
            end;
        else
            v34 = v36;
        end;

        local v37 = not u2 and v35;
        TweenService:Create(u27.Favorite, TweenInfo.new(0.35, Enum.EasingStyle.Quint), v34 and {
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromScale(0.05, 0.05)
        } or {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0.05, -0.05)
        }):Play();

        if not v37 or u27.ConfigOptions.Position == UDim2.fromScale(0.5, 0.5) then
            if not v37 and (u27.ConfigOptions.Position ~= UDim2.fromScale(0.5, 1.5) and u27.ConfigOptions.Position ~= UDim2.fromScale(1.5, 0.5)) then
                u27.ConfigOptions:TweenPosition(UDim2.fromScale(0.5, 1.5), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.35, true);
            end;

            return;
        end;

        u27.ConfigOptions.Position = UDim2.fromScale(1.5, 0.5);
        u27.ConfigOptions:TweenPosition(UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.35, false);
    end;

    u27.MouseEnter:Connect(function() -- Line: 536
        -- upvalues: u27 (copy), List (ref)
        u27:SetAttribute("IsFocused", true);
        u27.ViewportFrame:SetAttribute("FOV", 60);

        for _, child in pairs(List:GetChildren()) do
            if child:GetAttribute("IsFocused") and child ~= u27 then
                child:SetAttribute("IsFocused", false);
            end;
        end;
    end);
    u27.MouseLeave:Connect(function() -- Line: 547
        -- upvalues: u27 (copy), UserInputService (ref)
        u27.ViewportFrame:SetAttribute("FOV", 70);

        if UserInputService.MouseEnabled and UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then
            u27:SetAttribute("IsFocused", false);
        end;
    end);
    u27.Activated:Connect(function() -- Line: 555
        -- upvalues: u27 (copy), List (ref)
        u27:SetAttribute("ConfigsOpen", not u27:GetAttribute("ConfigsOpen"));

        for _, child in pairs(List:GetChildren()) do
            if child:GetAttribute("ConfigsOpen") and child ~= u27 then
                child:SetAttribute("ConfigsOpen", false);
            end;
        end;
    end);
    u27:GetAttributeChangedSignal("IsFocused"):Connect(UpdateButtonOverlays);
    u27:GetAttributeChangedSignal("ConfigsOpen"):Connect(UpdateButtonOverlays);
    local v38 = u26:GetAttributeChangedSignal("Favorited"):Connect(function() -- Line: 571, Name: UpdateFavoriteButtonIcon
        -- upvalues: u27 (copy), u26 (copy)
        u27.Favorite.Image = u27.Favorite:GetAttribute(u26:GetAttribute("Favorited") and "FavoritedImage" or "UnfavoritedImage");
    end);
    table.insert(u25, v38);
    u27.Favorite.Image = u27.Favorite:GetAttribute(u26:GetAttribute("Favorited") and "FavoritedImage" or "UnfavoritedImage");
    u27.Favorite.Activated:Connect(function() -- Line: 578
        -- upvalues: SavedOutfitsRemote (ref), u26 (copy)
        SavedOutfitsRemote:InvokeServer({
            Action = "ToggleOutfitFavorited",
            GUID = u26:GetAttribute("GUID")
        });
    end);

    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        u27.Favorite.Size = UDim2.fromScale(0.225, 0.225);
    end;

    u27.Destroying:Connect(function() -- Line: 591
        -- upvalues: u28 (copy)
        for _, v in pairs(u28) do
            v:Disconnect();
        end;
    end);
    CollectionService:AddTag(u27, script:GetFullName());

    return u27;
end;

function LoadOutfits(u39)
    -- upvalues: CleanupPreviousList (copy), Outfits2 (copy), LoadingOverlay (copy), List (copy), u25 (ref)
    CleanupPreviousList();
    Outfits2.TotalOutfits.Text = "";
    Outfits2.TotalOutfits.Text = #(u39 or {}) .. " Outfits";
    local u40 = 0;

    local function LoadNextOutfitBatch(p41) -- Line: 610
        -- upvalues: LoadingOverlay (ref), u39 (copy), u40 (ref), List (ref)
        LoadingOverlay.Visible = true;
        local v42 = 0;

        for _ = 1, p41 do
            if u39[u40 + 1] == nil then
                break;
            end;

            u40 = u40 + 1;
            v42 = v42 + 1;
            local v43 = CreateOutfitButton(u39[u40]);
            v43.LayoutOrder = u40;
            v43.Parent = List;
        end;

        LoadingOverlay.Visible = false;

        return v42;
    end;

    local function IsAtEndOfScrollFrame() -- Line: 632
        -- upvalues: List (ref)
        return math.round(List.CanvasPosition.Y + List.AbsoluteSize.Y) >= math.round(List.AbsoluteCanvasSize.Y) - 2;
    end;

    local u44 = true;

    local function OnScrollChanged() -- Line: 639
        -- upvalues: u44 (ref), List (ref), LoadNextOutfitBatch (copy)
        if u44 and math.round(List.CanvasPosition.Y + List.AbsoluteSize.Y) >= math.round(List.AbsoluteCanvasSize.Y) - 2 then
            u44 = false;
            LoadNextOutfitBatch(16);
            task.wait(0.2);
            u44 = true;
        end;
    end;

    LoadNextOutfitBatch(15);
    print("Starting InitialLoadLoop.");
    local v45 = 0;

    while math.round(List.CanvasPosition.Y + List.AbsoluteSize.Y) >= math.round(List.AbsoluteCanvasSize.Y) - 2 do
        v45 = v45 + 1;
        local v46 = LoadNextOutfitBatch(16);
        print("InitialLoadLoop:", v45, "NumLoaded:", v46);
        task.wait(0.3333333333333333);

        if math.round(List.CanvasPosition.Y + List.AbsoluteSize.Y) < math.round(List.AbsoluteCanvasSize.Y) - 2 or v46 == 0 then
            break;
        end;
    end;

    print("Completed initial load loop on iteration:", v45);
    local v47 = List:GetPropertyChangedSignal("CanvasPosition");
    table.insert(u25, v47:Connect(OnScrollChanged));
    local v48 = List:GetPropertyChangedSignal("AbsoluteCanvasSize");
    table.insert(u25, v48:Connect(OnScrollChanged));
end;

function GetAllOutfitFolderNames()
    -- upvalues: Outfits (copy)
    local v49 = { "All" };

    for _, child in pairs(Outfits:GetChildren()) do
        local Configs = child:FindFirstChild("Configs");

        if Configs and Configs:GetAttribute("OutfitFolders") then
            for _, v in pairs(string.split(Configs:GetAttribute("OutfitFolders"), ",")) do
                if not table.find(v49, v) then
                    table.insert(v49, v);
                end;
            end;
        end;
    end;

    return v49;
end;

local function SetSelectedFolderListButton(p50) -- Line: 689
    -- upvalues: FoldersList (copy), TweenService (copy)
    for _, child in pairs(FoldersList:GetChildren()) do
        if child:IsA("GuiButton") then
            child.SelectedLine.Visible = child == p50;
        end;
    end;

    if p50 then
        local Parent = p50.Parent;
        local v51 = p50.AbsolutePosition.X + p50.AbsoluteSize.X / 2 - (Parent.AbsolutePosition + Parent.AbsoluteSize / 2).X;
        TweenService:Create(Parent, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            CanvasPosition = Parent.CanvasPosition + Vector2.new(v51, 0)
        }):Play();
    end;
end;

local function CreateNewOutfitFolderSelectorButton(p52) -- Line: 705
    -- upvalues: OutfitFolderSelector (copy)
    local u53 = script.OutfitFolderSelectorButton:Clone();
    u53.Name = p52;
    u53.TextLabel.Text = p52;
    u53.UIStroke.Enabled = false;
    u53.Parent = OutfitFolderSelector.List;
    u53.Activated:Connect(function() -- Line: 712
        -- upvalues: u53 (copy)
        u53.UIStroke.Enabled = not u53.UIStroke.Enabled;
    end);

    return u53;
end;

function UpdateOutfitFolderButtons()
    -- upvalues: FoldersList (copy), OutfitFolderSelector (copy), u1 (ref), SetSelectedFolderListButton (copy), CreateNewOutfitFolderSelectorButton (copy)
    local v54 = GetAllOutfitFolderNames();
    table.sort(v54);

    for _, child in pairs(FoldersList:GetChildren()) do
        if child:IsA("GuiButton") and not table.find(v54, child.Name) then
            child:Destroy();
        end;
    end;

    for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "CreateNew" then
            if table.find(v54, child.Name) == nil then
                child:Destroy();
            else
                child.UIStroke.Enabled = false;
            end;
        end;
    end;

    for _, v in pairs(v54) do
        if not FoldersList:FindFirstChild(v) then
            local u55 = script.FolderButton:Clone();
            u55.Name = v;
            u55.TextLabel.Text = v;
            u55.Parent = FoldersList;
            u55.Activated:Connect(function() -- Line: 752
                -- upvalues: u1 (ref), v (copy), SetSelectedFolderListButton (ref), u55 (copy)
                u1 = v;
                SetSelectedFolderListButton(u55);
                DisplayRelevantOutfits();
            end);
        end;

        if not OutfitFolderSelector.List:FindFirstChild(v) and v ~= "All" then
            CreateNewOutfitFolderSelectorButton(v);
        end;
    end;

    for _, child in pairs(FoldersList:GetChildren()) do
        if child:IsA("GuiButton") then
            child.LayoutOrder = child.Name == "All" and -1 or (table.find(v54, child.Name) or 0);
        end;
    end;

    for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
        if child:FindFirstChild("UIStroke") then
            child.LayoutOrder = table.find(v54, child.Name) or 0;
        end;
    end;

    SetSelectedFolderListButton(FoldersList:FindFirstChild(u1));
end;

OutfitFolderSelector.List.CreateNew.Activated:Connect(function() -- Line: 787
    -- upvalues: OutfitFolderSelector (copy), CreateNewOutfitFolderSelectorButton (copy)
    local v56 = game.ReplicatedStorage.ClientPromptTextInput:Invoke({
        PromptText = "Enter a name for your new Outfit Folder",
        PlaceholderText = "Enter folder name..",
        MaxCharacters = 14,
        BlacklistedCharacters = ","
    });

    if v56 and (v56 ~= "All" and not OutfitFolderSelector.List:FindFirstChild(v56)) then
        local v57 = CreateNewOutfitFolderSelectorButton(v56);
        v57.UIStroke.Enabled = true;
        v57.LayoutOrder = -25;
    end;
end);
FoldersList.ChildAdded:Connect(function(p58) -- Line: 796
    -- upvalues: TextService (copy)
    if p58:IsA("GuiButton") then
        if not p58.Visible then
            p58:GetPropertyChangedSignal("Visible"):Wait();
        end;

        task.wait();
        local v59 = TextService:GetTextSize(p58.TextLabel.Text, p58.TextLabel.AbsoluteSize.Y, p58.TextLabel.Font, Vector2.new((1 / 0), p58.TextLabel.AbsoluteSize.Y));
        local v60 = v59.X / v59.Y;

        if v60 > 12 then
            v60 = script.FolderButton.UIAspectRatioConstraint.AspectRatio;
        end;

        p58.UIAspectRatioConstraint.AspectRatio = v60;
    end;
end);

local function ListenForConfigChanges(p61) -- Line: 815
    p61:GetAttributeChangedSignal("OutfitFolders"):Connect(UpdateOutfitFolderButtons);
    p61.Destroying:Connect(UpdateOutfitFolderButtons);
end;

Outfits.DescendantAdded:Connect(function(p62) -- Line: 820
    if p62.Name == "Configs" then
        p62:GetAttributeChangedSignal("OutfitFolders"):Connect(UpdateOutfitFolderButtons);
        p62.Destroying:Connect(UpdateOutfitFolderButtons);

        if p62:GetAttribute("OutfitFolders") then
            UpdateOutfitFolderButtons();
        end;
    end;
end);

for _, descendant in pairs(Outfits:GetDescendants()) do
    if descendant.Name == "Configs" then
        descendant:GetAttributeChangedSignal("OutfitFolders"):Connect(UpdateOutfitFolderButtons);
        descendant.Destroying:Connect(UpdateOutfitFolderButtons);
    end;
end;

UpdateOutfitFolderButtons();

local function ToggleCreateNewOutfitFrameVisible(p63) -- Line: 841
    -- upvalues: CreateNewOutfit (copy), Main (copy), AvatarPreview (copy), EquippedItems (copy), ShortcutMenu (copy)
    CreateNewOutfit.Visible = p63;
    Main.Visible = not p63;
    AvatarPreview.Visible = not p63;
    EquippedItems.Visible = not p63;
    ShortcutMenu.Visible = not p63;
    CreateNewOutfit.ViewportHolder:ClearAllChildren();
    CreateNewOutfit.EnterOutfitName.Text = "";
end;

CreateNew.Activated:Connect(function() -- Line: 852
    -- upvalues: u2 (ref), CreateNewOutfit (copy), Main (copy), AvatarPreview (copy), EquippedItems (copy), ShortcutMenu (copy), OutfitFolderSelector (copy), u1 (ref), AvatarViewportFactory (copy), LocalPlayer (copy)
    if u2 then
        if #GetSelectedOutfitButtons() > 0 then
            game.ReplicatedStorage.ClientPopupMessage:Fire("You Cannot Create a new Outfit whilst in Outfit Selection Mode.");

            return;
        end;

        ToggleOutfitSelectionMode(false);
    end;

    CreateNewOutfit.Visible = true;
    Main.Visible = false;
    AvatarPreview.Visible = false;
    EquippedItems.Visible = false;
    ShortcutMenu.Visible = false;
    CreateNewOutfit.ViewportHolder:ClearAllChildren();
    CreateNewOutfit.EnterOutfitName.Text = "";
    UpdateOutfitFolderButtons();

    for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
        if child:IsA("GuiButton") and (child:FindFirstChild("UIStroke") and child.Name == u1) then
            child.UIStroke.Enabled = true;
        end;
    end;

    AvatarViewportFactory:CreateDraggableVPFNPC(LocalPlayer.Character.Humanoid:GetAppliedDescription(), LocalPlayer.Character.Humanoid.RigType).Parent = CreateNewOutfit.ViewportHolder;
end);
CreateNewOutfit.Options.Save.Activated:Connect(function() -- Line: 874
    -- upvalues: OutfitFolderSelector (copy), CreateNewOutfit (copy), Main (copy), AvatarPreview (copy), EquippedItems (copy), ShortcutMenu (copy), SavedOutfitsRemote (copy)
    local v64 = {};

    for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
        if child:FindFirstChild("UIStroke") and child.UIStroke.Enabled then
            table.insert(v64, child.Name);
        end;
    end;

    local Text = CreateNewOutfit.EnterOutfitName.Text;
    CreateNewOutfit.Visible = false;
    Main.Visible = true;
    AvatarPreview.Visible = true;
    EquippedItems.Visible = true;
    ShortcutMenu.Visible = true;
    CreateNewOutfit.ViewportHolder:ClearAllChildren();
    CreateNewOutfit.EnterOutfitName.Text = "";
    print("Creating outfit w/ OutfitFolders:", v64, table.concat(v64, ","), "OutfitName:", Text);
    SavedOutfitsRemote:InvokeServer({
        Action = "CreateNewOutfit",
        OutfitName = Text,
        Configs = {
            OutfitFolders = #v64 > 0 and table.concat(v64, ",") or nil
        }
    });
end);
CreateNewOutfit.Options.Cancel.Activated:Connect(function() -- Line: 896
    -- upvalues: CreateNewOutfit (copy), Main (copy), AvatarPreview (copy), EquippedItems (copy), ShortcutMenu (copy)
    CreateNewOutfit.Visible = false;
    Main.Visible = true;
    AvatarPreview.Visible = true;
    EquippedItems.Visible = true;
    ShortcutMenu.Visible = true;
    CreateNewOutfit.ViewportHolder:ClearAllChildren();
    CreateNewOutfit.EnterOutfitName.Text = "";
end);
CreateNewOutfit.OpenFolderSelector.Activated:Connect(function() -- Line: 900
    -- upvalues: OutfitFolderSelector (copy), CreateNewOutfit (copy)
    OutfitFolderSelector.Visible = true;
    CreateNewOutfit.Visible = false;
    local u65 = nil;
    u65 = OutfitFolderSelector.Back.Activated:Connect(function() -- Line: 904
        -- upvalues: u65 (ref), CreateNewOutfit (ref), OutfitFolderSelector (ref)
        u65:Disconnect();
        u65 = nil;
        CreateNewOutfit.Visible = true;
        OutfitFolderSelector.Visible = false;
    end);
end);

function DisplayRelevantOutfits()
    -- upvalues: SearchBox (copy), SortFilterSelection (copy), u1 (ref), BottomRightButtons (copy), Outfits (copy)
    local v66 = {};
    local v67;

    if string.gsub(SearchBox.Text, "%s", "") == "" then
        v67 = false;
    else
        v67 = string.split(SearchBox.Text, " ");
    end;

    local v68 = SortFilterSelection:GetAttribute("Value") or "Recently Updated";
    local v69 = u1;
    local v70;

    if v69 then
        v70 = v69 ~= "All";
    else
        v70 = v69;
    end;

    BottomRightButtons.FolderConfigs.Visible = v70;

    for _, child in pairs(Outfits:GetChildren()) do
        if v68 ~= "Favorited" or child:GetAttribute("Favorited") then
            local v71, v72, v73, v74;

            if v68 == "Not In Any Folders" then
                local Configs = child:FindFirstChild("Configs");

                if not Configs or string.gsub(Configs:GetAttribute("OutfitFolders") or "", "%s", "") == "" then
                    v71 = true;

                    if v67 then
                        v72 = string.gsub(child:GetAttribute("OutfitName"):lower(), "%s", "");

                        for _, v in pairs(v67) do
                            v73 = string.gsub(v:lower(), "%s", "");

                            if v73 ~= "" and not string.match(v72, v73) then
                                v71 = false;
                                break;
                            end;
                        end;
                    end;

                    if v71 then
                        if v69 and v69 ~= "All" then
                            v74 = child:FindFirstChild("Configs");

                            if v74 and (v74:GetAttribute("OutfitFolders") and table.find(string.split(v74:GetAttribute("OutfitFolders"), ","), v69)) then
                                table.insert(v66, child);
                            end;
                        else
                            table.insert(v66, child);
                        end;
                    end;
                end;
            else
                v71 = true;

                if v67 then
                    v72 = string.gsub(child:GetAttribute("OutfitName"):lower(), "%s", "");

                    for _, v in pairs(v67) do
                        v73 = string.gsub(v:lower(), "%s", "");

                        if v73 ~= "" and not string.match(v72, v73) then
                            v71 = false;
                            break;
                        end;
                    end;
                end;

                if v71 then
                    if v69 and v69 ~= "All" then
                        v74 = child:FindFirstChild("Configs");

                        if v74 and (v74:GetAttribute("OutfitFolders") and table.find(string.split(v74:GetAttribute("OutfitFolders"), ","), v69)) then
                            table.insert(v66, child);
                        end;
                    else
                        table.insert(v66, child);
                    end;
                end;
            end;
        end;
    end;

    if v68 == "Recently Updated" or (v68 == "Favorited" or v68 == "Not In Any Folders") then
        table.sort(v66, function(p75, p76) -- Line: 972
            return (p75:GetAttribute("LastUpdated") or (p75:GetAttribute("Created") or 0)) > (p76:GetAttribute("LastUpdated") or (p76:GetAttribute("Created") or 0));
        end);
    elseif v68 == "Oldest to Newest" then
        table.sort(v66, function(p77, p78) -- Line: 978
            return (p77:GetAttribute("Created") or 0) < (p78:GetAttribute("Created") or 0);
        end);
    elseif v68 == "Newest to Oldest" then
        table.sort(v66, function(p79, p80) -- Line: 984
            return (p79:GetAttribute("Created") or 0) > (p80:GetAttribute("Created") or 0);
        end);
    elseif v68 == "A-Z" then
        table.sort(v66, function(p81, p82) -- Line: 990
            return (p81:GetAttribute("OutfitName") or ""):lower() < (p82:GetAttribute("OutfitName") or ""):lower();
        end);
    elseif v68 == "Z-A" then
        table.sort(v66, function(p83, p84) -- Line: 994
            return (p83:GetAttribute("OutfitName") or ""):lower() > (p84:GetAttribute("OutfitName") or ""):lower();
        end);
    end;

    LoadOutfits(v66);
end;

local Text = SearchBox.Text;
SearchBox.Focused:Connect(function() -- Line: 1005
    -- upvalues: Text (ref), SearchBox (copy)
    Text = SearchBox.Text;
end);
SearchBox.FocusLost:Connect(function() -- Line: 1008
    -- upvalues: SearchBox (copy), Text (ref)
    if SearchBox.Text ~= Text then
        DisplayRelevantOutfits();
    end;
end);
SortFilterSelection:GetAttributeChangedSignal("Value"):Connect(DisplayRelevantOutfits);

if not LocalPlayer:GetAttribute("LoadedOutfits") then
    LocalPlayer:GetAttributeChangedSignal("LoadedOutfits"):Wait();
end;

Outfits.ChildAdded:Connect(function() -- Line: 1021
    task.wait(0.1);
    DisplayRelevantOutfits();
end);
Outfits.ChildRemoved:Connect(DisplayRelevantOutfits);
local u85 = nil;
u85 = Holder:GetPropertyChangedSignal("Visible"):Connect(function() -- Line: 1028
    -- upvalues: Holder (copy), u85 (ref)
    if Holder.Visible then
        u85:Disconnect();
        u85 = nil;
        DisplayRelevantOutfits();
        print("Loading Initial Saved Outfits.");
    end;
end);

local function UpdateOutfitViewportFrameVisibilities() -- Line: 1043
    -- upvalues: CollectionService (copy), List (copy)
    for _, v in pairs(CollectionService:GetTagged(script:GetFullName())) do
        if v.Visible then
            if v.AbsolutePosition.Y + v.AbsoluteSize.Y < List.AbsolutePosition.Y or v.AbsolutePosition.Y > List.AbsolutePosition.Y + List.AbsoluteSize.Y then
                v.ViewportFrame.Visible = false;
            else
                v.ViewportFrame.Visible = true;
            end;
        else
            v.ViewportFrame.Visible = false;
        end;
    end;
end;

List:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateOutfitViewportFrameVisibilities);
List.ChildAdded:Connect(function() -- Line: 1064
    -- upvalues: UpdateOutfitViewportFrameVisibilities (copy)
    task.wait(0.1);
    UpdateOutfitViewportFrameVisibilities();
end);
List.ChildRemoved:Connect(function() -- Line: 1068
    -- upvalues: UpdateOutfitViewportFrameVisibilities (copy)
    task.wait(0.1);
    UpdateOutfitViewportFrameVisibilities();
end);
UpdateOutfitViewportFrameVisibilities();
local u86 = 0;
local u87 = nil;

function ShowTotalOutfitsTextUntilIdle()
    -- upvalues: u87 (ref), TweenService (copy), Outfits2 (copy), RunService (copy), u86 (ref)
    if u87 == nil then
        TweenService:Create(Outfits2.TotalOutfits, TweenInfo.new(1), {
            TextTransparency = 0
        }):Play();
        u87 = RunService.Heartbeat:Connect(function() -- Line: 1087
            -- upvalues: u86 (ref), u87 (ref), TweenService (ref), Outfits2 (ref)
            if tick() - u86 > 0.75 then
                u87:Disconnect();
                u87 = nil;
                TweenService:Create(Outfits2.TotalOutfits, TweenInfo.new(1), {
                    TextTransparency = 1
                }):Play();
            end;
        end);
    end;
end;

List:GetPropertyChangedSignal("CanvasPosition"):Connect(function() -- Line: 1097
    -- upvalues: u86 (ref)
    u86 = tick();
    ShowTotalOutfitsTextUntilIdle();
end);
Outfits2.TotalOutfits:GetPropertyChangedSignal("Text"):Connect(function() -- Line: 1101
    -- upvalues: u86 (ref)
    u86 = tick();
    ShowTotalOutfitsTextUntilIdle();
end);
local u88 = nil;
BottomRightButtons.FolderConfigs.Activated:Connect(function() -- Line: 1110
    -- upvalues: u1 (ref), u88 (ref), FolderConfigs (copy)
    if u1 and u1 ~= "All" then
        u88 = u1;
        FolderConfigs.FolderName.TextBox.Text = u88;
        FolderConfigs.Visible = true;
    end;
end);
FolderConfigs.Exit.Activated:Connect(function() -- Line: 1119
    -- upvalues: FolderConfigs (copy), u88 (ref)
    FolderConfigs.Visible = false;
    u88 = nil;
end);
FolderConfigs.DeleteFolder.Activated:Connect(function() -- Line: 1124
    -- upvalues: u88 (ref), FolderConfigs (copy), u1 (ref), SavedOutfitsRemote (copy)
    if u88 then
        FolderConfigs.Visible = false;
        local v89 = game.ReplicatedStorage.ClientPromptYesNoInput:Invoke({
            PromptText = "Are you sure you would like to delete folder \"" .. u88 .. "\"?"
        });
        FolderConfigs.Visible = true;

        if v89 then
            FolderConfigs.Visible = false;
            u1 = "All";
            DisplayRelevantOutfits();
            SavedOutfitsRemote:InvokeServer({
                Action = "DeleteOutfitFolder",
                FolderToDelete = u88
            });
            game.ReplicatedStorage.ClientPopupMessage:Fire("Folder \"" .. u88 .. "\" has been deleted.");
            u88 = nil;
            UpdateOutfitFolderButtons();
        end;
    end;
end);
FolderConfigs.FolderName.TextBox.FocusLost:Connect(function() -- Line: 1142
    -- upvalues: FolderConfigs (copy), u88 (ref), SavedOutfitsRemote (copy), u1 (ref)
    local v90 = string.gsub(FolderConfigs.FolderName.TextBox.Text, "^%s+", "");
    local v91 = string.gsub(v90, "%s+$", "");
    local v92 = string.gsub(v91, ",", "");
    local v93 = string.sub(v92, 1, 14);

    if v93 == u88 then
        return;
    end;

    if v93 == "All" or string.gsub(v93, "%s", "") == "" then
        game.ReplicatedStorage.ClientPopupMessage:Fire("This folder name is not allowed.");

        return;
    end;

    FolderConfigs.FolderName.TextBox.Text = v93;
    SavedOutfitsRemote:InvokeServer({
        Action = "RenameOutfitFolder",
        FolderToRename = u88,
        RenameTo = v93
    });
    game.ReplicatedStorage.ClientPopupMessage:Fire("Successfully renamed folder to \"" .. v93 .. "\"");
    u88 = v93;
    u1 = v93;
    UpdateOutfitFolderButtons();
end);
local u94 = "HumanoidRootPart";

function UpdatePerspective()
    -- upvalues: AvatarPreview (copy), u94 (ref)
    local NPC = AvatarPreview.ViewportHolder:FindFirstChild("NPC", true);
    local v95 = AvatarPreview.ViewportHolder:FindFirstChildWhichIsA("ViewportFrame", true);

    if u94 == "HumanoidRootPart" then
        v95.Target.Value = NPC.HumanoidRootPart;
        v95:SetAttribute("MoveUp", -0.25);
    elseif u94 == "Head" then
        v95.Target.Value = NPC.Head;
        v95:SetAttribute("MoveUp", 0.25);
    end;

    AvatarPreview.Perspective.Image = u94 == "Head" and AvatarPreview.Perspective:GetAttribute("HeadFocusedImage") or AvatarPreview.Perspective:GetAttribute("HeadUnfocusedImage");
end;

AvatarPreview.Perspective.Activated:Connect(function() -- Line: 1188
    -- upvalues: u94 (ref)
    if u94 == "HumanoidRootPart" then
        u94 = "Head";
    elseif u94 == "Head" then
        u94 = "HumanoidRootPart";
    end;

    UpdatePerspective();
end);
local u96 = nil;

function UpdatePreviewNPC(p97, p98)
    -- upvalues: u96 (ref), LocalPlayer (copy), AvatarPreview (copy), AvatarViewportFactory (copy)
    if not p97 then
        return;
    end;

    if p98 or u96 ~= nil and LocalPlayer.Character.Humanoid.RigType ~= u96.WorldModel.NPC.Humanoid.RigType then
        AvatarPreview.ViewportHolder:ClearAllChildren();
        u96 = nil;
    end;

    if u96 == nil then
        local v99 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.RigType;
        u96 = AvatarViewportFactory:CreateDraggableVPFNPC(p97, v99);
        u96.Parent = AvatarPreview.ViewportHolder;
    else
        u96.WorldModel.NPC.Humanoid:ApplyDescription(p97, Enum.AssetTypeVerification.Always);
    end;

    UpdatePerspective();
end;

function OnCharacterAdded(p100)
    local Humanoid = p100:WaitForChild("Humanoid");
    Humanoid.ApplyDescriptionFinished:Connect(function(p101) -- Line: 1225
        UpdatePreviewNPC(p101);
    end);

    if Humanoid:FindFirstChildOfClass("HumanoidDescription") then
        UpdatePreviewNPC(p100.Humanoid:GetAppliedDescription());
    end;
end;

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded);

if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character);
end;

Holder:GetPropertyChangedSignal("Visible"):Connect(function() -- Line: 1237
    -- upvalues: Holder (copy), LocalPlayer (copy)
    if Holder.Visible then
        UpdatePreviewNPC(LocalPlayer.Character.Humanoid:GetAppliedDescription(), true);
    end;
end);
local u102 = false;

function ToggleOpen(p103)
    -- upvalues: u102 (ref), Holder (copy)
    if p103 == nil then
        u102 = not u102;
    else
        u102 = p103;
    end;

    Holder.Visible = u102;
    game.ReplicatedStorage.ClientToggleUIVisible:Fire(not u102, { "Undo", "Redo" }, u102);

    if u102 then
        game.ReplicatedStorage.ClientOnGuiOpened:Fire(script.Parent);
    end;
end;

OpenSavedOutfits.Activated:Connect(function() -- Line: 1265
    ToggleOpen();
end);
Main.Exit.Activated:Connect(function() -- Line: 1268
    -- upvalues: Main (copy)
    if Main.ViewOutfitDetails.Visible then
        ExitOutfitDetailsScreen();

        return;
    end;

    ToggleOpen(false);
end);
local u104 = {};

function GetSelectedOutfitButtons()
    -- upvalues: CollectionService (copy)
    local v105 = {};
    local v106 = {};

    for _, v in pairs(CollectionService:GetTagged(script:GetFullName())) do
        if v.SelectionUIStroke.Enabled then
            table.insert(v105, v);

            if not table.find(v106, v.Name) then
                table.insert(v106, v.Name);
            end;
        end;
    end;

    return v105, v106;
end;

function ToggleOutfitSelectionMode(p107)
    -- upvalues: u2 (ref), CollectionService (copy), BottomRightButtons (copy), FoldersList (copy), BottomLeftButtons (copy), u1 (ref), u104 (ref)
    if p107 == nil then
        u2 = not u2;
    else
        u2 = p107;
    end;

    for _, v in pairs(CollectionService:GetTagged(script:GetFullName())) do
        if v:GetAttribute("ConfigsOpen") then
            v:SetAttribute("ConfigsOpen", false);
        end;

        if v:GetAttribute("IsFocused") then
            v:SetAttribute("IsFocused", false);
        end;
    end;

    BottomRightButtons.SelectOutfits.TextLabel.Text = u2 and "Cancel Selection" or "Select Outfits";
    FoldersList.Visible = not u2;

    for _, child in pairs(BottomLeftButtons:GetChildren()) do
        if child:GetAttribute("OutfitSelectionModeButton") then
            child.Visible = u2;

            if child.Visible and child:GetAttribute("VisibleInFoldersOnly") then
                child.Visible = u1 and u1 ~= "All";
            end;
        end;
    end;

    for _, v in pairs(u104) do
        v:Disconnect();
    end;

    u104 = {};

    local function SetupButtonSelectionUIStrokeConnections(u108) -- Line: 1343
        -- upvalues: u2 (ref), u104 (ref)
        u108.SelectionUIStroke.Enabled = false;

        if u2 then
            local v109 = u108.Activated:Connect(function() -- Line: 1347
                -- upvalues: u108 (copy)
                u108.SelectionUIStroke.Enabled = not u108.SelectionUIStroke.Enabled;
            end);
            table.insert(u104, v109);
        end;
    end;

    for _, v in pairs(CollectionService:GetTagged(script:GetFullName())) do
        v.SelectionUIStroke.Enabled = false;

        if u2 then
            local v110 = v.Activated:Connect(function() -- Line: 1347
                -- upvalues: v (copy)
                v.SelectionUIStroke.Enabled = not v.SelectionUIStroke.Enabled;
            end);
            table.insert(u104, v110);
        end;
    end;

    local v111 = CollectionService:GetInstanceAddedSignal(script:GetFullName()):Connect(SetupButtonSelectionUIStrokeConnections);
    table.insert(u104, v111);
end;

BottomRightButtons.SelectOutfits.Activated:Connect(function() -- Line: 1362
    ToggleOutfitSelectionMode();
end);
BottomLeftButtons.DeleteSelection.Activated:Connect(function() -- Line: 1367
    -- upvalues: SavedOutfitsRemote (copy)
    local v112, v113 = GetSelectedOutfitButtons();

    if #v113 == 0 then
        game.ReplicatedStorage.ClientPopupMessage:Fire("You have not selected any outfits!");

        return;
    end;

    if game.ReplicatedStorage.ClientPromptYesNoInput:Invoke({
        PromptText = "Are you sure you would like to delete the " .. #v112 .. " selected outfit" .. (#v112 == 1 and "" or "s") .. "?"
    }) then
        ToggleOutfitSelectionMode(false);
        SavedOutfitsRemote:InvokeServer({
            Action = "BulkDeleteOutfits",
            OutfitGUIDs = v113
        });
        game.ReplicatedStorage.ClientPopupMessage:Fire("Successfully deleted " .. #v112 .. " outfits.");
    end;
end);
BottomLeftButtons.RemoveFromFolder.Activated:Connect(function() -- Line: 1384
    -- upvalues: u1 (ref), SavedOutfitsRemote (copy)
    local v114, v115 = GetSelectedOutfitButtons();

    if #v115 == 0 then
        game.ReplicatedStorage.ClientPopupMessage:Fire("You have not selected any outfits!");

        return;
    end;

    if game.ReplicatedStorage.ClientPromptYesNoInput:Invoke({
        PromptText = "Are you sure you would like to remove the " .. #v114 .. " selected outfit" .. (#v115 == 1 and "" or "s") .. " from the folder \"" .. u1 .. "\"?"
    }) then
        ToggleOutfitSelectionMode(false);
        SavedOutfitsRemote:InvokeServer({
            Action = "BulkOutfitFolderRemoval",
            OutfitGUIDs = v115,
            FolderToRemoveFrom = u1
        });
        game.ReplicatedStorage.ClientPopupMessage:Fire("Successfully removed " .. #v114 .. " outfits from folder \"" .. u1 .. "\".");
        DisplayRelevantOutfits();
    end;
end);
BottomLeftButtons.AddToFolder.Activated:Connect(function() -- Line: 1402
    -- upvalues: OutfitFolderSelector (copy), SavedOutfitsRemote (copy)
    local _, u116 = GetSelectedOutfitButtons();
    UpdateOutfitFolderButtons();

    if #u116 == 0 then
        game.ReplicatedStorage.ClientPopupMessage:Fire("You have not selected any outfits!");

        return;
    end;

    OutfitFolderSelector.Visible = true;
    local u117 = nil;
    u117 = OutfitFolderSelector.Back.Activated:Connect(function() -- Line: 1412
        -- upvalues: u117 (ref), OutfitFolderSelector (ref), u116 (copy), SavedOutfitsRemote (ref)
        u117:Disconnect();
        u117 = nil;
        OutfitFolderSelector.Visible = false;
        local v118 = {};

        for _, child in pairs(OutfitFolderSelector.List:GetChildren()) do
            if child:FindFirstChild("UIStroke") and child.UIStroke.Enabled then
                table.insert(v118, child.Name);
            end;
        end;

        if #v118 > 0 and game.ReplicatedStorage.ClientPromptYesNoInput:Invoke({
            PromptText = "Add " .. #u116 .. " selected outfit" .. (#u116 == 1 and "" or "s") .. " to " .. #v118 .. " folder" .. (#v118 == 1 and "" or "s") .. "?"
        }) then
            ToggleOutfitSelectionMode(false);
            SavedOutfitsRemote:InvokeServer({
                Action = "BulkOutfitFolderAddition",
                OutfitGUIDs = u116,
                FoldersToAddTo = v118
            });
            game.ReplicatedStorage.ClientPopupMessage:Fire("Successfully added " .. #u116 .. " selected outfit" .. (#u116 == 1 and "" or "s") .. " to " .. #v118 .. " folder" .. (#v118 == 1 and "" or "s") .. "!");
            UpdateOutfitFolderButtons();
        end;
    end);
end);
