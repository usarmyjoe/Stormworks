-- Author: usarmyjoe
-- GitHub: https://github.com/usarmyjoe
-- Workshop: https://steamcommunity.com/profiles/76561198116812183/

--Feel free to reuse. I am but a mere mortal. I'm happy to hear what you improved so i may learn. Just dont copy and call it yours. Thanks!--
-- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--      By Nameous Changey (Please retain this notice at the top of the file as a courtesy; a lot of effort went into the creation of these tools.)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues
--- 	Please try to describe the issue clearly, and send a copy of the /_build/_debug_simulator_log.txt file, with any screenshots (thank you!)


--- With LifeBoatAPI; you can use the "require(...)" keyword to use code from other files!
---     This lets you share code between projects, and organise your work better.
---     The below, includes the content from _simulator_config.lua in the generated /_build/ folder
--- (If you want to include code from other projects, press CTRL+COMMA, and add to the LifeBoatAPI library paths)
require("_build._simulator_config")
local iN=input.getNumber
local oN=output.setNumber
local oB=output.setBool
local iB=input.getBool
local skim=property.getNumber("skim alt")
local top=property.getNumber("top alt")
local radarOn=property.getNumber("radarOn")
local m=math
local atan=m.atan
local sqrt=m.sqrt
local pi=m.pi
local pi2=m.pi * 2
local abs=m.abs
local sin=m.sin
local cos=m.cos
local deg=m.deg
local rad=m.rad
local asin=m.asin
local tx,ty,tz=0,0,0
local rd,re,rb=0,0,0
local phase=0
---@diagnostic disable-next-line: redundant-value
local sx,sy,sz,sc,st,bearing,altitude,distance,alt,galt,w,tlaunch,wait,scd,sct,Nx,Ny,Nz=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
local duration=12
local on,terminal,atype,term,launch,tgt,xyz=false,false,false,false,false,false,false
local easy={}
function onTick()
	xyz=iB(5)
	sx=iN(1)
	sy=iN(2)
	sz=iN(3)
	sc=iN(4)
	scd=((1+sc)*360)%360
	st=iN(5)
	tgt=iB(2)
	if not launch then
		if xyz then
			tx=iN(6)
			ty=iN(7)
			tz=iN(8)
		else
			distance=iN(6)
			bearing=iN(7)/360-sc
			altitude=atan(sz-iN(8),distance)/pi2
			tx,ty,tz=getCoords(distance,bearing,altitude,sx,sy,sz,sc,st)
		end
	end
	atype=iB(3)
	if iB(4) or launch then
		launch=true
		if tgt then
			rd=iN(9)
			rb=iN(10)
			re=iN(11)
			mx=iN(12)
			my=iN(13)
			distance=rd
			bearing=rb * 1.32
			altitude=re
			tx,ty,tz=getCoords(distance,bearing,altitude,sx,sy,sz,sc,st)
			if distance < 200 then -- strike altitude
				phase=5
				alt=tz
			else
				if atype then -- top attack
					alt=tz + top
					phase=41
				else -- skim
					alt=tz + skim
					phase=42
				end
			end
			oN(21, rd) --extra data
			oN(22, rb) --extra data
			oN(23, re) --extra data
			oN(24, mx) --extra data
			oN(25, my) --extra data
		else
			distance,bearing,altitude=getBearing(tx,ty,tz,sx,sy,sz,sc,st)
	    	if atype then --top attack
				alt=tz + top
				phase=21
				if distance < radarOn then --radar enable
					phase=31
					oB(2, true)
				end
			else --sea skim
				alt=tz + skim
				phase=22
				if distance < radarOn then --radar enable
					phase=32
					oB(2, true)
				end
			end
		end
		if distance > 200 then
			if wait%20 == 0 then -- ease altitude changes
				for i=1,duration do
					easy[i] = ease(i,sz,alt-sz,duration)
				end
			end
		end
		alt=easy[1]
	else -- not launched but want data sent back to console
		distance,bearing,altitude=getBearing(tx,ty,tz,sx,sy,sz,sc,st)
		alt=tz + skim
		phase=1
	end
	oB(1, true)
	oB(3, tgt)
	oN(1, distance)
	oN(2, bearing)
	oN(3, alt)
	oN(4, phase)
	oN(5, scd)
	oN(11, tx) --extra data
	oN(12, ty) --extra data
	oN(13, tz) --extra data
	wait=wait + 1
end
function getBearing(Btx,Bty,Btz,Bsx,Bsy,Bsz,Bsc,Bst)
	local Chx,Chy,Chz,B,Bd,rB,D2,D3,E
	Chx=Bsx - Btx
	Chy=Bsy - Bty
	Chz=Bsz - Btz
	B=(atan( Chx, Chy ))/pi2 --in turns
	D2=sqrt( Chx^2 + Chy^2 )
	D3=sqrt( Chx^2 + Chy^2 + Chz^2)
	E=(atan( Chz, D3))/pi2 -- in turns
	if Bsy > Bty then
		B=B + .5
	end
	rB=(B + Bsc + 1.5)%1-.5
	return D3,rB,E
end
function getCoords(Ctr,Cta,Cte,Csx,Csy,Csz,Csc,Cst)
	local Nx, Ny, Nz, A, Z, C
	A=(Cta * pi2) --radians
	C=(Csc * pi2) -- radians
	Z=((Cte + Cst) * pi2) --radians
	Nx=(sin(A+C) * Ctr * cos(Z)) + Csx
	Ny=(cos(A+C) * Ctr * cos(Z)) + Csy
	Nz=(sin(Z) * Ctr) + Csz
	return Nx,Ny,Nz
end
--from https://github.com/EmmanuelOga/easing
function ease(t, b, c, d)
		return c * t / d + b
end