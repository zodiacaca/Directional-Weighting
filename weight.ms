
clearlistener()

wt_verts = #()
wt_bone_indexes = #()

wt_selChangeFn = undefined
wt_getSkinModifier = undefined

fn wt_subSelChangeFn event node =
(
	try
	(
		skin = wt_getSkinModifier()
		
		if selection.count == 1 and classof (selection[1]) == Editable_mesh and skin != undefined then
		(
			for i = 1 to wt_verts.count do
			(
				if (skinOps.IsVertexSelected skin i) == 1 then
				(
					bones = #()
					
					for b = 1 to (skinOps.GetVertexWeightCount skin i) do
					(
						if (skinOps.GetSelectedBone skin) == (skinOps.GetVertexWeightBoneID skin i b) then
						(
							if wtAssign_ro != undefined then
							(
								wtAssign_ro.spn_mirror.value = skinOps.GetVertexWeight skin i b
							)
						)
						
						name = skinOps.GetBoneName skin (skinOps.GetVertexWeightBoneID skin i b) 0
						append bones name
					)
					
					if wtAssign_ro != undefined then
					(
						wtAssign_ro.lst_weighted.items = bones
						for i = 1 to wtAssign_ro.lst_weighted.items.count do
						(
							if wtAssign_ro.lst_weighted.items[i] == skinOps.GetBoneName skin (skinOps.GetSelectedBone skin) 0 then
							(
								wtAssign_ro.lst_weighted.selection = i
								wtAssign_ro.b1 = wtAssign_ro.lst_weighted.items[i]
							)
						)
						bones_scene = #()
						for obj in objects do
						(
							if classof obj == BoneGeometry then
							(
								append bones_scene obj.name
							)
						)
						wtAssign_ro.lst_participate.items = bones_scene
					)
				)
				
			)
		)
	)
	catch
	(
	)
)

