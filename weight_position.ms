
groupBox grp_wt_pos "Position Related Weights" pos:[10,10] \
width:360 height:56

button btn_save "Save" pos:[20,30] \
width:80 height:28
on btn_save pressed  do
(
	skin = wt_getSkinModifier()
	
	weights_p = #()
	for i = 1 to wt_verts.count do
	(
		wt_pos = wt_p()
		wt_pos.position = wt_verts[i]
		wt_pos.weights = #()
		for b = 1 to (skinOps.GetVertexWeightCount skin i) do
		(
			w = wt()
			w.i = skinOps.GetVertexWeightBoneID skin i b
			w.w = skinOps.GetVertexWeight skin i b
			append wt_pos.weights w
		)
		append weights_p wt_pos
	)
	
	f_path = getSavePath caption:"Choose the file directory"
	if f_path != undefined then
	(
		str_s = stringStream ""
		str = "[Bones]"
		str += "\n"
		str = str as stringStream
		append str_s str
		for i = 1 to wt_bone_indexes.count do
		(
			str = ""
			str += skinOps.GetBoneName skin i 0
			str += "\n"
			
			str = str as stringStream
			append str_s str
		)
		str = "[Weights]"
		str += "\n"
		str = str as stringStream
		append str_s str
		for i = 1 to weights_p.count do
		(
			str = ""
			str += weights_p[i].position as string
			str += " "
			str += weights_p[i].weights.count as string
			for ii = 1 to weights_p[i].weights.count do
			(
				str += " "
				str += skinOps.GetBoneName skin weights_p[i].weights[ii].i 0
				str += " "
				str += weights_p[i].weights[ii].w as string
			)
			str += "\n"
			
			str = str as stringStream
			append str_s str
		)
		f_path += "//pos-weight.txt"
		f = createFile f_path
		str = str_s as string
		format str to:f
		free f
		close f
	)
)

button btn_load "Load" pos:[120,30] \
width:80 height:28
on btn_load pressed  do
(
	f_path = getOpenFileName \
	caption:"Open :" \
	types:"pos-wt (*.txt)|*.txt|All (*.*)|*.*|"
	
	if f_path != undefined then
	(
		file = openFile f_path
		
		num = 1
		file_line = #()
		
		while not (eof file) do
		(
			file_line[num] = readLine file
			num += 1
		)
		
		wt_start = (findItem file_line "[Weights]") + 1
		
		skin = wt_getSkinModifier()
		
		wtAssign_ro.getBoneIndexes()
		bones = #()
		for i = 1 to wt_bone_indexes.count do
		(
			append bones (skinOps.GetBoneName skin i 0)
		)
		
		for i = 2 to (wt_start - 2) do
		(
			if findItem bones file_line[i] == 0 then
			(
				skinOps.addbone skin (getnodebyname file_line[i]) 0
			)
		)
		
		weights_position = #()
		for i = wt_start to file_line.count do
		(
			append weights_position (readLineInfo i)
		)
		
		for i = 1 to wt_verts.count do
		(
			skinOps.unNormalizeVertex skin i true
		)
		
		for i = 1 to wt_verts.count do
		(
			for ii = 1 to (skinOps.GetVertexWeightCount skin i) do
			(
				index = skinOps.GetVertexWeightBoneID skin i ii
				skinOps.SetVertexWeights skin i index 0
			)
		)
		
		for i = 1 to wt_verts.count do
		(
			for ii = 1 to weights_position.count do
			(
				dist = distance wt_verts[i] weights_position[ii].position
				if abs dist < 0.001 then
				(
					for iii = 1 to weights_position[ii].weights.count do
					(
						skinOps.selectBoneByNode skin (getnodebyname weights_position[ii].weights[iii].i)
						index = skinOps.GetSelectedBone skin
						skinOps.SetVertexWeights skin i index weights_position[ii].weights[iii].w
					)
					deleteitem weights_position ii
					exit
				)
			)
		)
		
		for i = 1 to wt_verts.count do
		(
			skinOps.unNormalizeVertex skin i false
		)
	)
)
