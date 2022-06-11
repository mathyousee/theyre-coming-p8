pico-8 cartridge // http://www.pico-8.com
version 36
__lua__

function _init()
 mode="splash"
 flash=1
 highscore=0
end

function _draw()

 if mode=="play" then
  draw_play()
 elseif mode=="level" then
  draw_level()
 elseif mode=="splash" then
  draw_splash()
 elseif mode=="over" then
  draw_over()
 end

end

function _update()
 
 if mode=="play" then
  update_play()
 elseif mode=="level" then
  update_level()
 elseif mode=="splash" then
  update_splash()
 elseif mode=="over" then
  update_over()
 end
 
end


function startgame()
 cls(0)
 l=1
 lsm=0
 p={s=2,x=64,y=64,dx=0,dy=0,m=0,f={s=4,smin=4,smax=7},fy=4,l=4,nb=0,sw=7}
 pb={}
 pw={cd=10,d=1} --player active weapon
 sw={q=2,d=10} --secondary weapon
 score=0 --score
 stars={}
 initstarfield()
 init_enemies()
 enemies={}
 flashes={}
 init_level()
 -- add(flashes,{x=30,y=30,r=1,dr=1,mr=3})
 -- add(enemies,{x=60,y=5,dx=0,dy=1,s=9,sw=7,sh=7,smin=9,smax=13,en=3})
 -- add(enemies,{x=40,y=5,dx=0,dy=2,s=9,sw=7,sh=7,smin=9,smax=13,en=3})
 -- add(enemies,{x=110,y=-50,dx=-.3,dy=1.3,s=25,sw=7,sh=7,smin=25,smax=28,en=1})
end

function init_level()
 p.x=64
 p.y=64
 p.dx=0
 p.dy=0
 lsm+=.2
 pb={}
 enemies={}
 flashes={}
 nextenemy=30
 levelcountdown=120
end

function init_enemies()
 etypes={}
 add(etypes,{s=25,dx=.15,dy=1.5,sw=7,sh=7,smin=25,smax=28,en=1})
 add(etypes,{s=25,dx=-.15,dy=1.5,sw=7,sh=7,smin=25,smax=28,en=2})
 add(etypes,{s=9,dx=0,dy=2,sw=7,smin=9,smax=13,en=3})
 add(etypes,{s=9,dx=0,dy=3,sw=7,smin=9,smax=13,en=4})
 add(etypes,{s=41,dx=0,dy=3.5,sw=7,smin=41,smax=44,en=5})

end


-->8
--player functions

--move

function pmove() --move player

 --reset to no movement
 p.dx=0
 p.s=2
 p.dy=0
 p.fy=4
 
 --check left
 if btn(0) then
  p.dx=-2
  p.s=1
 end
 --check right
 if btn(1) then
  p.dx=2
  p.s=3
 end
 --check down
 if btn(3) then
  p.dy=2
  p.fy=2
 end
 --check up
 if btn(2) then
  p.dy=-2
  p.fy=6
 end

 --move horizontally and vertically
 p.x+=p.dx
 p.y+=p.dy
 
 --don't go off the screen
 if(p.x>=120) then
  p.x=120
 elseif (p.x<=0) then
  p.x=0
 end

 if(p.y>=120) then
  p.y=120
 elseif (p.y<=0) then
  p.y=0
 end

end

--shoot

function pshoot() --fire weapon

--adjust counters
 p.m-=1
 if p.nb >0 then p.nb-=1 end --next bullet countdown

--move all player bullets
 for i in all (pb) do
  i.y+=-6
  --check for collisions
  for b in all (enemies) do
   if collide(i,b) then
    if b.en>2 then
     sfx(1)
     del(enemies,b)
     del(pb,i)
     add(flashes,{x=b.x,y=b.y,r=1,dr=1,mr=3})
     score+=100
    else
     del(pb,i)
    end
   end
  end
 end
 

 --check for more shots
  
 if btn(5) and p.nb <=0  then
  add(pb,{s=33,x=p.x,y=p.y,sw=7,sh=7})
  p.m=4
  p.nb=pw.cd
  sfx(0)

 end

end

function pflame() 
 --cycle between flame frames
 animate(p.f)
 --p.f+=1
 --if p.f>7 then p.f=4 end
end

