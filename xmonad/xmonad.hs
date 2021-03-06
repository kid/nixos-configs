import Data.Monoid (All (All))
import qualified Data.Monoid
import XMonad
import qualified XMonad as XMonad.Operations
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (doCenterFloat, doFullFloat, isFullscreen)
import XMonad.Layout.Circle
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (hPutStrLn, spawnPipe)

-- main = xmonad =<< xmobar myConfig
myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "kitty"

myScratchpads :: [NamedScratchpad]
myScratchpads =
  [ NS "htop" "kitty --name=htop -e htop" (appName =? "htop") doCenterFloat,
    NS
      "telegram"
      "telegram-desktop"
      (appName =? "TelegramDesktop")
      defaultFloating
  ]

myKeys :: [(String, X ())]
myKeys =
  [ ("M-S-r", spawn "xmonad --restart"),
    ("M-t", namedScratchpadAction myScratchpads "htop"),
    ("M-s t", namedScratchpadAction myScratchpads "telegram")
  ]

defaultLayouts =
  smartBorders
    ( avoidStruts
        -- ThreeColMid layout puts the large master window in the center
        -- of the screen. As configured below, by default it takes of 3/4 of
        -- the available space. Remaining windows tile to both the left and
        -- right of the master window. You can resize using "super-h" and
        -- "super-l".
        ( ThreeColMid 1 (3 / 100) (3 / 7)
            -- ResizableTall layout has a large master window on the left,
            -- and remaining windows tile on the right. By default each area
            -- takes up half the screen, but you can resize using "super-h" and
            -- "super-l".
            ||| ResizableTall 1 (3 / 100) (1 / 2) []
            -- Mirrored variation of ResizableTall. In this layout, the large
            -- master window is at the top, and remaining windows tile at the
            -- bottom of the screen. Can be resized as described above.
            ||| Mirror (ResizableTall 1 (3 / 100) (1 / 2) [])
            -- Full layout makes every window full screen. When you toggle the
            -- active window, it will bring the active window to the front.
            ||| noBorders Full
            -- Circle layout places the master window in the center of the screen.
            -- Remaining windows appear in a circle around it
            ||| Circle
            -- Grid layout tries to equally distribute windows in the available
            -- space, increasing the number of columns and rows as necessary.
            -- Master window is at top left.
            ||| Grid
        )
    )

myManageHooks :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHooks =
  composeAll
    [ insertPosition Below Newer,
      isFullscreen --> doFullFloat,
      className =? "dialog" --> doFloat,
      resource =? "dialog" --> doCenterFloat
    ]
    <+> namedScratchpadManageHook myScratchpads
    <+> manageDocks

restartEventHook e@ClientMessageEvent {ev_message_type = mt} = do
  a <- getAtom "XMONAD_RESTART"
  if mt == a
    then XMonad.Operations.restart "xmonad" True >> return (All True)
    else return $ All True
restartEventHook _ = return $ All True

main :: IO ()
main = do
  xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/gruvbox-dark.xmobarrc"
  xmonad $ docks $
    ewmh
      def
        { manageHook = myManageHooks,
          modMask = myModMask,
          terminal = myTerminal,
          layoutHook = defaultLayouts,
          logHook = dynamicLogWithPP $ xmobarPP {ppOutput = hPutStrLn xmproc0},
          handleEventHook = restartEventHook
        }
      `additionalKeysP` myKeys
