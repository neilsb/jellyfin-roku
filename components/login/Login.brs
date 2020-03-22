function init()
    m.loginServerList = m.top.findNode("LoginServerList")
    m.loginUserList = m.top.findNode("LoginUserList")

    m.serverListAnimation = m.top.FindNode("serverListAnimation")
    m.userListAnimation = m.top.FindNode("userListAnimation")
    
    m.loginServerList.content = getMarkupListData()


    m.serverUrl  = m.top.FindNode("serverUrl")
    m.saveButton  = m.top.FindNode("savebutton")
    m.addgroup  = m.top.FindNode("addServerGroup")
    m.serverUrl.setFocus(true)


    'examplerect = m.loginServerList.BoundingRect()

    
    'm.loginServerList.ObserveField("itemFocused", "onFocusChanged")

    'rect = m.loginServerList.boundingRect()

    'Print "Height: " + rect.height
    m.selectingServer = true
    sizeServerList()
    m.loginServerList.SetFocus(true)
    m.top.setFocus(true)
    ' m.addgroup.setFocus(true)
    ' m.saveButton.setFocus(true)
    'm.serverUrl.setFocus(true)


end function


sub sizeServerList()

    ' Get Size of List to allow centering
    children = m.loginServerList.content.getChildCount()
    
    height = (children - 1) * 50

    m.loginServerList.focusRow = Cint(children / 2) - 1
    
    top = ((1080 - 115 - height)/2) 

    m.loginServerList.translation = [m.loginServerList.translation[0], top]

    m.top.setFocus(true)
end sub

sub serverListFocus(hasFocus)

    ' Slide ServerList left or right depending on Focus
    serverSlide = m.top.findNode("serverSlide")

    if hasFocus = true 
        desiredX = (1920 - 400) / 2
        serverSlide.KeyValue = [ 
            [m.loginServerList.translation[0], m.loginServerList.translation[1]],
            [m.loginServerList.translation[0], m.loginServerList.translation[1]],
            [desiredX, m.loginServerList.translation[1]]
        ]
    else
        desiredX = 100
        serverSlide.KeyValue = [ 
            [m.loginServerList.translation[0], m.loginServerList.translation[1]],
            [desiredX, m.loginServerList.translation[1]],
            [desiredX, m.loginServerList.translation[1]]
        ]
    end if
    

    ' Start the Animation
    m.serverListAnimation.control = "start"

    m.loginServerList.setFocus(hasFocus)
    m.top.setFocus(true)
end sub


sub userListFocus(hasFocus)

    ' Fade in or out depending on Focus
    serverSlide = m.top.findNode("userListOpacity")

    if hasFocus = true 
        desiredOpacity = 1
        serverSlide.KeyValue = [m.loginUserList.opacity, m.loginUserList.opacity, desiredOpacity]
    else
        desiredOpacity = 0
        serverSlide.KeyValue = [m.loginUserList.opacity, desiredOpacity, desiredOpacity]
    end if
    
    ' Start the Animation
    m.UserListAnimation.control = "start"

    m.loginUserList.setFocus(hasFocus)
    m.top.setFocus(true)
end sub

function sizeUserList()

    ' Get Size of List to allow centering
    children = m.loginUserList.content.getChildCount()

    ' Set max visible rows to 7
    if children > m.loginUserList.numRows
        children = m.loginUserList.numRows
    end if

    height = (children - 1) * 90
    m.loginUserList.focusRow = Cint(children / 2) - 1

    top = ((1080 - 115 - height)/2) 

    'If choosing server, center on screen
       m.loginUserList.translation = [m.loginUserList.translation[0], top]

    m.top.setFocus(true)
end function


function getMarkupListData() as object
    data = CreateObject("roSGNode", "ContentNode")

        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/server.png"
        dataItem.labelText = "Server 1"
        dataItem.label2Text = "http://192.168.1.50:8096"

        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/server.png"
        dataItem.labelText = "Server 2"
        dataItem.label2Text = "http://192.168.1.50:18096"

        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/server.png"
        dataItem.labelText = "Server 3"
        dataItem.label2Text = "http://192.168.1.50:8096"

        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/server.png"
        dataItem.labelText = "Server 4"
        dataItem.label2Text = "http://192.168.1.50:18096"

        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/server.png"
        dataItem.labelText = "Server 5"
        dataItem.label2Text = "http://192.168.1.50:8096"


        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/server.png"
        dataItem.labelText = "Server 6"
        dataItem.label2Text = "http://192.168.1.50:18096"

        dataItem = data.CreateChild("LoginServerData")
        dataItem.posterUrl = "pkg:/images/add.png"
        dataItem.labelText = "Add Server"
        dataItem.label2Text = ""

    return data
end function

function onFocusChanged() as void
    print "Focus on item: " + stri(m.loginServerList.itemFocused)
    print "Focus on item: " + stri(m.loginServerList.itemUnfocused) + " lost"
end function


function onUserListLoaded(msg) as void

    userData = msg.GetData()

	sourceNode = msg.getRoSGNode()
	sourceNode.unobserveField("content")

    users = CreateObject("roSGNode", "ContentNode")


    for each user in userData
        users.appendChild(user)
    end for


    m.loginUserList.content = users
    sizeUserList()
    m.loginUserList.SetFocus(true)

    print "User Loaded"
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false

    if press then

        if m.loginServerList.hasFocus() = true then
            if key = "OK" OR Key = "right"

                ' Load the users form the server
                m.LoadItemsTask = createObject("roSGNode", "ServerInfoTask")
                m.LoadItemsTask.observeField("content", "onUserListLoaded")
                m.LoadItemsTask.control = "RUN"

                serverListFocus(false)
                userListFocus(true)

                print "Server Selected"

            else if key = "back"
                print "Exiting from Server Select"
                return false
            end if


        else if m.loginUserList.hasFocus() = true then

            print "Got Press......" + Key
            if key = "back" OR Key = "left"

                print "Server List to get focus"
                userListFocus(false)
                serverListFocus(true)


            end if


        end if
        




        ' m.serverListAnimation.control = "start"
        ' if m.selectingServer = true then
        '     m.selectingServer = false
        ' else
        '     m.selectingServer = true
        ' end if
        ' formatServerList()
        handled = true
    end if


    ' if (m.simpleMarkupList.hasFocus() = true) and (key = "right") and (press=true)
	'     m.simpleMarkupGrid.setFocus(true)
	' 	m.simpleMarkupList.setFocus(false)
	'     handled = true
	' else if (m.simpleMarkupGrid.hasFocus() = true) and (key = "left") and (press=true)
	'     m.simpleMarkupGrid.setFocus(false)
	' 	m.simpleMarkupList.setFocus(true)
	'     handled = true
	' endif
    return handled    
end function

function onDialogButton()
    d = m.top.getScene().dialog
    button_text = d.buttons[d.buttonSelected]

    if button_text = "Search"
        m.top.search_value = d.text
        dismiss_dialog()
        return true
    else if button_text = "Cancel"
        dismiss_dialog()
        return true
    end if

    return false
end function

sub show_dialog()
    dialog = CreateObject("roSGNode", "KeyboardDialog")
    dialog.title = "Search"
    dialog.buttons = ["Search", "Cancel"]

    m.top.getScene().dialog = dialog

    dialog.observeField("buttonselected", "onDialogButton")
end sub

sub dismiss_dialog()
    m.top.getScene().dialog.close = true
end sub