function spawnenemies()
 if nextenemy<=0 then
   local myrand=ceil(rnd(5))
   local newenemy=etypes[myrand]
   add(enemies,
    {
     x=rnd(120),
     y=-10,
     dx=newenemy.dx+lsm,
     dy=newenemy.dy+lsm,
     s=newenemy.s,
     sw=newenemy.sw,
     smin=newenemy.smin,
     smax=newenemy.smax,
     en=myrand
    }
   )
   nextenemy=rnd(15)
 end
 nextenemy-=1
end

-->8
--tools

function drawsprite(ispr)
 spr(ispr.s,ispr.x,ispr.y)
end

function animate(thing)
 thing.s+=1
 if thing.s>thing.smax then thing.s=thing.smin end
end

function collide(a,b)
 local al=a.x
 local ar=a.x+a.sw
 local at=a.y
 local ab=a.y+a.sw
 local bl=b.x
 local br=b.x+b.sw
 local bt=b.y
 local bb=b.y+b.sw
 
 if(al>br) then
  return false
 elseif ar<bl then
  return false
 elseif at>bb then
  return false
 elseif ab<bt then
  return false
 else return true
 end

end
-->8
--graphics

--starfield

function initstarfield()
 for i=1,100 do
  add(stars,{x=flr(rnd(127)),y=flr(rnd(127)),s=rnd(2)+0.5})
 end
end

function drawstarfield()
 for i in all (stars) do
  local c=6
  if i.s < 1.0 then
   c=1
  elseif i.s < 1.8 then
   c=13
  end
  pset(i.x,i.y,c)
 end
end

function animatestars()
 for i in all (stars) do
  i.y+= i.s
  if i.y >128 then
   i.y-=128
   i.x=flr(rnd(127))
  end
 end
end

--player

function drawp()
 spr(p.f.s,p.x,p.y+p.fy)--flame
 
 drawsprite(p)
 --draw bullets
 for i in all (pb) do
  drawsprite(i)
  if i.y <0 then del(pb,i) end
 end
 --draw muzzle flash
 if (p.m>0) then
  circfill(p.x+2,p.y+3,1,7)
  circfill(p.x+5,p.y+3,1,7)
 end

end

--enemies

function drawenemies()
 for i in all (enemies) do
  drawsprite(i)
  --spr(i.s,i.x,i.y)
 end
end

--hud

function drawhud()

 --score

 print("score: "..score,45,2,7)

 --hearts

 for i=1,4 do
  spr(14,i*9-5,1)
 end

 for i=1,p.l do
  spr(15,i*9-5,1)
 end

 --bombs

 --for i=1,3 do
 -- spr(30,i*9+89,1)
 --end

 for i=1,sw.q do
  spr(31,i*9+89,1)
 end

 for i in all (flashes) do
  print(i.r)
 end

end

--color blink

function blink()
 flash+=1
 
 local banim={5,5,6,6,7,7,6,6,5,5}
  
 if flash>#banim then
  flash=1
 end
 
 return banim[flash]
 
end

function animateflashes()
 for i in all (flashes) do
  circfill(i.x,i.y,i.r,blink())
  i.r+=i.dr
  if i.r>=i.mr then i.dr=i.dr*-1 end
  if i.r<=0 then del(flashes,i) end
 end
end
-->8
--update states


function update_play()
 pmove()
 pshoot()
 pflame()
 animatestars()
 update_enemies()
 if levelcountdown>=0 then
  levelcountdown-=1
  spawnenemies()
 elseif #enemies > 0 then
  
 else
  mode="level"
  l+=1
  init_level()
 end
 if p.l<=0 then mode="over" end
end

function update_level()
 if levelcountdown <=0 then
  mode="play"
  levelcountdown=300
 else
  animatestars()
  levelcountdown-=1
 end
end

function update_splash()
 if btnp(4) or btnp(5) or btnp(⬅️) or btnp(⬆️) or btnp(➡️) or btnp(⬇️) then
  mode="level"
  startgame()
 end
end

function update_over()
 if score > highscore then highscore=score end
 if btnp(⬅️) and btnp(➡️) then
  mode="splash"
 end
end

function update_enemies()
 for i in all (enemies) do
  --change sprite & loop
  i.s+=0.2 
  if i.s>i.smax then i.s=i.smin end
  --change x
  i.x+=i.dx
  --change y & check visibility
  i.y+=i.dy 
  if i.y >128 then del(enemies,i) end
  if collide(p,i) then 
   p.l-=1
   sfx(1)
   if i.en>2 then
    del(enemies,i)
   end
  end
 end
 

end



-->8
--drawstates

function draw_play()
 cls(0)
 
 drawstarfield()
 drawp()
 drawhud()
 drawenemies()
 animateflashes()
