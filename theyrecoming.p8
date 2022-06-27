pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--they're coming
--mathyousee

function _init()
 _update=update_splash
 _draw=draw_splash
 cartdata("usee_theyrecoming")
 highscore=dget(0)
 flash=1
 t=0
 parts={}
 shwaves={}
 bombs={}
--  add(bombs,{x=64,y=64,r=10,t=0,tr=50,c=7})
 stars={}
  initstarfield()
 weapons={}
  add(weapons,{cd=4,d=1,sp=33,swc=10,id=1})
  add(weapons,{cd=2,d=1,sp=34,swc=10,id=2})
  add(weapons,{cd=8,d=2,sp=35,swc=9,id=3})
  add(weapons,{cd=12,d=5,sp=36,swc=8,id=4})
 etypes={}
	 add(etypes,{s=25,dx=.15,dy=1.5,sw=7,sh=7,smin=25,smax=28,hp=10,en=1})
	 add(etypes,{s=25,dx=-.15,dy=1.5,sw=7,sh=7,smin=25,smax=28,hp=8,en=2})
	 add(etypes,{s=9,dx=0,dy=2,sw=7,smin=9,smax=13,hp=1,en=3})
	 add(etypes,{s=9,dx=0,dy=3,sw=7,smin=9,smax=13,hp=1,en=4})
	 add(etypes,{s=41,dx=0,dy=3.5,sw=7,smin=41,smax=44,hp=2,en=5})  
 utypes={}
  add(utypes,{sp=17,utype="pw",sw=8,id=1})
  add(utypes,{sp=18,utype="pw",sw=8,id=2})
  add(utypes,{sp=19,utype="pw",sw=8,id=3})
  add(utypes,{sp=20,utype="pw",sw=8,id=4})
  add(utypes,{sp=21,utype="sq",sw=8,id=0})
  add(utypes,{sp=22,utype="life",sw=8,id=0})

end

function startgame()
 cls(0)
 t=0
 l=1
 lsm=0
 p={s=2,x=64,y=64,dx=0,dy=0,m=0,f={s=4,smin=4,smax=7},fy=4,l=4,nb=0,sw=7,inv=0}
 pb={}
 set_pweapon(1) --player active weapon
 sw={q=2,d=10} --secondary weapon
 score=0 --score
 enemies={}
 flashes={}
 init_level()
end

function init_level()
 p.x=64
 p.y=64
 p.dx=0
 p.dy=0
 p.inv=0
 lsm+=.2
 pb={}
 enemies={}
 flashes={}
 powerups={}
-- add(powerups,{x=30,y=30,sp=19,sw=8,utype="pw",id=3})
-- add(powerups,{x=50,y=50,sp=21,sw=8,utype="sq",id=3})
-- add(powerups,{x=90,y=90,sp=22,sw=8,utype="life"})
 nextenemy=30
 levelcountdown=120
end



-->8
--player functions

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
    b.hp-=pw.d
    smol_shwave(b.x+4,b.y+8,i.swc)
    if b.hp<=0 then
     sfx(1)
     explode(i.x+4,i.y+4,4)
     add(flashes,{x=b.x,y=b.y,r=1,dr=1,mr=3})
     
     if rnd(100)>90 then
      gen_powerup(b.x,b.y)
     end
     
     del(enemies,b)
     del(pb,i)
     
     score+=100
    end
   del(pb,i)
   end
  end
 end
 

 --check for more shots
  
 if btn(5) and p.nb <=0  then
  add(pb,{s=pw.sp,x=p.x,y=p.y,sw=7,sh=7,swc=pw.swc})
  p.m=4
  p.nb=pw.cd
  sfx(0)
 end

 --[[debug
 if btnp(4) then
  gen_powerup(p.x,p.y-50)
 end]]

 --check for powerups

 for pu in all (powerups) do
  if collide(p,pu) then
   do_powerup(pu)
   del(powerups,pu)
  end
 end

end

function do_powerup(pow)
 if pow.utype=="pw" then
  set_pweapon(pow.id)
  sfx(4)
 elseif pow.utype=="sq" then
 elseif pow.utype=="life" then
  p.l+=1
  sfx(3)
 end
end

function pflame() 
 --cycle between flame frames
 animate(p.f)
end

