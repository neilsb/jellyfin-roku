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
        dataItem.label2Text = "http://192.168.1.40:8096"

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


'
' "Server Error" dialog dismissed
sub dialogClosed(msg)

    ' Clean up Dialog
    sourceNode = msg.getRoSGNode()
	sourceNode.unobserveField("buttonSelected")
	sourceNode.unobserveField("wasClosed")
    sourceNode.close = true

    ' Re-focus the Server List
    userListFocus(false)
    serverListFocus(true)
end sub

'
' User list loaded by Task
function onUserListLoaded(msg) as void

    userData = msg.GetData()

	sourceNode = msg.getRoSGNode()
	sourceNode.unobserveField("content")

    ' If there was an error - display Dialog
    if sourceNode.error = true then

      dialog = createObject("roSGNode", "Dialog")
      dialog.title = tr("Error Contacting Server")
      dialog.buttons = [tr("OK")]
      dialog.message = tr("Unable to connnect to selected server.")
      dialog.observeField("buttonSelected", "dialogClosed")
      dialog.observeField("wasClosed", "dialogClosed")
      m.top.getScene().dialog = dialog
      return

    end if


    users = CreateObject("roSGNode", "ContentNode")

    for each user in userData
        users.appendChild(user)
    end for

    ' Add Manual Login item
    manualLogin = CreateObject("roSGNode", "UserData")
    manualLogin.username = "Manual Login"
    manualLogin.id = "-1"
    users.appendChild(manualLogin)




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

                ' Get selected item
                
                print "Selected Item Index" m.loginServerList.itemFocused

                selectedItem = m.loginServerList.content.getChild(m.loginServerList.itemFocused)

                if selectedItem.label2Text = "" and selectedItem.labelText = "Add Server" then

                else
                    ' Load the users form the server
                    m.loginUserList.content = CreateObject("roSGNode", "ContentNode")
                    m.LoadItemsTask = createObject("roSGNode", "ServerInfoTask")
                    m.LoadItemsTask.serverUrl = selectedItem.label2Text
                    m.LoadItemsTask.observeField("content", "onUserListLoaded")
                    m.LoadItemsTask.control = "RUN"

                    serverListFocus(false)
                    userListFocus(true)

                    print "Server Selected"
                end if

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