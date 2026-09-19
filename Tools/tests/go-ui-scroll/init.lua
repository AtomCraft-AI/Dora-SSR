-- Reproduce interrupted scroll gestures without issuing model requests.
local D=require('Dora')
local previous={}
for k,v in pairs(package.loaded)do if k:match('Dev[/%.]Mobile')then previous[k]=v;package.loaded[k]=nil end end
local Remix=require('Dev/Mobile/Remix')
local find=require('Dev/Mobile/Gamepad').findGamepadNode
local out=D.Path(D.Content.writablePath,'go-ui-scroll')..'/'
D.Content:mkdir(out)
D.thread(function()
 local hidden={};D.Director.systemUI:eachChild(function(n)if n.tag=='mobile-feed' or n.tag=='mobile-remix'then hidden[#hidden+1]={n,n.visible};n.visible=false end;return false end)
 local h,checks=nil,{}
 local function check(value,message)assert(value,message);checks[#checks+1]=message end
 local ok,err=xpcall(function()
  local session={id=999,title='Scroll regression',projectRoot='',kind='main',rootSessionId=999,memoryScope='',workMode='code',status='RUNNING',currentTaskId=999,currentTaskStatus='RUNNING',createdAt=0,updatedAt=0}
  local detail={success=true,session=session,messages={},steps={},relatedSessions={},checkpoints={},hasActivePlan=false}
  for i=1,60 do detail.messages[#detail.messages+1]={id=i,sessionId=999,role=i%2==1 and 'user' or 'assistant',content='滑动中保留阅读位置 '..i..'\n这是用于验证会话刷新的消息。'}end
  local services={createSession=function()return {success=true,session=session}end,getSession=function()return detail end,setWorkMode=function()return {success=true}end,sendPrompt=function()error('unexpected model request')end,respondQuestionnaire=function()return {success=false}end,stopSessionTask=function()end,getActiveLLMConfig=function()return {success=false}end,getLLMConfig=function()return {success=false}end,getLLMConfigSummaries=function()return {{id=999,name='测试',model='mock'}}end}
  h=Remix.startMobileRemix({entry={id='scroll-test',title='Scroll regression'},services=services,onBack=function()end,onPlay=function()end})
  D.sleep(.3)
  local observer=find(h,'remix-focus-observer')
  observer:emit('TapBegan',{location=D.Vec2(150,300)})
  observer:emit('TapMoved',{location=D.Vec2(152,400)})
  -- Deliberately omit TapEnded, as happens if another touch handler consumes release.
  session.status='IDLE';session.currentTaskStatus='STOPPED'
  D.sleep(.55)
  check(find(h,'remix-stop')==nil and find(h,'remix-send')~=nil,'vertical gesture without release cannot freeze session status')
  session.status='RUNNING';session.currentTaskStatus='RUNNING';D.sleep(.35)
  observer=find(h,'remix-focus-observer');observer:emit('TapBegan',{location=D.Vec2(150,300)})
  observer:emit('TapMoved',{location=D.Vec2(100,301)})
  session.status='IDLE';session.currentTaskStatus='STOPPED';D.sleep(.85)
  check(find(h,'remix-stop')==nil,'interrupted horizontal gesture expires instead of blocking refresh')
  check(math.abs(find(h,'remix-page').x)<.01,'interrupted swipe restores page position')
  local scroll=find(h,'remix-scroll');scroll.offset=D.Vec2.zero
  local before=scroll.offset.y
  detail.messages[#detail.messages+1]={id=61,sessionId=999,role='assistant',content='任务已完成。'}
  D.sleep(.4);check(math.abs(scroll.offset.y-before)<2,'message arrival preserves reader position')
  local started=D.App.runningTime
  for i=1,120 do scroll.offset=D.Vec2(0,(i%20)*10)end
  check(scroll.offset.y==0,'scroll event burst retains finite expected offset')
  checks[#checks+1]=string.format('120 scroll updates: %.2f ms',(D.App.runningTime-started)*1000)
  find(h,'remix-latest'):emit('Tapped');check(not find(h,'remix-latest').visible,'return to latest still works')
 end,debug.traceback)
 if h and h.parent then h:removeFromParent(true)end
 for k in pairs(package.loaded)do if k:match('Dev[/%.]Mobile')then package.loaded[k]=nil end end
 for k,v in pairs(previous)do package.loaded[k]=v end
 for _,v in ipairs(hidden)do if v[1].parent then v[1].visible=v[2]end end
 D.Content:save(out..'results.txt',tostring(ok)..'\n'..table.concat(checks,'\n')..'\n'..tostring(err))
 print('Go scroll regression '..tostring(ok)..' '..#checks..' checks')
end)
