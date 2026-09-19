-- Run with repository Assets; this test never sends a real model request.
local D=require('Dora')
local previousSize=D.App.winSize
local previousModules={}
for k,v in pairs(package.loaded) do if k:match('Dev[/%.]Mobile') then previousModules[k]=v;package.loaded[k]=nil end end
D.App.winSize=D.Size(585,1266)
for k in pairs(package.loaded) do if k:match('Dev[/%.]Mobile') then package.loaded[k]=nil end end
local Feed=require('Dev/Mobile/Feed');local Remix=require('Dev/Mobile/Remix');local LLM=require('Dev/Mobile/LLMSetup')
local find=require('Dev/Mobile/Gamepad').findGamepadNode
local out=D.Path(D.Content.writablePath,'go-ui-revision')..'/'
D.Content:mkdir(out)
local checks,fixtures={},{}
local function check(v,msg)assert(v,msg);checks[#checks+1]=msg end
local function tap(h,tag)local n=find(h,tag);assert(n,'missing '..tag);n:emit('Tapped')end
local function shot(n)D.App:saveScreenshot(out..n..'.tga');D.sleep(.08)end
D.thread(function()
 local hidden={};D.Director.systemUI:eachChild(function(n)if n.tag=='mobile-feed' or n.tag=='mobile-remix' then hidden[#hidden+1]={n,n.visible};n.visible=false end;return false end)
 local ok,err=xpcall(function()
  local corners=require('Dev/Mobile/Visual').roundedRectVerts(200,208,24,0)
  check(corners[1].x==200 and corners[1].y==0 and corners[#corners].x==0 and corners[#corners].y==0,'bottom sheet corners are square')
  local writes,created,sends=0,0,0;local draftEntry,materialize
  local root=out..'draft-fixture-'..os.time();D.Content:mkdir(root)
  local storage={workspace=root,getDirs=function(p)return D.Content:getDirs(p)end,getFiles=function(p)return D.Content:getFiles(p)end,exist=function(p)return D.Content:exist(p)end,mkdir=function(p)return D.Content:mkdir(p)end,save=function(p,s)return D.Content:save(p,s)end,remove=function(p)return D.Content:remove(p)end}
  local description='一个关于重力、碰撞和探索的游戏。在会移动的平台间跳跃，收集金币并寻找出口。每个房间都有不同的谜题与秘密；你可以自由改变角色速度、场景和奖励规则。长按与滚动只阅读简介，不切换卡带。'
  local feed=Feed.startMobileFeed({getLocalEntries=function()return {{id='long',kind='local',title='我的跳跳球',description=description,bannerFile='Image/banner.jpg'}}end,getDiscoverEntries=function()return {}end,onPlay=function()end,onRemix=function(e,c)draftEntry=e;materialize=c end,createProject=function(name,lang)writes=writes+1;local r=require('Dev/Mobile/ProjectCreate').createMobileProject(name,lang,storage);if not r.success then return r end;return {success=true,entry={id='created',title=name,kind='local',workDir=r.workDir,fileName=r.fileName}}end,onSwitchMode=function()end})
  fixtures[#fixtures+1]=feed;D.sleep(.4);shot('revision-feed')
  local card=find(feed,'mobile-feed-cartridge');local beforeY=card.y
  tap(feed,'mobile-feed-description-toggle');D.sleep(.35)
  local scroll=find(feed,'mobile-feed-description-scroll');check(scroll~=nil and scroll.area.height>=39 and scroll.area.height<=63,'description expands to three-line scrolling area');check(card.y>beforeY,'expansion moves content upward');shot('revision-description')
  scroll.offset=D.Vec2(0,20);scroll:emit('Scrolled',D.Vec2.zero);check(find(feed,'mobile-feed-card-long')~=nil,'reading description retains current game')
  scroll:emit('TapBegan');scroll:emit('TapMoved',{delta=D.Vec2(0,18)});scroll:emit('TapEnded');D.sleep(.1);check(find(feed,'mobile-feed-description-scroll')~=nil,'dragging description does not collapse it')
  scroll:emit('TapBegan');scroll:emit('TapEnded');D.sleep(.35);check(find(feed,'mobile-feed-description-scroll')==nil,'tapping expanded description collapses it');check(math.abs(card.y-beforeY)<.1,'collapsed layout restores card position')
  local scene=find(feed,'mobile-feed-scene');scene:emit('TapBegan');D.sleep(.18);scene:emit('TapMoved',{delta=D.Vec2(-60,0)});check(card.scaleX<1 and card.angleY>0,'left drag scales and tilts card into depth');shot('revision-drag');scene:emit('TapEnded');D.sleep(.3);check(math.abs(card.scaleX-1)<.001 and math.abs(card.angleY)<.001,'cancel restores scale and perspective')
  tap(feed,'mobile-feed-settings');D.sleep(.3);tap(feed,'mobile-agent-config');D.sleep(.4)
  local manager=D.Director.systemUI:getChildByTag('mobile-llm-manager');check(manager~=nil and feed.visible,'home opens Agent settings over visible feed');check(find(manager,'mobile-llm-config-scroll')~=nil,'Agent configurations use scroll list');shot('revision-agent-home')
  tap(manager,'mobile-llm-manager-close');D.sleep(.3);check(feed.visible,'closing settings retains home')
  tap(feed,'mobile-feed-create');check(writes==0 and #D.Content:getDirs(root)==0,'new button creates no directory');check(materialize~=nil,'new button passes deferred creation callback')
  feed.visible=false
  local session={id=999,title='draft',projectRoot='',kind='main',rootSessionId=999,memoryScope='',workMode='code',status='IDLE',createdAt=0,updatedAt=0}
  local detail={success=true,session=session,relatedSessions={},messages={},steps={},checkpoints={},hasActivePlan=false}
  local config={url='',model='test',apiKey='',contextWindow=8192,temperature=0,maxTokens=100,supportsFunctionCalling=true}
  local allowConfig=true
  local services={createSession=function(path)created=created+1;session.projectRoot=path;return {success=true,session=session}end,getSession=function()return detail end,setWorkMode=function(_,m)session.workMode=m;return {success=true}end,sendPrompt=function(_,text,_,mode)sends=sends+1;check(text~='','only non-empty prompt reaches service');session.workMode=mode;return {success=false,message='Test send failure'}end,respondQuestionnaire=function()return {success=false,message='unused'}end,stopSessionTask=function()end,getActiveLLMConfig=function()if allowConfig then return {success=true,id=999,config=config}end;return {success=false,message='missing'}end,getLLMConfig=function()if allowConfig then return {success=true,id=999,config=config}end;return {success=false,message='missing'}end,getLLMConfigSummaries=function()return {{id=999,name='测试配置',model='test'}}end}
  local h=Remix.startMobileRemix({entry=draftEntry,createProject=materialize,onBack=function()end,onPlay=function()end,services=services});fixtures[#fixtures+1]=h;D.sleep(.4)
  check(writes==0 and created==0,'draft conversation creates neither project nor session');shot('revision-draft')
  check(find(h,'remix-settings')==nil,'conversation has no redundant settings menu')
  tap(h,'remix-title-edit');D.sleep(.35)
  local rename=find(h,'remix-title-input')
  check(rename and not D.Director.systemUI:getChildByTag('go-workspace-panel'),'title edits inline without a modal');shot('revision-rename')
  rename:emit('TextInput','测试')
  tap(h,'remix-title-cancel');D.sleep(.1)
  check(draftEntry.title=='未命名游戏' and writes==0,'cancel name edit keeps draft and filesystem unchanged')
  tap(h,'remix-title-edit');D.sleep(.1);rename=find(h,'remix-title-input')
  rename:emit('KeyDown','Home')
  for i=1,30 do rename:emit('KeyDown','Delete') end
  rename:emit('TextInput','   ');tap(h,'remix-title-confirm')
  check(find(h,'remix-title-input')==rename and draftEntry.title=='未命名游戏','empty title stays in edit mode without changing saved name')
  rename:emit('TextEditing','中文名称',2);h:emit('ResumeLocalUI')
  check(find(h,'remix-title-input')==rename,'session refresh preserves active title IME node')
  tap(h,'remix-title-confirm');check(find(h,'remix-title-input')~=nil,'confirm does not save unfinished composition')
  rename:emit('TextInput','中文名称');tap(h,'remix-title-confirm');D.sleep(.1)
  check(find(h,'remix-title-input')==nil and draftEntry.title=='中文名称','confirm saves trimmed Chinese title and exits edit mode')
  D.App.winSize=D.Size(480,960);D.sleep(.3);tap(h,'remix-title-edit');D.sleep(.1)
  rename=find(h,'remix-title-input');local cancel=find(h,'remix-title-cancel');local confirm=find(h,'remix-title-confirm')
  check(rename.x+rename.width<=cancel.x and cancel.x+cancel.width<=confirm.x,'narrow header fits input and both action buttons');shot('revision-rename-narrow')
  tap(h,'remix-title-cancel');D.App.winSize=D.Size(585,1266);D.sleep(.3)
  check(writes==0 and created==0,'renaming draft does not create project or session');shot('revision-renamed')
  tap(h,'remix-send');check(writes==0 and sends==0,'empty send does not materialize project')
  tap(h,'remix-mode-plan');check(created==0,'switching draft mode does not create session')
  find(h,'remix-input'):emit('TextInput','做一个跳跳球游戏')
  allowConfig=false;tap(h,'remix-send');D.sleep(.35);check(writes==0 and created==0,'missing API config does not create project');manager=D.Director.systemUI:getChildByTag('mobile-llm-manager');check(manager and h.visible,'conversation remains visible under model settings');shot('revision-agent-chat');tap(manager,'mobile-llm-manager-close');D.sleep(.3)
  allowConfig=true;tap(h,'remix-send');D.sleep(.3);check(writes==1 and created==1 and sends==1,'first valid send creates project and session once');check(session.workMode=='plan','draft work mode survives creation');check(#D.Content:getDirs(root)==1,'exactly one project directory exists')
  tap(h,'remix-send');check(writes==1 and created==1 and sends==2,'retry after send failure reuses project and session')
  tap(h,'remix-title-edit');find(h,'remix-title-input'):emit('TextInput','保存');tap(h,'remix-title-confirm')
  check(require('Dev/Mobile/ProjectPresentation').projectDisplayName(draftEntry.workDir,'')==draftEntry.title,'existing project title persists through display-name storage')
  h.visible=false
  local projectAttempts,sessionAttempts=0,0
  local failedServices=setmetatable({createSession=function(path)
   sessionAttempts=sessionAttempts+1
   if sessionAttempts==1 then return {success=false,message='Test session failure'} end
   session.projectRoot=path;return {success=true,session=session}
  end},{__index=services})
  local retry=Remix.startMobileRemix({entry={id='retry-draft',title='重试项目'},createProject=function()
   projectAttempts=projectAttempts+1
   if projectAttempts==1 then return {success=false,error='Test project failure'} end
   return {success=true,entry={id='retry',title='重试项目',workDir=root..'/retry'}}
  end,onBack=function()end,onPlay=function()end,services=failedServices})
  fixtures[#fixtures+1]=retry
  find(retry,'remix-input'):emit('TextInput','生成游戏')
  tap(retry,'remix-send');check(projectAttempts==1 and sessionAttempts==0,'project failure preserves draft without creating session')
  tap(retry,'remix-send');check(projectAttempts==2 and sessionAttempts==1,'project retry reaches session creation')
  tap(retry,'remix-send');check(projectAttempts==2 and sessionAttempts==2,'session retry reuses materialized project')
  retry.visible=false;feed.visible=true
  for _,size in ipairs({D.Size(480,960),D.Size(1266,585)}) do
   D.App.winSize=size;D.sleep(.35)
   tap(feed,'mobile-feed-settings');D.sleep(.25);tap(feed,'mobile-agent-config');D.sleep(.35)
   manager=D.Director.systemUI:getChildByTag('mobile-llm-manager')
   local list=find(manager,'mobile-llm-config-scroll')
   check(list and list.area.height>0 and feed.visible,'Agent scroll viewport remains available at '..size.width..'x'..size.height)
   shot('revision-agent-'..size.width..'x'..size.height)
   feed.visible=false;tap(manager,'mobile-llm-manager-close');D.sleep(.25)
   check(not feed.visible,'closing Agent panel preserves externally hidden host');feed.visible=true
  end
 end,debug.traceback)
 for _,n in ipairs(fixtures)do if n.parent then n:removeFromParent(true)end end
 local modal=D.Director.systemUI:getChildByTag('mobile-llm-manager');if modal then modal:removeFromParent(true)end
 for k in pairs(package.loaded)do if k:match('Dev[/%.]Mobile')then package.loaded[k]=nil end end
 for k,v in pairs(previousModules)do package.loaded[k]=v end
 D.App.winSize=previousSize
 for _,v in ipairs(hidden)do if v[1].parent then v[1].visible=v[2]end end
 D.Content:save(out..'revision-results.txt',tostring(ok)..'\n'..table.concat(checks,'\n')..'\n'..tostring(err))
 print('Go revision check '..tostring(ok)..' '..#checks..' checks');if not ok then print(err)end
end)
