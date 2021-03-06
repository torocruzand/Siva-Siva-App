﻿script "lib_SivaSivaPortal"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaPortal
type: library
version: 0.2
Original Script by David Bovill

/*
The SivaSiva portal is a self-contained group which presents a "contents view" of:

1) Top level portals to SivaSiva modules
2) Second level contents of individual SivaSiva modules

In general navigation terems we can consider the portal view as a 
giving a "book contents" style overview and springboard to material in individual modules.

Technicaly it is possible to have any number of levels, but we should try to avois any more thant 2 clicks before we navigate to actual module content.
The portals group is currently placed on one single card - the first card of the "sivasivahome" stack and uses an array stored in the model_SivaSiva.json file.
This data combines what was previously stored in a number of files scattered throughout the app.
It is still possible for individual modules to store their own module-specifig configuration data as before, but portal data shoul be stored in the model_SivaSiva.json file
and accessed via the handlers in the SivaSiva | Portal | Model section below.

BR: Aside from handling the layout of the portal stack, this script also controls
the general flow of navigation across the entire app, where users are going from one module to another
Modules handle internal navigation across their own cards in the same stack.
Key handlers for global navigaiton are the Portal_GoStack, Portal_SetCurrentStack, portal_GetLastStack
Which are called to track movement across modules so that "Back" will return to the last viewed  view/stack

we Realy should separate all thehandler pertaining to the "views" and move them to a navigation library.
*/ 


--> Variables
-
local LocalArray, sCurrentPortal, sLastStack, sLaunchStack, sLastLinkTitle, sNavMap
local sLastModulesList, sOrientation, sDestinationCardOrStack, sDisplayLabel


------------- Navigation section -------------------
# BR: this whole set of handlers probably should move to a separate lib dedicated to navigation
# or all the way "up" to the primary back script: lib_SivaSiva
# Functions related to presentation that have been deprecated.
# and moved to the end  for save keeping

------------------------------------------------------





-----------------------------------------------------------
-- portal_GoStack
-- DESCRIPTION
--  This is the main navigation command that switch stacks on demand
--   it is set to close all stacks other than the loader stack
--    so you will need to be careful about addressing scripts in the hierarchy if the 
--    stack is already closed. 
--  to "go back" this handler set the last module traversed by the user expect for 
-- SivaSivaApp, Journal, and Browser (unless from Journal)
-- PARAMETERS
-- this can be simply the short name of the stack  or a string like
-- "card 1 of  stack  tSomeStackName" 
-- CHANGES:  2016-08-01 David Bovil -- created
-- 2017-04/05 Brahmanathaswami, added more robust  code for going back.
--------------------------------------------------------------


command portal_GoStack cardOrStackObject
   
   tsNetLibUrlReuseConnection false
   # in case the UI froze on internet connection the 
   # use the user was banging in nav icons.
   --mobileClearTouch 
   
   local oStackName, pTrackdata, pAction
   --breakpoint
   put the short name of this stack into oStackName
   
   # cannot pass quotes to these strings or you willl
   # break the JSON, BR added utilities section to lib_SivaSiva
   
   put removeQuotes(cardOrStackObject) into pTrackdata["contentTarget"]
   ntinfo "nothing"
   if oStackName <> empty then # this is not the first run boot of portal
      deleteAllMobileControls # will destroy all except audioPlayer
   end if
   
   ## Do not change to the acceleratedRending true | false at this point
   ## it causes a blank black screen going form one stack to another
   
   ntInfo "about to change stacks from: " & oStackName & " to " & cardOrStackObject
   
   if currentlyLandscape() then
      -- need to transition through a blank card/stack to allow rotation to happen
      -- before attempting to draw the new portrait card
      put cardOrStackObject into sDestinationCardOrStack
      put the long id of stack "blank" into cardOrStackObject
   else
      put empty into sDestinationCardOrStack
   end if
   
   close stack oStackName
   go cardOrStackObject
   if isMobile() = true then
      mobileClearTouches
   end if
   
   if oStackName is "Siva-Siva-Portal" then 
      put "navigation/topindex" into pAction
   else 
      put "navigation/goContent" into pAction
   end if
   
   if oStackName is "Siva-Siva-Portal" then
      news_Fetch
   end if
   
   put oStackName into pTrackData["exitFrom"]
   tracking_RecordActivity "Portal", pAction, pTrackdata 
end portal_GoStack

command portal_FinishGoStack
   # used to complete the navigation from a landscape stack to a portrait stack
   if sDestinationCardOrStack is empty then
      exit portal_FinishGoStack
   end if
   go sDestinationCardOrStack
   put empty into sDestinationCardOrStack
end portal_FinishGoStack
   
function getOrientionOfStacks oStackName, cardOrStackObject
   local tLandscapeModules, tPortraitModules
   # go for landscape to portrait requires us to manually load a blank
   # screen to allow the rendering change to happen while screen is blank
   
   put "wordpuzzles,view_BrowserLandscape" into tLandscapeModules
   put "siva-siva-portal, journal, settings" into tPortraitModules
   
   return (oStackName is among the items of  tLandscapeModules)
   
end getOrientionOfStacks

