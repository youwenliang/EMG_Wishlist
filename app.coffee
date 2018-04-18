{InputLayer} = require "input"

# Global Data
state = "Home"
collection_nameList = ["Wishlist", "Shopping List", "Travel List", "Documents"]
collection_arrayList = []
app_List = {
	"App": App,
	"Home": Home,
	"Tokopedia": Tokopedia,
	"Lazada": Lazada
}
input_array = []
collection_name = "Default"
App.x = Tokopedia.x = Lazada.x = App.y = Tokopedia.y = Lazada.y = 0

timer_toast = null
timer_notification = null

# Flow Component
flowComp = new FlowComponent
flowComp.showNext(Home)
flowComp.header = statusbar_black
flowComp.footer = nav
nav.z = statusbar_black.z = 10

# Scroll Component - Panel
scrollComp = new ScrollComponent
	parent: Panel
	width: Panel.width
	height: Panel.height - 140
	y: 140
	scrollHorizontal: false
	contentInset: 
		top: 0
		right: 0
		bottom: 0 #add paddingBottom
		left: 0

# Time
today = new Date
hour = today.getHours()
minute = ("0"+today.getMinutes()).slice(-2)
time.text = hour+":"+minute
	
setInterval ->
	today = new Date
	hour = today.getHours()
	minute = ("0"+today.getMinutes()).slice(-2)
	time.text = hour+":"+minute
, 60000
####################################################
# 1. Notification
####################################################

# - states
notification.states.hide =
	opacity: 0
	x: 0
	y: -81
	animationOptions:
		time: .4
notification.states.show =
	opacity: 1
	x: 0
	y: 24
	animationOptions:
		time: .4

# - init
notification.stateSwitch("hide")

# - action
recent_btn.onClick ->
	notification.parent = app_List[state]
	notification.animate("show")
	clearTimeout timer_notification
	timer_notification = setTimeout ->
		notification.animate('hide')
	, 4000

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
			collection_name = this.name
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
			toast.parent = app_List[state]
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
	x: Align.center
	y: Screen.height - 150
toast.states.show =
	opacity: 1 
	x: Align.center
	y: Screen.height - 170
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
		toast.parent = app_List[state]
		toast.animate('show')
		clearTimeout timer_toast
		timer_toast = setTimeout ->
			toast.animate('hide')	
		, 3000

####################################################
# 4. App
####################################################
	
# Custom transition 
scaleTransition = (nav, layerA, layerB, overlay) ->
	transition =
		layerA:
			show:
				scale: 1.0
				opacity: 1
				options:
					time: 0.4
			hide:
				scale: 1.0
				opacity: 0
				options:
					time: 0.4
		layerB:
			show:
				scale: 1.0
				opacity: 1
				options:
					time: 0.4
			hide:
				scale: 0.5
				opacity: 0
				options:
					time: 0.4

app.onClick ->
# 	flowComp.transition(App, scaleTransition)
	flowComp.showNext(App)
	collection_text.text = collection_name
	state = "App"
tokopedia_icon.onClick ->
# 	flowComp.transition(Tokopedia, scaleTransition)
	flowComp.showNext(Tokopedia)
	state = "Tokopedia"
lazada_icon.onClick ->
# 	flowComp.transition(Lazada, scaleTransition)
	flowComp.showNext(Lazada)
	state = "Lazada"

home_btn.onClick ->
	flowComp.showPrevious()
	state = "Home"
back_btn.onClick ->
	flowComp.showPrevious()
	state = "Home"
	
	
# Menu actions
menu_Panel_btn.onClick ->
	flowComp.showOverlayBottom(menu_Panel)
App.header = app_header
appScrollComp = new ScrollComponent
	parent: App
	scrollHorizontal: false
	width: App.width
	height: Screen.height - 48
	x: 0
	y: 93
appScrollComp.content.draggable.overdrag = false
app_content.parent = appScrollComp.content
app_content.x = app_content.y = 0

# Scroll
collectionScroll_1 = new ScrollComponent
	parent: app_content
	scrollVertical: false
	width: Screen.width
	height: 150
	x: 0
	y: 45
	contentInset:
		left: 20
scroll_1.parent = collectionScroll_1.content
scroll_1.x = scroll_1.y = 0

collectionScroll_2 = new ScrollComponent
	parent: app_content
	scrollVertical: false
	width: Screen.width
	height: 150
	x: 0
	y: 246
	contentInset:
		left: 20
