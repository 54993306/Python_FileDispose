--
-- Author: Nong Jinxia
-- Date: 2017-04-07 09:07:40
--

function rPrint(s, l, i)
	l = (l) or 100; i = i or "";
	if (l < 1) then print(" Error: Item limit reached."); return l - 1 end;

	local ts = type(s)
	if (ts ~= "table") then print(i, ts, s); return l - 1 end

	print(i, ts);

	for k, v in pairs(s) do
		l = rPrint(v, l, i .."\t [" .. tostring(k) .. "]");
		if (l < 0) then break end
	end
	return l
end

function debugDraw(node, color)
	local drawNode = cc.DrawNode:create()
	local size = node:getContentSize()
	local poses = {cc.p(0, 0), cc.p(size.width, 0), cc.p(size.width, size.height), cc.p(0, size.height)}
	if color == nil then
		color = cc.c4f(0, 1, 0, 0.5)
	end
	drawNode:drawSolidPoly(poses, 4, color)
	drawNode:setPosition(cc.p(0, 0))
	node:addChild(drawNode, 1000)
end