function do_enemies()
 for i in all (enemies) do
  --change sprite & loop
  i.s+=0.2 
  if i.s>i.smax then i.s=i.smin end
  
  i.x+=i.dx
  --change y & check visibility
  i.y+=i.dy 
  if i.y >128 then del(enemies,i) end
  if collide(p,i) and p.inv<=0 then 
   explode(p.x,p.y,3)
   p.l-=1
   p.inv=45
   sfx(1)
   if i.en>2 then
    del(enemies,i)
   end
  end
 end
 

end


function set_pweapon(wid)
 for i in all (weapons) do
  if i.id==wid then
   pw={cd=i.cd,d=i.d,swc=i.swc,sp=i.sp}
  end
 end
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

function collideb(a,c)
 --check if dist( allaxy vs cxy)< is c.r
 
 local closest_x=0 closest_y=0
 local sa=0 sb=0 sc=0
 
 closest_x=mid(a.x,a.x+a.sw,c.x)
 closest_y=mid(a.y,a.y+a.sw,c.y)
 if closest_x==c.x and closest_y==c.y then 
  return true 
 else
  sa=(closest_x-c.x)^2
  sb=(closest_y-c.y)^2
  sc=sqrt(sa+sb)
  if sc<c.r then 
   return true
  end
 end
 return false
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
     hp=newenemy.hp,
     en=myrand
    }
   )
   nextenemy=rnd(15)
 end
 nextenemy-=1
end

function explode(expx,expy,expspread)
 local myflash={}
 myflash.x=expx
 myflash.y=expy
 myflash.dx=0
 myflash.dy=0
 myflash.age=0
 myflash.death=10
 myflash.size=10
 add(parts,myflash)
 
 for i=1,22 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 myp.dx=(rnd()-0.5)*expspread
	 myp.dy=(rnd()-0.75)*expspread
	 myp.age=flr(rnd(10))
	 myp.death=30
	 myp.size=1+rnd(2)
	 add(parts,myp)
 end

end

function smol_shwave(shx,shy,shc)
 local mysw={}
 mysw.x=shx
 mysw.y=shy
 mysw.r=1
 mysw.tr=5
 mysw.c=shc
 add(shwaves,mysw) 
end

function big_shwave(shx,shy)
 local mysw={}
 mysw.x=shx
 mysw.y=shy
 mysw.r=1
 mysw.tr=30
 add(shwaves,mysw) 
end

function gen_powerup(pux,puy)
 local r=0 ut={}
 r=ceil(rnd(4+4-p.l))
 ut=utypes[r]
 add(powerups,{x=pux,y=puy,sp=ut.sp,sw=ut.sw,utype=ut.utype,id=ut.id})
end

function blow_bomb(bbx,bby,bbc)
 local mybb={}
 mybb.x=bbx
 mybb.y=bby
 mybb.r=1
 mybb.tr=10
 mybb.c=bbc
 add(bombs,mybb) 
end

function up_bombs()
 for myb in all (bombs) do
  --myb.r+=1
  if myb.r>myb.tr then
   del(bombs,myb)
  end
  --check for collision
  for en in all (enemies) do
   if collideb(en,myb) then
    
    --add points
    del(enemies,en)
    
   end
  end
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

function drawp()
 if p.inv<=0 then
  drawsprite(p)
  spr(p.f.s,p.x,p.y+p.fy)--flame
 else
  if sin(t/5)<0.1 then 
   drawsprite(p) 
   spr(p.f.s,p.x,p.y+p.fy)--flame
  end
 end
 
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

function do_shwaves()
 for mysw in all (shwaves) do
  circ(mysw.x,mysw.y,mysw.r,mysw.c,mysw.c)
  mysw.r+=1
  if mysw.r>mysw.tr then
   del(shwaves,mysw)
  end
 end
end

function drawpow()
 for pow in all (powerups) do
  if sin(time())>0 then
    spr(pow.sp,pow.x,pow.y)
  else
    spr(16,pow.x,pow.y)
  end
 end
end

