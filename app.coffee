{InputLayer} = require "input"

flowComp = new FlowComponent
flowComp.showNext(Home)
scrollComp = new ScrollComponent
	parent: Panel
	width: Panel.width
	height: Panel.height - 140
	paddingBottom: 80
	y: 140
	scrollHorizontal: false
	contentInset: 
		top: 0
		right: 0
		bottom: 0 #add paddingBottom
		left: 0

# - nav
nav.x = 0
nav.y = Screen.height - 48
nav.z = 100
nav.superLayer = Home

collection_nameList = ["Wishlist", "Shopping List", "Travel List", "Documents"]
collection_arrayList = []
input_array = []
collection_name = ""

####################################################
# 1. Notification
####################################################

# - states
notification.states.hide =
	opacity: 0
	y: -81
	animationOptions:
		time: .4
notification.states.show =
	opacity: 1
	y: 24
	animationOptions:
		time: .4

# - init
notification.stateSwitch("hide")
# notification.draggable.enabled = true
# notification.draggable.constraints = {
# 	x: 0
# 	y: -81
# 	width: Screen.width
# 	height: 186
# }
# notification.draggable.horizontal = false
# notification.draggable.overdrag = false

# - action
background.onClick ->
	notification.stateCycle()
	Utils.delay 4, ->
		notification.animate('hide')

notification.onClick (event) ->
	updateCollection()
	event.preventDefault()
	notification.animate("hide")
	input_button.stateSwitch("show")
	flowComp.showOverlayBottom(Panel)
	check.stateSwitch("disabled")
	collection_name = ""
	if input_array.length != 0
		input_array[0].destroy()
		if(input_array[1] != undefined) 
			input_array[1].destroy()
		input_array = []

####################################################
# 2. Panel
####################################################

# - states
input_button.states.hide = 
	opacity: 0
	z: -1
input_button.states.show =
	opacity: 1 
	z: 10
check.states.disabled = 
	"pointer-events": "none"
	opacity: .2
check.states.enabled =
	opacity: 1 

# - action
input_button.onClick ->
	input_button.stateSwitch("hide")
	if input_array.length == 0
		input = new InputLayer
			backgroundColor: "#ddd"
			name: 'input'
			parent: Panel
			text: "Name your Collection"
			fontSize: 30
			x: 30
			y: 90
			width: 260
			height: 20
		input_array.push(input)
		input.onValueChange ->
			if(input.value == "")
				check.stateSwitch("disabled")
			else
				check.stateSwitch("enabled")
				collection_name = input.value
				toast_message.text = "Add to " + collection_name

updateCollection = () ->
	for i in [0...collection_arrayList.length]
		collection_arrayList[i].destroy()
	collection_arrayList = []
	for i in [0..collection_nameList.length - 1]
		collection = new Layer
			name: collection_nameList[i]
			parent: scrollComp.content
			y: 145*Math.floor(i/2)
			x: 20 + 145*(i%2)
			width: 135
			height: 135
			borderRadius: 10
		collection.onClick ->
			flowComp.showPrevious()
			toast_message.text = "Add to " + this.name
			toast_background = new Layer
				parent: toast
				x: Align.center
				y: Align.center
				z: -1
				width: toast_message.width + 40
				height: 45
				borderRadius: 100
				backgroundColor: "#000000"
				opacity: .5
			toast_background.placeBehind(toast_message)
			input_array.push(toast_background);
			toast.animate('show')
			Utils.delay 3, ->
				toast.animate('hide')	
		collection_arrayList.push(collection)
		collection_text = new TextLayer
			parent: collection_arrayList[i]
			text: collection_nameList[i]
			fontSize: 12
			color: "#fff"
			padding: 20
			width: 150
		collection_text.autoWidth = yes
	if collection_arrayList.length > 4
		scrollComp.contentInset =
			bottom: 20
####################################################
# 3. Toast
####################################################

# - states
toast.states.hide = 
	opacity: 0
	y: Screen.height - 250
toast.states.show =
	opacity: 1 
	y: Screen.height - 270
	animationOptions:
		time: .6

# - init
toast.z = 20
toast_message.z = 30
toast.stateSwitch("hide")

# - action
check.onClick ->
	if(check.opacity == 1)
		flowComp.showPrevious()
		collection_nameList.unshift(collection_name)
		toast_background = new Layer
			parent: toast
			x: Align.center
			y: Align.center
			z: -1
			width: toast_message.width + 40
			height: 45
			borderRadius: 100
			backgroundColor: "#000000"
			opacity: .5
		toast_background.placeBehind(toast_message)
		input_array.push(toast_background);
		toast.animate('show')
		Utils.delay 3, ->
			toast.animate('hide')	

####################################################
# 4. App
####################################################

app.onClick ->
	flowComp.showOverlayCenter(App)
	nav.superLayer = App
tokopedia_icon.onClick ->
	flowComp.showOverlayCenter(Tokopedia)
	nav.superLayer = Tokopedia
lazada_icon.onClick ->
	flowComp.showOverlayCenter(Lazada)
	nav.superLayer = Lazada
back_btn.onClick ->
	flowComp.showPrevious()
	nav.superLayer = Home