fn wt_getSkinModifier =
(
	skin = undefined
	
	if $ != undefined and $.modifiers != undefined and $.modifiers[#skin] != undefined then
	(
		skin = $.modifiers[#skin]
	)

	skin
)


rollout wtAssign_ro "Weight Assign" width:400 height:820
(
	struct wt
	(
		i,
		w
	)
	
	struct wt_p
	(
		position,
		weights
	)
	
	local wt_callbackItem
	
	local file_line = #()
	
	local readLineInfo
	local checkTangents
	local correctPoints
	local getPercent
	local getPercentValue
	
	local b1 = undefined
	local b2 = undefined
	
	
	include "weight_position.ms"
	include "weight_participate.ms"
	include "weight_misc.ms"
	
	-- functions
	fn initCurvePointsB =
	(
		ccc = wtAssign_ro.cuvCtrl.curves[2]
		ccc.color = color 0 0 255
		ccc.numPoints = 5
		
		cp = ccc.points[1]
		cp.value = [-150,100]
		cp.bezier = true
		cp.corner = true
		cp.outTangent = [25,0]
		ccc.points[1] = cp
		
		cp = ccc.points[2]
		cp.value = [-100,100]
		cp.inTangent = [-37.5,0]
		cp.outTangent = [37.5,0]
		ccc.points[2] = cp
		
		cp = ccc.points[3]
		cp.value = [0,100]
		cp.inTangent = [-50,0]
		cp.outTangent = [50,0]
		ccc.points[3] = cp
		
		cp = ccc.points[4]
		cp.value = [100,0]
		cp.inTangent = [-37.5,0]
		cp.outTangent = [37.5,0]
		ccc.points[4] = cp
		
		cp = ccc.points[5]
		cp.value = [150,0]
		cp.bezier = true
		cp.corner = true
		cp.inTangent = [-25,0]
		ccc.points[5] = cp
		
		zoom cuvCtrl #all
		
		giveup = 0
		while (checkTangents ccc) != undefined and giveup < 50 do
		(
			giveup += 1
			correctPoints ccc (checkTangents ccc)
			format "Curve 2: % time(s)\n" giveup
		)
	)
	
	fn initCurvePointsA =
	(
		ccc = wtAssign_ro.cuvCtrl.curves[1]
		ccc.color = color 0 0 255
		ccc.numPoints = 5
		
		cp = ccc.points[1]
		cp.value = [-150,0]
		cp.bezier = true
		cp.corner = true
		cp.outTangent = [25,0]
		ccc.points[1] = cp
		
		cp = ccc.points[2]
		cp.value = [-100,0]
		cp.inTangent = [-37.5,0]
		cp.outTangent = [37.5,0]
		ccc.points[2] = cp
		
		cp = ccc.points[3]
		cp.value = [0,0]
		cp.inTangent = [-50,0]
		cp.outTangent = [50,0]
		ccc.points[3] = cp
		
		cp = ccc.points[4]
		cp.value = [100,100]
		cp.inTangent = [-37.5,0]
		cp.outTangent = [37.5,0]
		ccc.points[4] = cp
		
		cp = ccc.points[5]
		cp.value = [150,100]
		cp.bezier = true
		cp.corner = true
		cp.inTangent = [-25,0]
		ccc.points[5] = cp
		
		zoom cuvCtrl #all
		
		giveup = 0
		while (checkTangents ccc) != undefined and giveup < 50 do
		(
			giveup += 1
			correctPoints ccc (checkTangents ccc)
			format "Curve 1: % time(s)\n" giveup
		)
	)
	
	local tangents = #(
		#(0, 0, 25, 0),
		#(-37.5, 0, 37.5, 0),
		#(-50, 0, 50, 0),
		#(-37.5, 0, 37.5, 0),
		#(-25, 0, 0, 0)
	)
	
	fn checkTangents c =
	(
		correct = undefined
		for i = 1 to tangents.count do
		(
			if c.points[i].inTangent != [tangents[i][1],tangents[i][2]] then
			(
				correct = i
			)
			if c.points[i].outTangent != [tangents[i][3],tangents[i][4]] then
			(
				correct = i
			)
		)
		
		correct
	)
	
	fn correctPoints c i =
	(
		c.points[i].inTangent = [tangents[i][1],tangents[i][2]]
		c.points[i].outTangent = [tangents[i][3],tangents[i][4]]
	)
	
	fn addCallback =
	(
		wt_callbackItem = undefined
		gc light:true
			
		wt_callbackItem = nodeEventCallback subobjectSelectionChanged:wt_subSelChangeFn
	)
	
	fn getVertexes =
	(
		try
		(
			wt_verts = #()
			count = getNumVerts $
			for i = 1 to count do
			(
				wt_verts[i] = getVert $ i
			)
			format "Vertex count: %\n" wt_verts.count
		)
		catch
		(
			messageBox "Need Editable Mesh." \
			title:"" beep:false
		)
	)
	
	fn getBoneIndexes =
	(
		try
		(
			skin = wt_getSkinModifier()
			
			wt_bone_indexes = #()
			skinOps.SelectBone skin 1
			start = skinOps.GetSelectedBone skin
			name = skinOps.GetBoneName skin start 0
			if name.count > 1 then
			(
				append wt_bone_indexes start
				skinOps.selectNextBone skin
				while (skinOps.GetSelectedBone skin) != start do
				(
					append wt_bone_indexes (skinOps.GetSelectedBone skin)
					skinOps.selectNextBone skin
				)
			)
		)
		catch
		(
			messageBox "Need Skin modifier or at least one bone in list" \
			title:"" beep:false
		)
	)
	
	fn readLineInfo index =
	(
		pos_wt = wt_p()
		
		str = trimLeft file_line[index]
		str = str as stringstream
		pos_wt.position = execute (readToken str)
		skipspace str
		pos_wt.weights = #()
		count = (readToken str) as integer
		for i = 1 to count do
		(
			skipspace str
			wt_pos = wt()
			wt_pos.i = readToken str
			skipspace str
			wt_pos.w = (readToken str) as float
			append pos_wt.weights wt_pos
		)
		
		pos_wt
	)
	
	-- events
	on lst_weighted selected sel do
	(
		skin = wt_getSkinModifier()
		
		skinOps.selectBoneByNode skin (getnodebyname lst_weighted.items[sel])
		
		b1 = lst_weighted.items[sel]
	)
	
	on lst_participate selected sel do
	(
		b2 = lst_participate.items[sel]
	)
	
	on cuvCtrl ptChanged ci val do
	(
-- 		format "%--%\n" cuvCtrl.curves[ci].points[val].inTangent cuvCtrl.curves[ci].points[val].outTangent
	)
	
	on cuvCtrl reset c do
	(
		initCurvePointsA()
		initCurvePointsB()
	)
	
	on wtAssign_ro open do
	(
		addCallback()
		
		initCurvePointsA()
		initCurvePointsB()
		
		getVertexes()
		getBoneIndexes()
	)
	
	on wtAssign_ro close do
	(
		wt_callbackItem = undefined
		gc light:true
	)
)

if $ != undefined and $.modifiers != undefined and $.modifiers[#skin] != undefined then
(
	if wtAssign_rf != undefined do closeRolloutFloater wtAssign_rf
	wtAssign_rf = newRolloutFloater "" 400 820 40 40
	
	addRollout wtAssign_ro wtAssign_rf
)
else
(
	messageBox "Select Skin modifier first." \
	title:"" beep:false
)