function do_particles()
 for myp in all(parts) do
  --pset(myp.x,myp.y,7)
  local pc=7
  
  
  if myp.age>20 then pc=5
  elseif myp.age>15 then pc=2 
  elseif myp.age>11 then pc=8 
  elseif myp.age>7 then pc=9
  elseif myp.age>5 then  pc=10
  end
  circfill(myp.x,myp.y,myp.size,pc)
  myp.x+=myp.dx
  myp.y+=myp.dy
  myp.age+=1
  
  myp.dx*=0.9
  myp.dy*=0.9
  
  if myp.age>myp.death then
   myp.size-=0.5
   if myp.size<0 then
    del(parts,myp)
   end
  end
 end
end

function draw_bombs()
 for myb in all (bombs) do
  circ(myb.x,myb.y,myb.r,myb.c,myb.c)
 end
end


-->8
--update states


function update_play()
 t+=1
 pmove()
 pshoot()
 pflame()
 animatestars()
 do_enemies()
 up_bombs()
 if levelcountdown>=0 then
  levelcountdown-=1
  spawnenemies()
 elseif #enemies > 0 then
  --keep playing
 else
--  mode="level"
  _update=update_level
  _draw=draw_level
  l+=1
  init_level()
 end
 if p.inv >0 then p.inv-=1 end --invincible countdown
 if p.l<=0 then 
--  mode="over" 
  _update=update_over
  _draw=draw_over
 end
end

function update_level()
 if levelcountdown <=0 then
--  mode="play"
  _update=update_play
  _draw=draw_play
  levelcountdown=300
 else
  animatestars()
  levelcountdown-=1
 end
end

function update_splash()
 if btnp(4) or btnp(5) or btnp(⬅️) or btnp(⬆️) or btnp(➡️) or btnp(⬇️) then
--  mode="level"  
  _update=update_level
  _draw=draw_level
  startgame()

 end
end

function update_over()
 if score > highscore then 
  highscore=score
  dset(0,highscore)
 end
 if btn(⬅️) and btn(➡️) then