command portal_DoRowLink rowName
   local linkArray, linkCommand, linkParam
   --portal_SetLastLinkTitle rowName
   --put portal_GetRowLinkArray (rowName) into linkArray
   
   put getNavigationMap() into sNavMap
   put sNavMap["portalRowDictionary"][rowName]["link"] into linkArray
   
   put linkArray ["portal command"] into linkCommand
   put linkArray ["portal param"] into linkParam
   
   switch linkCommand
      case "getRandomVideo"
         portal_SetLastStack "Surprise"
         getRandomVideo
         break
      case "portal_Link"
         portal_Link linkParam
         break
      case "portal_GoStack"  
         portal_GoStack linkParam
         break
      case "portal_Go"
         portal_Go linkParam
         break
      case "portal_GoUrl"
         portal_GoUrl linkParam, rowName 
         # rowname become sJournalLabel unless it modified after the page loads
         break
      case "portal_GoLandscapeUrl"
         portal_GoLandscapeUrl linkParam
         break
      case "portal_LaunchUrl" # invoke external browser
         portal_LaunchURL linkParam
         break
   end switch
end portal_DoRowLink

command portal_Link portalName
   local tPortalTarget, pTrackdata
   --ntInfo "Portal link"
   
   -- navigates to the "portal view" and displays the named portal
   
   if not (sLaunchStack="Siva-Siva-Portal") then 
      # called from a module and not the portal stack
      portal_SetCurrentPortal portalName
      if requiresConnection(portalName)  = "false" then
         dialog_CustomMsg "Connection required. Going Home"
         put "Home" into portalName
      end if
      put format ("card \"%s\" of stack \"Siva-Siva-Portal\"",portalName) into tPortalTarget
            portal_GoStack tPortalTarget
      
   else
      portal_SetCurrentPortal portalName
      portal_SetLastStack "Siva-Siva-Portal"
      if requiresConnection(portalName) = "false" then
         dialog_CustomMsg "Connection required."
         put "Home" into portalName
      end if
      go card portalName
      put portalName into pTrackdata["contentTarget"]
      tracking_RecordActivity "Portal", "navigation/topindex", pTrackdata
   end if
   
end portal_Link

command portal_GoUrl pURL,pJournalLabel
   --breakpoint
   local tRequiresLandscape, oStackName, tBrowserView, pTrackdata
   
   put ("youtube.com","1988-apple-video") into tRequiresLandscape
   
   if requiresConnection(sLastLinkTitle) = "false" then
      dialog_CustomMsg "Connection required."
      exit to top
   end if
   
   if checkURLAvailable(pURL) = "false" then
      dialog_CustomMsg "Web site unavailable. Try later."
      exit to top
   end if
   
   # need to store a proper for the web to refer to in journal
   portal_SetLabel pJournalLabel
   
   put the short name of this stack into oStackName
   repeat for each item x  in tRequiresLandscape
      if  pURL contains x then
         put "goLandscape" into tBrowserView
      end if
   end repeat
   if  tBrowserView = "goLandscape" then
      portal_GoStack "view_BrowserLandscape"
      send "setBrowserURL pURL"  to cd "SivaSivaBrowser" of stack "view_BrowserLandscape" in 100 milliseconds
   else
      portal_GoStack "view_SivaSivaBrowser"     
      send "setBrowserURL pURL" to cd "SivaSivaBrowser" of stack "view_SivaSivaBrowser" in 100 milliseconds
   end if
   
   put pURL into pTrackdata["webUrl"]
   tracking_RecordActivity oStackName, "navigation/webview", pTrackdata
   
end portal_GoUrl

command portal_LaunchUrl someURL
   
   # leave Siva Siva app and open the native web app on the device
   launch url someURL    
end portal_LaunchUrl

command portal_SetLabel pJournalLabel
   put pJournalLabel into sDisplayLabel
end portal_SetLabel

function portal_GetLabel
   return sDisplayLabel
end portal_GetLabel

command portal_GoLandscapeUrl someURL
   set the browser_URL [true] of stack "view_SivaSivaBrowser" to someURL
   portal_GoStack "view_SivaSivaBrowser"
end portal_GoLandscapeUrl

command portal_SetCurrentPortal portalName
   put portalName into sCurrentPortal   
end portal_SetCurrentPortal

function portal_GetCurrentPortal
   --ntInfo "portal_GetCurrent"
   # BR: Support for tracking the portal from which
   # a module was launched from   
   return sCurrentPortal
end portal_GetCurrentPortal

command portal_SetLastStack stackName
   # every time a stack is closed, it is registered as the last stack
   # we  go back "sLastStack" on "global" navigation.
   # like returning from Chennai to London;
   --ntInfo "portal_SetLastStack"
   --   if stackname = "Siva-Siva-App" then
   --      ntinfo "Launch from SivaSivaApp"
   --      put "Siva-Siva-Portal" into stackName
   --   end if
   put stackName into sLastStack  
end portal_SetLastStack


function portal_GetLastStack
   # a module came from  so we can go back
   return sLastStack
end portal_GetLastStack

command portal_SetLaunchStack stackName
   # every time a stack is opened,  it is save as the "sLaunchStack"
   # Some stacks need to go to "substacks" 
   # Like going from Wailua Homesteads to the Lihue Airport
   # the substack, Journal, or the Browser need to return
   # this stack and then don't return to a global node/stack
   # We call it the "slaunchStack"
   --ntInfo "portal_setLaunchStackk"
   put stackName into sLaunchStack  
end portal_setLaunchStack

function portal_GetLaunchStack stackName
   # we  go back "sLaunchStack" of a local navigation.
   # like returning from Lihue Airport to Wailua Homesteads
   --ntInfo "portal_setLaunchStack"
   return sLaunchStack  
end portal_GetLaunchStack


command portal_SetModulesList  tTarget
   put tTarget into sLastModulesList  
end portal_SetModulesList

function portal_GetModulesList stackName
   --breakpoint
   return sLastModulesList  
end portal_getModulesList

