
local c_y = 100
	
groupBox grp_participate "Participate Weights" pos:[10,c_y-20] \
width:360 height:630

CurveControl cuvCtrl pos:[20,c_y] \
width:340 height:260 \
visible:true numCurves:2 \
displayModes:#{1} \
x_range:[-150,150] y_range:[0,100] \
-- commandMode:#move_xy \
-- asPopup:false

listBox lst_weighted "Select weighted bone" pos:[20,c_y+280] \
width:160 height:13 \

comboBox lst_participate "Select participate bone" pos:[200,c_y+280] \
width:160 height:12 \
	
local p_x = 20
local p_y = 580

local ref = 1
local dir = 1

dropDownList ddl1 "Base position use:" pos:[p_x,p_y] \
width:120 height:40 \
items:#("Weighted", "Participate", "Blended", "World")
on ddl1 selected sel do
(
	ref = sel
	if sel == 2 then
	(
		wtAssign_ro.cuvCtrl.displayModes = #{2}
	)
	else if sel == 3 then
	(
		wtAssign_ro.cuvCtrl.displayModes = #{1,2}
	)
	else
	(
		wtAssign_ro.cuvCtrl.displayModes = #{1}
	)
)

radioButtons rdo1 "Direction" pos:[p_x+2,p_y+50] \
width:100 height:60 \
labels:#("x", "y", "z") columns:3 default:1
on rdo1 changed stat do
(
	dir = stat
)

button btn_asn "Assign" pos:[p_x,p_y+50+40] \
width:70 height:30
on btn_asn pressed  do
(
	skin = wt_getSkinModifier()
	
	count = skinOps.GetNumberVertices skin
	
	weights = #()
	for i = 1 to count do
	(
		weights[i] = #()
		for b = 1 to (skinOps.GetVertexWeightCount skin i) do
		(
			w = wt()
			w.i = skinOps.GetVertexWeightBoneID skin i b
			w.w = skinOps.GetVertexWeight skin i b
			append weights[i] w
		)
	)
	
	for i = 1 to count do
	(
		for ii = 1 to weights[i].count do
		(
			if skinOps.GetBoneName skin weights[i][ii].i 0 == b1 then
			(
				skinOps.unNormalizeVertex skin i true
				
				mat1 = (getnodebyname b1).transform
				mat2 = (getnodebyname b2).transform
				
				p = 0
				
				if ref == 4 then
				(
					pos1 = mat1.row4
					pos2 = mat2.row4
					
					percent = 0
					if dir == 3 then
					(
						offset = pos2.z - pos1.z
						percent = (wt_verts[i].z - pos1.z)/offset
					)
					else if dir == 2 then
					(
						offset = pos2.y - pos1.y
						percent = (wt_verts[i].y - pos1.y)/offset
					)
					else
					(
						offset = pos2.x - pos1.x
						percent = (wt_verts[i].x - pos1.x)/offset
					)
					
					if percent > 1.5 do
						percent = 1.5
					
					percent *= 100
					p = getValue wtAssign_ro.cuvCtrl.curves[1] 0 percent
					p /= 100
				)
				else if ref == 1 then
				(
					percent = getPercent i mat1 mat2
					p = getPercentValue percent 1
				)
				else if ref == 2 then
				(
					percent = getPercent i mat2 mat1
					p = getPercentValue percent 2
				)
				else
				(
					pct1 = getPercent i mat1 mat2
					pct2 = getPercent i mat2 mat1
					
					p1 = getPercentValue pct1 1
					p2 = getPercentValue pct2 2
					
					p = p1 + p2
					p /= 2
					
					if p > 1 do
						p = 1
				)
				
				bone2 = undefined
				for iii = 1 to wt_bone_indexes.count do
				(
					if skinOps.GetBoneName skin wt_bone_indexes[iii] 0 == b2 then
					(
						bone2 = wt_bone_indexes[iii]
						exit
					)
				)
				
				if bone2 != undefined then
				(
					wt_b2 = 0
					for b = 1 to weights[i].count do
					(
						if weights[i][b].i == bone2 then
						(
							wt_b2 = weights[i][b].w
						)
					)
					skinOps.SetVertexWeights skin i weights[i][ii].i (weights[i][ii].w * (1-p))
					skinOps.SetVertexWeights skin i bone2 (weights[i][ii].w * p+wt_b2)
				)
				
-- 				skinOps.unNormalizeVertex skin i false
			)
		)
	)
)

fn getPercent i m1 m2 =
(
	pos2 = m2 * inverse m1
	pos2 = pos2.row4
	
	vtx_p = matrix3 1
	vtx_p.row4 = wt_verts[i]
	vtx_p = vtx_p * inverse m1
	vtx_p = vtx_p.row4
	
	pct = 0
	if dir == 3 then
	(
		pct = vtx_p.z/pos2.z
	)
	else if dir == 2 then
	(
		pct = vtx_p.y/pos2.y
	)
	else
	(
		pct = vtx_p.x/pos2.z
	)
	
	if pct > 1.5 do
		pct = 1.5
	
	pct
)

fn getPercentValue pct c =
(
	pct *= 100
	
	p = getValue wtAssign_ro.cuvCtrl.curves[c] 0 pct
	
	p /= 100
)