--  mode="splash"
  _update=update_splash
  _draw=draw_splash
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
 do_shwaves()
 do_particles()
 animateflashes()
 draw_bombs()
 drawpow()
 
 --[[debug
 print("pwc"..pw.swc,7)
 for z in all (swaves) do
  print(z.d,z.c)
 end
 ]]--
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
00111100001111000011110000111100001111000000000008800880000000000000000000999900009999000099990000999900000000000055550000111100
0166661001dddd1001dddd1001dddd1001dddd100055550088888888000000000000000009999990099999900999499009999990000000000500005001dddd10
166886611dd88dd11dd88dd11dd88dd11dd88dd1055885508888888800000000000000009999999999999999999449999999449900000000500000051dd88dd1
168668611d8668d11d8aa8d11d8ee8d11d8228d1058998508888888800000000000000009999994994499999994499999999944900000000500000051d8998d1
168668611d8668d11d8aa8d11d8ee8d11d8228d1058998500888888000000000000000009999944994499999994999999999994900000000500000051d8998d1
166886611dd88dd11dd88dd11dd88dd11dd88dd1055885500088880000000000000000009994499999444999999999999999999900000000500000051dd88dd1
0166661001dddd1001dddd1001dddd1001dddd100055550000088000000000000000000009999990099499900999999009999990000000000500005001dddd10
00111100001111000011110000111100001111000000000000000000000000000000000000999900009999000099990000999900000000000055550000111100
00000000000000000000000000000000000220000000000000000000000000000000000000aa890008a8898000aa8900000a8000000000000000000000000000
0000000000a00a0000900900008008000222222000000000000000000000000000000000009a9a00008a9a00009a9a00000a9000000000000000000000000000
000000000a7aa7a009a99a900e98e98022288222000000000000000000000000000000000059950000598500005995000059a500000000000000000000000000
00000000a070070a90a00a09e090090e208008020000000000000000000000000000000000555500005555000055550000555500000000000000000000000000
000000000070070000a00a00007007000070070000000000000000000000000000000000c111111cc111111cc111111cc111111c000000000000000000000000
000000000000000000a00a00007007000070070000000000000000000000000000000000cc1111cccc1111cccc1111cccc1111cc000000000000000000000000
0000000000000000000000000000000000700700000000000000000000000000000000000cc11cc00cc11cc00cc11cc00cc11cc0000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000cc000000cc000000cc000000cc000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888777777888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888888888888888888ff8ff8888228822888222822888888822888888228888
8888778887788ee88eee88ee888ee88ee888ee88ee8e8ee88ee888ee88ee8eeee88881888888888888ff888ff888222222888222822888882282888888222888
888777878778eeee8eee8eeeee8ee8eeeee8ee8eee8e8ee8eee8eeee8eee8eeee88817188888888888ff888ff888282282888222888888228882888888288888
888777878778eeee8eee8eee888ee8eeee88ee8eee888ee8eee888ee8eee888ee88817118188888888ff888ff888222222888888222888228882888822288888
888777878778eeee8eee8eee8eeee8eeeee8ee8eeeee8ee8eeeee8ee8eee8e8ee88817171718888888ff888ff888822228888228222888882282888222288888
888777888778eee888ee8eee888ee8eee888ee8eeeee8ee8eee888ee8eee888ee881177777188888888ff8ff8888828828888228222888888822888222888888
888777777778eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee817177777188888888888888888888888888888888888888888888888888888
11661111117717711111111111111111111111111111111111111111111111111111777777111111111111111111111111111111111111111111111111111111
16111777117111711111111111111111111111111111111111111111111111111111117771111111111111111111111111111111111111111111111111111111
16661111177111771111111111111111111111111111111111111111111111111111117771111111111111111111111111111111111111111111111111111111
11161777117111711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16611111117717711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616661666116616611166111111771166166111111c1c1111166111111cc111111166166611111ccc1ccc111111661616116611111cc11ccc111116661661
161116161616161616161611111111711611161617771c1c11111616177711c11111161116161777111c111c1111161116161611177711c11c1c111111611616
166116661666161616161666111117711611161611111ccc11111616111111c1111116661666111111cc11cc1111166616161611111111c11c1c111111611616
16111616161116161616111611711171161116161777111c11711616177711c11171111616111777111c111c1171111616661611177711c11c1c117111611616
16661616161116611616166117111177116616661111111c1711166611111ccc17111661161111111ccc1ccc171116611666116611111ccc1ccc171116661666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616661666116616611166111111771166166111111111166111111cc111111166166611111ccc1ccc111111661616116611111cc11ccc1111166616611111
1611161616161616161616111111117116111616177711111616177711c11111161116161777111c111c1111161116161611177711c11c1c1111116116161777
1661166616661616161616661111177116111616111111111616111111c1111116661666111111cc11cc1111166616161611111111c11c1c1111116116161111
1611161616111616161611161171117116111616177711711616177711c11171111616111777111c111c1171111616661611177711c11c1c1171116116161777
166616161611166116161661171111771166166611111711166611111ccc17111661161111111ccc1ccc171116611666116611111ccc1ccc1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616661666116616611166111111771166166111111ccc1111166111111ccc11111166166611111ccc1ccc111111661616116611111ccc1111166616611111
161116161616161616161611111111711611161617771c1c111116161777111c1111161116161777111c1c11111116111616161117771c1c1111116116161777
166116661666161616161666111117711611161611111ccc1111161611111ccc111116661666111111cc1ccc111116661616161111111ccc1111116116161111
161116161611161616161116117111711611161617771c1c1171161617771c111171111616111777111c111c11711116166616111777111c1171116116161777
166616161611166116161661171111771166166611111ccc1711166611111ccc17111661161111111ccc1ccc17111661166611661111111c1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
166616661666116616611166111111771166166111111cc11ccc1111166111111ccc11111166166611111ccc1c11111111661616116611111ccc111116661661
1611161616161616161616111111117116111616177711c1111c1111161617771c111111161116161777111c1c11111116111616161117771c1c111111611616
1661166616661616161616661111177116111616111111c11ccc1111161611111ccc111116661666111111cc1ccc111116661616161111111ccc111111611616
1611161616111616161611161171117116111616177711c11c11117116161777111c1171111616111777111c1c1c117111161666161117771c1c117111611616
166616161611166116161661171111771166166611111ccc1ccc1711166611111ccc17111661161111111ccc1ccc171116611666116611111ccc171116661666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111177177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17771171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111771117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17771171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111177177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161616661666116611111177116611111ccc1ccc111116611616111111111cc11ccc11111661161611111cc111111ccc11111166161611111ccc11111166
116116161616161116111111117116111777111c1c111111161616161777111111c11c11111116161616177711c111111c111111161116161777111c11111611
1161166616661661166611111771166611111ccc1ccc1111161611611111111111c11ccc111116161666111111c111111ccc1111166616161111111c11111666
1161111616111611111611711171111617771c11111c1171161616161777111111c1111c117116161116177711c11111111c1171111616661777111c11711116
1161166616111666166117111177166111111ccc1ccc171116661616111111c11ccc1ccc17111666166611111ccc11c11ccc1711166116661111111c17111661
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161616661666116611111177116611111ccc1ccc1111166116161111111111111cc11ccc11111661161611111cc111111ccc11111166161611111ccc1111
116116161616161116111111117116111777111c1c1111111616161617771111111111c11c11111116161616177711c111111c111111161116161777111c1111
1161166616661661166611111771166611111ccc1ccc11111616116111111ccc111111c11ccc111116161666111111c111111ccc1111166616161111111c1111
1161111616111611111611711171111617771c11111c11711616161617771111111111c1111c117116161116177711c11111111c1171111616661777111c1171
1161166616111666166117111177166111111ccc1ccc1711166616161111111111c11ccc1ccc17111666166611111ccc11c11ccc1711166116661111111c1711
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161616661666116611111177116611111ccc11111661161611111ccc11111661161611111ccc11111166161611111ccc1111116616661666166111111ccc
1161161616161611161111111171161117771c1c11111616161617771c1c1111161616161777111c1111161116161777111c1111161116661161161617771c1c
1161166616661661166611111771166611111ccc11111616116111111c1c11111616166611111ccc1111166616161111111c1111166616161161161611111ccc
116111161611161111161171117111161777111c11711616161617771c1c11711616111617771c111171111616661777111c117111161616116116161777111c
116116661611166616611711117716611111111c17111666161611111ccc17111666166611111ccc1711166116661111111c171116611616166616161111111c
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161616661666116611111177116611111ccc11111661161611111ccc11111661161611111ccc11111166161611111ccc1111116616661666166111111ccc
1161161616161611161111111171161117771c1c11111616161617771c1c1111161616161777111c1111161116161777111c1111161116661161161617771c1c
1161166616661661166611111771166611111ccc11111616116111111c1c111116161666111111cc1111166616161111111c1111166616161161161611111ccc
116111161611161111161171117111161777111c11711616161617771c1c1171161611161777111c1171111616661777111c117111161616116116161777111c
116116661611166616611711117716611111111c17111666161611111ccc17111666166611111ccc1711166116661111111c171116611616166616161111111c
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1666161616661666116611111177116611111c1c1cc111111661161611111ccc11111661161611111ccc11111ccc11111166161611111ccc1111116616661666
1161161616161611161111111171161117771c1c11c111111616161617771c1c1111161616161777111c11111c111111161116161777111c1111161116661161
1161166616661661166611111771166611111ccc11c111111616116111111c1c111116161666111111cc11111ccc1111166616161111111c1111166616161161
116111161611161111161171117111161777111c11c111711616161617771c1c1171161611161777111c1111111c1171111616661777111c1171111616161161
116116661611166616611711117716611111111c1ccc17111666161611111ccc17111666166611111ccc11c11ccc1711166116661111111c1711166116161666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111177177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17771171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111771117711111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
17771171117111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111177177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661616166616661166111111771166166611111cc11ccc11111616166616161666166611111c1c1ccc1c1c1c1c11111166161611111ccc1111166616611111
116116161616161116111111117116111616177711c1111c11111616116116161616161117771c1c1c1c1c1c1c1c11111611161617771c1c1111116116161777
116116661666166116661111177116661666111111c1111c111116161161166616661661111111111ccc1c1c111111111666161611111ccc1111116116161111
116111161611161111161171117111161611177711c1111c117116161161111616111611177711111c111ccc111111711116166617771c1c1171116116161777
11611666161116661661171111771661161111111ccc111c171111661161166616111666111111111c111ccc111117111661166611111ccc1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661616166616661166111111771166166611111cc11ccc11111616166616161666166611111c1c1ccc1c1c1c1c11111166161611111ccc1111166616611111
116116161616161116111111117116111616177711c11c1c11111616116116161616161117771c1c1c1c1c1c1c1c11111611161617771c1c1111116116161777
116116661666166116661111177116661666111111c11ccc111116161161166616661661111111111ccc1c1c111111111666161611111ccc1111116116161111
116111161611161111161171117111161611177711c11c1c117116161161111616111611177711111c111ccc111111711116166617771c1c1171116116161777
11611666161116661661171111771661161111111ccc1ccc171111661161166616111666111111111c111ccc111117111661166611111ccc1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661616166616661166111111771166166611111cc11ccc11111616166616161666166611111c1c1ccc1c1c1c1c11111166161611111ccc1111166616611111
116116161616161116111111117116111616177711c11c1c11111616116116161616161117771c1c1c1c1c1c1c1c11111611161617771c1c1111116116161777
116116661666166116661111177116661666111111c11ccc111116161161166616661661111111111ccc1c1c111111111666161611111ccc1111116116161111
116111161611161111161171117111161611177711c1111c117116161161111616111611177711111c111ccc111111711116166617771c1c1171116116161777
11611666161116661661171111771661161111111ccc111c171111661161166616111666111111111c111ccc111117111661166611111ccc1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661616166616661166111111771166166611111ccc1ccc11111616166616161666166611111c1c1ccc1c1c1c1c11111166161611111ccc1111166616611111
1161161616161611161111111171161116161777111c1c1c11111616116116161616161117771c1c1c1c1c1c1c1c11111611161617771c1c1111116116161777
11611666166616611666111117711666166611111ccc1c1c111116161161166616661661111111111ccc1c1c111111111666161611111ccc1111116116161111
11611116161116111116117111711116161117771c111c1c117116161161111616111611177711111c111ccc111111711116166617771c1c1171116116161777
11611666161116661661171111771661161111111ccc1ccc171111661161166616111666111111111c111ccc111117111661166611111ccc1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661616166616661166111111771166166611111ccc1cc111111616166616161666166611111c1c11cc11c11c1c11111166161611111ccc1111166616611111
1161161616161611161111111171161116161777111c11c111111616116116161616161117771c1c1c111c1c1c1c11111611161617771c1c1111116116161777
11611666166616611666111117711666166611111ccc11c1111116161161166616661661111111111ccc1c1c111111111666161611111ccc1111116116161111
11611116161116111116117111711116161117771c1111c111711616116111161611161117771111111c1cc1111111711116166617771c1c1171116116161777
11611666161116661661171111771661161111111ccc1ccc171111661161166616111666111111111cc111cc111117111661166611111ccc1711166616661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
16661616166616661166111111771166166611111ccc1ccc11111616166616161666166611111c1c1c111ccc1ccc1ccc1c1c11111166161611111ccc11111666
1161161616161611161111111171161116161777111c111c11111616116116161616161117771c1c1c1111c11c111c111c1c11111611161617771c1c11111161
11611666166616611666111117711666166611111ccc1ccc111116161161166616661661111111111c1111c11cc11cc1111111111666161611111ccc11111161
11611116161116111116117111711116161117771c111c11117116161161111616111611177711111c1111c11c111c11111111711116166617771c1c11711161
11611666161116661661171111771661161111111ccc1ccc171111661161166616111666111111111ccc1ccc1c111ccc111117111661166611111ccc17111666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888822882888882828882228888888888888888888888888888888888888888888882228222822282228882822282288222822288866688
82888828828282888888882882888828828882828888888888888888888888888888888888888888888888828882888282888828828288288282888288888888
82888828828282288888882882228828822282228888888888888888888888888888888888888888888882228222822282228828822288288222822288822288
82888828828282888888882882828828828288828888888888888888888888888888888888888888888882888288828888828828828288288882828888888888
82228222828282228888822282228288822288828888888888888888888888888888888888888888888882228222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__sfx__
000100003705034050310502f0502a05026050230501e0501905014050110500f0500d0500b050090500705006050040500305000050000500100000000000000000000000000000000000000000000000000000
000200002d6502c6502b6502c6502a65026650226501c65018650116500c650086500665002650006500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb120000087500b7500d7500e750107501375015750177501a7501d7501f750217502375024750217501f7501d7501b7501a7501b7501d7501f75021750237502575026750257502575026750277502875029750
00020000097500875007750077500775007750077500775007750077500875008750097500b7500b7500b7500d7500e750117501375016750187501c750227502a750317503e7503c7502d0002b0002b0002b000
000400002f1502c15028150251502515025150251502615027150291502f150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
