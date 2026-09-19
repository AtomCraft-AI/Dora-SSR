-- Run with Dora CLI against the repository Assets directory; results and frames go to writablePath/go-ui-motion.
local D=require('Dora')
local previousModules={}
for k,v in pairs(package.loaded) do if k:match('Dev[/%.]Mobile') then previousModules[k]=v;package.loaded[k]=nil end end
for _,name in ipairs({'settings','back','more','down','exit','plus','code','remix','files','changes','logs','swap','close','next','up','stop','dropdown'}) do D.Cache:unload('Image/GoUI/icon-'..name..'.png') end
local Feed=require('Dev/Mobile/Feed')
local find=require('Dev/Mobile/Gamepad').findGamepadNode
local out=D.Path(D.Content.writablePath,'go-ui-motion')..'/'
D.Content:mkdir(out)
local checks={}
local function check(ok,text) assert(ok,text);checks[#checks+1]=text end
local function shot(name) D.App:saveScreenshot(out..name..'.tga');D.sleep(0.04) end
D.thread(function()
 local hidden,feed={},nil
 D.Director.systemUI:eachChild(function(n) if n.tag=='mobile-feed' or n.tag=='mobile-remix' then hidden[#hidden+1]={n,n.visible};n.visible=false end;return false end)
 local ok,err=xpcall(function()
  local played,current=0,nil
  local entries={}
  for i=1,3 do entries[i]={id='motion'..i,title='交互检查 '..i,description='连续拖动、回弹与入槽',kind='local',bannerFile='Image/banner.jpg'} end
  feed=Feed.startMobileFeed({getLocalEntries=function()return entries end,getDiscoverEntries=function()return {{id='discover',title='发现',kind='discover'}} end,onCurrentEntryChanged=function(e)current=e.id end,onPlay=function()played=played+1 end,onRemix=function()end,onSwitchMode=function()end,createProject=function()return {success=false,error='test'}end})
  D.sleep(0.3);shot('motion-idle')
  local button=find(feed,'mobile-feed-create');local bx,by=button.x,button.y
  button:emit('TapBegan');D.sleep(0.06)
  local visual=find(button,'go-press-visual')
  check(visual and visual.scaleX<1 and visual.scaleX>0.93,'button artwork compresses during press')
  check(button.x==bx and button.y==by and button.scaleX==1,'press keeps control hit bounds stable')
  shot('motion-pressed');button:emit('TapEnded');D.sleep(0.23)
  check(math.abs(visual.scaleX-1)<0.001,'button releases to original scale')
  find(feed,'mobile-feed-settings'):emit('Tapped');D.sleep(0.06)
  local menu=find(feed,'mobile-feed-settings-menu')
  check(menu.anchor.x==1 and menu.anchor.y==1 and menu.scaleX<1.1,'popover expands from top-right trigger')
  find(feed,'mobile-feed-settings'):emit('Tapped');D.sleep(0.23)
  check(not find(feed,'mobile-feed-settings-menu'),'interrupted popover closes without leftover overlay')
  find(feed,'mobile-feed-settings'):emit('Tapped');D.sleep(0.34);shot('motion-settings')
  find(feed,'mobile-feed-settings'):emit('Tapped');D.sleep(0.23)
  find(feed,'mobile-feed-scene-toggle'):emit('Tapped');D.sleep(0.08)
  check(current=='discover' and find(feed,'mobile-feed-cartridge').scaleX<1.05,'tab switch enters the destination feed with animated card')
  D.sleep(0.45);check(math.abs(find(feed,'mobile-feed-cartridge').scaleX-1)<0.001,'tab transition settles at original scale')
  find(feed,'mobile-feed-scene-toggle'):emit('Tapped');D.sleep(0.5)
  check(current=='motion1','switching back restores local selection')
  local scene=find(feed,'mobile-feed-scene');local card=find(feed,'mobile-feed-cartridge');local slot=find(feed,'mobile-feed-slot');local cx,cy=card.x,card.y
  scene:emit('TapBegan');D.sleep(0.18);scene:emit('TapMoved',{delta=D.Vec2(-60,0)})
  check(card.x<cx and card.angle>0 and slot.opacity>0,'left drag moves and tilts card while revealing slot')
  shot('motion-drag');local x,angle,alpha=card.x,card.angle,slot.opacity
  scene:emit('TapEnded')
  check(math.abs(card.x-x)<0.01 and slot.opacity>0,'release preserves current pose and visible slot')
  D.sleep(0.08);check(card.x>x and card.x<cx and slot.opacity>0,'cancel interpolates card and slot instead of snapping')
  shot('motion-cancel');local interrupted=card.x
  scene:emit('TapBegan');check(math.abs(card.x-interrupted)<0.01,'regrab preserves interrupted return position')
  scene:emit('TapMoved',{delta=D.Vec2(-15,0)});scene:emit('TapEnded');D.sleep(0.28)
  check(math.abs(card.x-cx)<0.01 and math.abs(card.angle)<0.01 and slot.opacity<0.001,'cancel restores complete idle pose')
  scene:emit('TapBegan');scene:emit('TapMoved',{delta=D.Vec2(0,160)});scene:emit('TapEnded');D.sleep(0.4)
  check(current=='motion2','vertical swipe advances feed after settle')
  scene=find(feed,'mobile-feed-scene');card=find(feed,'mobile-feed-cartridge');slot=find(feed,'mobile-feed-slot')
  scene:emit('TapBegan');scene:emit('TapMoved',{delta=D.Vec2(-110,0)});local startX=card.x;scene:emit('TapEnded')
  check(math.abs(card.x-startX)<0.01,'insertion starts at dragged pose')
  D.sleep(0.18);shot('motion-turn');check(card.angleY > 20 and card.angleY < 68 and card.angle > 2,'insertion tilts counterclockwise before aligning to slot')
  D.sleep(0.35);shot('motion-seat');check(math.abs(card.x-D.App.safeArea.left-131.5)<10 and math.abs(card.y-cy)<0.1,'terminal pose sits at left slot mouth')
  check(played==0,'seated pose remains visible before launching')
  D.sleep(0.25);check(played==1,'insertion invokes play once')
  feed:removeFromParent(true);feed=nil
  local originalDora=package.loaded.Dora
  for k in pairs(package.loaded) do if k:match('Dev[/%.]Mobile[/%.]Feed$') or k:match('Dev[/%.]Mobile[/%.]Motion$') then package.loaded[k]=nil end end
  package.loaded.Dora=setmetatable({App=setmetatable({reducedMotion=true},{__index=D.App})},{__index=D})
  local ReducedFeed=require('Dev/Mobile/Feed')
  local reducedPress=require('Dev/Mobile/Motion').pressFeedback
  package.loaded.Dora=originalDora
  local control=D.Node();control.size=D.Size(40,40);control:addTo(D.Director.systemUI);reducedPress(control)
  control:emit('TapBegan');D.sleep(0.02)
  check(find(control,'go-press-visual').scaleX==1,'reduced motion disables press scaling');control:removeFromParent(true)
  local reducedPlayed=0
  feed=ReducedFeed.startMobileFeed({getLocalEntries=function()return entries end,getDiscoverEntries=function()return {}end,onPlay=function()reducedPlayed=reducedPlayed+1 end,onRemix=function()end})
  scene=find(feed,'mobile-feed-scene');scene:emit('TapBegan');scene:emit('TapMoved',{delta=D.Vec2(-110,0)})
  check(find(feed,'mobile-feed-cartridge').angle==0,'reduced motion disables drag tilt')
  scene:emit('TapEnded');check(reducedPlayed==1,'reduced motion launches without insertion delay')
  feed:removeFromParent(true);feed=nil
 end,debug.traceback)
 if feed and feed.parent then feed:removeFromParent(true) end
 for _,item in ipairs(hidden) do if item[1].parent then item[1].visible=item[2] end end
 for k in pairs(package.loaded) do if k:match('Dev[/%.]Mobile') then package.loaded[k]=nil end end
 for k,v in pairs(previousModules) do package.loaded[k]=v end
 D.Content:save(out..'motion-results.txt',tostring(ok)..'\n'..table.concat(checks,'\n')..'\n'..tostring(err))
 print('Go motion check: '..tostring(ok)..' ('..#checks..' assertions). Results: '..out..'motion-results.txt')
 if not ok then print(err) end
end)
