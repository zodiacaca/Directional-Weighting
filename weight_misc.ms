
local m_x = 20
local m_y = 740

groupBox grp_wt_misc "Misc" pos:[m_x-10,m_y-20] \
width:360 height:56

button btn_clear_boneID "Clear None-Weight Bones" pos:[m_x,m_y] \
width:140 height:28
on btn_clear_boneID pressed  do
(
	indexes = #()
	
	skin = wt_getSkinModifier()

	count = skinOps.GetNumberVertices skin
	
	for i = 1 to count do
	(
		for b = 1 to (skinOps.GetVertexWeightCount skin i) do
		(
			index = skinOps.GetVertexWeightBoneID skin i b
			appendifunique indexes index
		)
	)
	
	dump = #()
	for i = 1 to wt_bone_indexes.count do
	(
		if finditem indexes wt_bone_indexes[i] == 0 then
		(
			append dump i
		)
	)
	
	for i = dump.count to 1 by -1 do
	(
		skinOps.RemoveBone skin dump[i]
	)
)