scroll_2.parent = collectionScroll_2.content
scroll_2.x = scroll_2.y = 0

collectionScroll_3 = new ScrollComponent
	parent: app_content
	scrollVertical: false
	width: Screen.width
	height: 150
	x: 0
	y: 447
	contentInset:
		left: 20
scroll_3.parent = collectionScroll_3.content
scroll_3.x = scroll_3.y = 0

# Custom transition 
fadeTransition = (nav, layerA, layerB, overlay) ->
	transition =
		layerA:
			show:
				opacity: 1
				z: -1
				options:
					time: .3
			hide:
				opacity: 1
				z: -2
				options:
					time: .3
		layerB:
			show:
				opacity: 1
				z: -1
				options:
					time: .3
			hide:
				opacity: 0
				z: -2
				options:
					time: .3

# Collection Menu
share_1.onClick ->
	flowComp.showOverlayBottom(share_Panel)
share_2.onClick ->
	flowComp.showOverlayBottom(share_Panel)
more_1.onClick ->
	flowComp.showOverlayBottom(collection_Panel)
more_2.onClick ->
	flowComp.showOverlayBottom(collection_Panel)

collection_info.onClick ->
	flowComp.showPrevious(animate: false)
	flowComp.showOverlayBottom(collectionInfo_Panel)
rename.onClick ->
	flowComp.showPrevious(animate: false)
	flowComp.showOverlayCenter(rename_Panel)
select.onClick ->
	flowComp.showPrevious(animate: false)
	flowComp.showNext(Select)
back.onClick ->
	flowComp.showPrevious()
delete_collection.onClick ->
	flowComp.showPrevious(animate: false)
	flowComp.showOverlayCenter(delete_Panel)

# Search
search_input.onClick ->
	flowComp.transition(Search_page, fadeTransition)
	Search_page.x = Search_page.y = 0
back_1.onClick ->
	flowComp.showPrevious()
back_2.onClick ->
	flowComp.showPrevious()
search_action.onClick ->
	flowComp.transition(Search_results, fadeTransition)
	search_text_2.text = search_text_1.text
	Search_results.x = Search_results.y = 0
reset.onClick ->
	flowComp.transition(App, fadeTransition)

#tags
tags = [tag_1, tag_2, tag_3, tag_4, tag_5, tag_6]
tags_text = []
tags_temp = ""

for i in [0...6]
	tags[i].onClick ->
		rect = this.subLayers[0]
		text = this.subLayers[1]
		if(rect.opacity != 1)
			rect.opacity = 1
			text.color = "#fff"
			tags_text.push(text.text)
			tags_temp = tags_text.join(', ')
		else
			rect.opacity = .2
			text.color = "#000"
			index = tags_text.indexOf(text.text)
			if (index > -1)
				tags_text.splice(index, 1)
				tags_temp = tags_text.join(', ')
		if(tags_temp != "") 
			search_text_1.color = "#000"
			search_text_1.text = tags_temp
		else 
			search_text_1.color = "#BBB"
			search_text_1.text = "Search Screenshots"

#Detail
target_shot.onClick ->
	flowComp.showNext(Detail)

detail_more.onClick ->
	flowComp.showOverlayBottom(detailmore_Panel)
	
shot.states =
	inactive:
		z: -10
		options:
			time: .1
	active:
		z: 5
		options:
			time: .1
shot.stateSwitch("inactive")
shot.onClick ->
	this.stateCycle "active", "inactive"

tags_footer.states =
	inactive:
		y: Screen.height - 98
		options:
			time: .2
	active:
		y: Screen.height - 148
		options:
			time: .2
tags_footer.stateSwitch("inactive")
tags_footer.onClick ->
	this.stateCycle "active", "inactive"	
	


open_browser.onClick ->
	flowComp.showPrevious()
	flowComp.showNext(Browser)	

select_image = [select_1, select_2, select_3, select_4]
size_image = ["", "2.1MB", "3.4MB", "4.9MB", "5.7MB"]
selected_num = 0

for i in [0...4]
	select_image[i].onClick ->
		if(this.opacity != 1)
			this.opacity = 1
			selected_num++
		else
			this.opacity = .5
			selected_num--
		if (selected_num != 0) 
			selected_text.text = selected_num + " selected"
			size_text.text = size_image[selected_num]
		else
			selected_text.text = ""
			size_text.text = ""

		