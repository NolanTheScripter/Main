local SC = {};

SC.Def = {
    RetryCnt = 2;
    RetryDly = 1;
    YieldInt = 0.03;
};

SC.Err = {
    InvalidURL = "Invalid URL provided";
    Aborted = "Execution aborted";
    Suspicious = "Suspicious content detected";
    FetchFail = "Failed to fetch script";
    ExecFail = "Script execution failed";
};

SC.AV = {
    Log = {};
    QuarantineDir = "AVQuarantine";

    LogDet = function(self, url, reason)
        table.insert(self.Log, {
            Time = os.time();
            URL = url;
            Reason = reason;
        });
        warn("⚠️ Suspicious script detected and blocked from: " .. url);
        warn("Reason: " .. reason);
    end;

    QuarantineScr = function(self, url, content)
        if not isfolder(self.QuarantineDir) then
            makefolder(self.QuarantineDir);
        end;
        local fileName = self.QuarantineDir .. "/" .. game:GetService("HttpService"):GenerateGUID(false) .. ".lua";
        writefile(fileName, content);
        print("🔒 Suspicious script quarantined: " .. fileName);
    end;

    ScanWS = function(self)
        print("🔍 Scanning workspace for suspicious scripts...");
        local suspCnt = 0;
        local function scanInst(inst)
            if inst:IsA("LuaSourceContainer") then
                local src = inst.Source;
                local isSusp, reason = SC.IsSusp(src);
                if isSusp then
                    suspCnt = suspCnt + 1;
                    warn("⚠️ Suspicious script found in workspace: " .. inst:GetFullName());
                    warn("Reason: " .. reason);
                end;
            end;
            for _, child in ipairs(inst:GetChildren()) do
                scanInst(child);
            end;
        end;
        scanInst(game);
        print("✅ Workspace scan completed. Found " .. suspCnt .. " suspicious scripts.");
    end;

    ScanAll = function(self)
        print("🔍 Scanning all instances for suspicious content...");
        local suspCnt = 0;

        local function scanTbl(tbl)
            for key, val in pairs(tbl) do
                if type(val) == "string" then
                    local isSusp, reason = SC.IsSusp(val);
                    if isSusp then
                        suspCnt = suspCnt + 1;
                        warn("⚠️ Suspicious content found in table key: " .. tostring(key));
                        warn("Reason: " .. reason);
                    end;
                elseif type(val) == "table" then
                    scanTbl(val);
                end;
            end;
        end;

        local function scanInst(inst)
            if inst:IsA("LuaSourceContainer") then
                local src = inst.Source;
                local isSusp, reason = SC.IsSusp(src);
                if isSusp then
                    suspCnt = suspCnt + 1;
                    warn("⚠️ Suspicious script found in instance: " .. inst:GetFullName());
                    warn("Reason: " .. reason);
                end;
            end;
            for _, child in ipairs(inst:GetChildren()) do
                scanInst(child);
            end;
        end;

        local function scanSvc(svc)
            for _, inst in ipairs(svc:GetChildren()) do
                scanInst(inst);
            end;
        end;

        for _, svc in ipairs(game:GetChildren()) do
            scanSvc(svc);
        end;

        -- Scan global environment
        scanTbl(_G);

        -- Scan workspace
        scanInst(game);

        print("✅ Comprehensive scan completed. Found " .. suspCnt .. " suspicious items.");
    end;
};