end

function draw_level()
 cls(0)
 drawstarfield()
 print("get ready",45,40,12)
 print("level "..l,48,80,blink())
end

function draw_splash()
 cls(1)
 print("they're coming!",35,40,12)
 print("high score: "..highscore,35,60,7)
 print("press any button to start",15,80,blink())
end

function draw_over()
 cls(8)
 print("game over",30,40,12)
 print("your score was "..score)
 print("press ⬅️➡️ buttons to restart",6,80,blink())
end
-->8


--variable definitions

--[[
 p.:player variable
   s:active sprite
   l:life meter
   x:x position
   y:y position
   dx:change in x
   dy:change in y
   m:muzzle flash counter
   f:ship flame sprite array
   fy:ship flame y offset
   nb:next bullet
 pw.:player weapon variable
   cd:cool down
   d:damage
 sw.:secondary weapon variable
   q:qty in inventory
   d:damage
 pb.:player bullet array
   s:speed
   x:x position
   y:y position
 score:score
]]

__gfx__
00000000033000000003300000000330000000000000000000000000000000000099990000033000000330000003300000033000000000000ee00ee008800880
0000000003300000000330000000033000000000000000000000000000000000099999900033330000333300003333000033330000000000e00ee00e88888888
0070070000330000000330000000330000a88a0000a77a0000a99a0000a98a0099999999033ff330033f6330033663300336f33000000000e000000e88888888
000770000b33b00000b33b00000b33b000a98a0000a87a0000a97a0000a99a0099999949330ff033330ef033330ee033330fe03300000000e000000e88888888
000770000b33b00000b33b00000b33b000a99a0000a88a0000a78a0000a97a009999944903333330033333300333333003333330000000000e0000e008888880
007007000bbbbb000bbbbbb000bbbbb0000990000009800000088000000770009994499900b00b0000b00b0000b00b0000b00b000000000000e00e0000888800
0000000000999b000b9999b000b9990000099000000990000008800000087000099999900bb00bb000bb0bb000b00b000bb0bb0000000000000ee00000088000
0000000000909000009009000009090000000000000000000000800000080000009999000b0000b0000b00b00bb00bb00b00b000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000999900009999000099990000999900000000000055550000111100
0000000000000e000000000000000000000000000000000000000000000000000000000009999990099999900999499009999990000000000500005001dddd10
00000000002e2200000000000000000000000000000000000000000000000000000000009999999999999999999449999999449900000000500000051dd88dd1
000000000e222220000000000000000000000000000000000000000000000000000000009999994994499999994499999999944900000000500000051d8998d1
000000000e220220000000000000000000000000000000000000000000000000000000009999944994499999994999999999994900000000500000051d8998d1
0000000000e222e0000000000000000000000000000000000000000000000000000000009994499999444999999999999999999900000000500000051dd88dd1
000000000000e0000000000000000000000000000000000000000000000000000000000009999990099499900999999009999990000000000500005001dddd10
00000000000000000000000000000000000000000000000000000000000000000000000000999900009999000099990000999900000000000055550000111100
00000000000000000000000000000000000220000000000000000000000000000000000000aa890008a8898000aa8900000a8000000000000000000000000000
0000000000a00a0000900900008008000222222000000000000000000000000000000000009a9a00008a9a00009a9a00000a9000000000000000000000000000
000000000a7aa7a009a99a900e98e98022288222000000000000000000000000000000000059950000598500005995000059a500000000000000000000000000
00000000a070070a90a00a09e090090e208008020000000000000000000000000000000000555500005555000055550000555500000000000000000000000000
000000000070070000a00a00007007000070070000000000000000000000000000000000c111111cc111111cc111111cc111111c000000000000000000000000
000000000000000000a00a00007007000070070000000000000000000000000000000000cc1111cccc1111cccc1111cccc1111cc000000000000000000000000
0000000000000000000000000000000000700700000000000000000000000000000000000cc11cc00cc11cc00cc11cc00cc11cc0000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000cc000000cc000000cc000000cc000000000000000000000000000
__sfx__
000100003705034050310502f0502a05026050230501e0501905014050110500f0500d0500b050090500705006050040500305000050000500100000000000000000000000000000000000000000000000000000
000200002d6502c6502b6502c6502a65026650226501c65018650116500c650086500665002650006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb120000087500b7500d7500e750107501375015750177501a7501d7501f750217502375024750217501f7501d7501b7501a7501b7501d7501f75021750237502575026750257502575026750277502875029750