SC.GUI = {
    SGUINode = nil;
    NotifyTpl = nil;

    SetupGUI= function(self)
        self.SGUINode= Instance.new("ScreenGui");
        self.SGUINode.Name= "SCNotify";
        self.SGUINode.Parent= game.Players.LocalPlayer:WaitForChild("PlayerGui");

        self.NotifyTpl= Instance.new("TextLabel");
        self.NotifyTpl.Size= UDim2.new(0, 300, 0, 50);
        self.NotifyTpl.Position= UDim2.new(1, -320, 1, -70);
        self.NotifyTpl.AnchorPoint= Vector2.new(0, 1);
        self.NotifyTpl.BackgroundColor3= Color3.fromRGB(40, 40, 40);
        self.NotifyTpl.TextColor3= Color3.fromRGB(255, 255, 255);
        self.NotifyTpl.TextSize= 14;
        self.NotifyTpl.Font= Enum.Font.SourceSansBold;
        self.NotifyTpl.TextWrapped= true;
        self.NotifyTpl.TextXAlignment= Enum.TextXAlignment.Left;
        self.NotifyTpl.TextYAlignment= Enum.TextYAlignment.Top;

        local corner= Instance.new("UICorner");
        corner.CornerRadius= UDim.new(0, 8);
        corner.Parent= self.NotifyTpl;

       local padding= Instance.new("UIPadding");
       padding.PaddingLeft= UDim.new(0, 10);
       padding.PaddingRight= UDim.new(0, 10);
       padding.PaddingTop= UDim.new(0, 5);
       padding.PaddingBottom= UDim.new(0, 5);
       padding.Parent= self.NotifyTpl;
   end;

   NotifyUser=function(self,title,msg,color )
      local notify=self.NotifyTpl :Clone ();
      notify.Text=title.."\n"..msg ;
      notify.BackgroundColor3=color or Color3.fromRGB (40 ,40 ,40 );
      notify.Parent=self.SGUINode ;

      -- Animation 
      task.spawn (function()
         notify :TweenPosition (
             UDim2 .new (1 ,-320 ,1 ,-70 -(#self.SGUINode :GetChildren ()-1 )*60 ),
             Enum.EasingDirection.Out ,
             Enum.EasingStyle.Quart ,
             0.5 ,
             true 
         );

         -- Auto-remove after 5 seconds 
         task.wait (5 );

         notify :TweenPosition (
             UDim2 .new (1 ,20 ,notify.Position.Y.Scale ,notify.Position.Y.Offset ),
             Enum.EasingDirection.Out ,
             Enum.EasingStyle.Quart ,
             0.5 ,
             true ,
             function()
                 notify :Destroy ();
             end 
         );
     end )
   end ;
};

function SC.IsSusp(scr )
   local suspPatterns={
       "MarketplaceService",
       "robux",
       "DevProduct",
       "ProductPurchase",
       "PromptPurchase",
       "GetRobuxBalance",
       "PerformPurchase",
       "RequestPurchase",
       "httpservice",
       "syn",
       "http",
       "request",
       "getgenv",
       "setclipboard",
       "loadstring",
       "getfenv",
       "setfenv"
   };

   local lowerSrc=scr :lower ();
   for _ ,pattern in ipairs(suspPatterns )do 
      if lowerSrc :find (pattern :lower ())then 
         return true ,"Suspicious pattern found:"..pattern ;
     end ;
   end ;

   if scr :find ("string%.char%(" )or scr :find ("string%.byte%(" )then 
      return true ,"Potential obfuscation detected" ;
   end ;

   -- Check for base64 encoded content 
   if scr :match ("^[A-Za-z0-9+/]+={0 ,2}$" )then 
      return true ,"Potential base64 encoded content detected" ;
   end ;

   return false ;
end ;

function SC.Exec(url ,opts )
   assert (type (url )=="string" and url :match ("^https?://"),SC.Err.InvalidURL );
   opts=type (opts )=="table" and opts or{};

   local retryCnt=opts.RetryCnt or SC.Def.RetryCnt ;
   local retryDly=opts.RetryDly or SC.Def.RetryDly ;

   local function fetchAndChkScr ()
      local success ,content=pcall (game.HttpGet ,game ,url );
      if not success then 
         SC.GUI :NotifyUser ("Fetch Failed",SC.Err.FetchFail..": "..tostring (content ),Color3.fromRGB (255 ,100 ,100 ));
         return false ,SC.Err.FetchFail..": "..tostring (content );
     end ;

     local isSusp ,reason=SC.IsSusp (content );
     if isSusp then 
         SC.AV :LogDet (url ,reason );
         SC.AV :QuarantineScr (url ,content );
         SC.AV :ScanWS ();
         SC.GUI :NotifyUser ("Suspicious Content",SC.Err.Suspicious..": "..reason ,Color3.fromRGB (255 ,165 ,0 ));
         return false ,SC.Err.Suspicious..": "..reason ;
     end ;

     return true ,content ;
end ;

local function runScr(content )
     local success,result=pcall(loadstring(content ));
     if not success then 
         SC.GUI:NotifyUser ("Execution Failed",SC.Err.ExecFail..": "..tostring(result ),Color3.fromRGB(255 ,100 ,100 ));
         return false ,SC.Err.ExecFail..": "..tostring(result );
     end ;
     return true,result ;
end ;

local function retry(attemptsLeft )
     local fetchSuccess,fetchResult=fetchAndChkScr();
     if not fetchSuccess then 
         if attemptsLeft >0 then 
             if opts.OnRetry then 
                 opts.OnRetry(retryCnt -attemptsLeft +1 ,fetchResult );
             end ;
             SC.GUI:NotifyUser ("Retrying","Attempt "..(retryCnt -attemptsLeft +1 ).." of "..retryCnt ,Color3.fromRGB(255 ,255 ,100 ));
              task.wait(retryDly );
              return retry(attemptsLeft -1 );
          else 
              if opts.OnError then opts.OnError(fetchResult );end ;
              return false ,fetchResult ;
          end ;
      end ;

      local runSuccess,runResult=runScr(fetchResult );
      if runSuccess then 
          if opts.OnSuccess then opts.OnSuccess(runResult );end ;
          SC.GUI:NotifyUser ("Success","Script executed successfully",Color3.fromRGB(100 ,255 ,100 ));
          return true ,runResult ;
      elseif attemptsLeft >0 then 
          if opts.OnRetry then 
              opts.OnRetry(retryCnt -attemptsLeft +1 ,runResult );
          end ;
          SC.GUI:NotifyUser ("Retrying","Attempt "..(retryCnt -attemptsLeft +1 ).." of "..retryCnt ,Color3.fromRGB(255 ,255 ,100 ));
           task.wait(retryDly );
           return retry(attemptsLeft -1 );
      else 
           if opts.OnError then opts.OnError(runResult );end ;
           return false ,runResult ;
      end ;
end ;

if opts.ShouldAbort and opts.ShouldAbort()then 
     SC.GUI:NotifyUser ("Aborted",SC.Err.Aborted ,Color3.fromRGB(255 ,165 ,0 ));
     return false ,SC.Err.Aborted ;
end ;

return retry(retryCnt );
end ;

-- Initialize the GUI when the module loads 
SC.GUI:SetupGUI ();

-- Example usage 
local url="https://example.com/script.lua";
local options={
     RetryCnt=0 ,
     RetryDly=5 ,
     OnSuccess=function(result )print ("Success:",result );end ,
     OnError=function(error )warn ("Error:",error );end ,
     OnRetry=function(attempt,error )warn ("Retry attempt:",attempt ,"Error:",error );end ,
     ShouldAbort=function()return false ;end -- Example abort condition 
};

local success,result=SC.Exec(url ,options );
print(success and ("Final result:"..tostring(result ))or ("Final failure:"..tostring(result )));

-- To scan all instances services functions variables and numbers 
SC.AV:ScanAll ();