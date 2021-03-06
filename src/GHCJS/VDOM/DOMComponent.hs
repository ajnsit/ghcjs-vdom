{- |
   DOM components manage a normal DOM subtree inside a virtual-dom tree.

   The component has callbacks for mounting and unmounting. The mount
   callback returns a DOM tree that stays in the document until the
   unmount callback is called.

   A single component can be mounted multiple times. The mount callback
   is called for each mount, and is expected to return a fresh DOM
   tree every time.
 -}

{-# LANGUAGE ForeignFunctionInterface, JavaScriptFFI, QuasiQuotes #-}
module GHCJS.VDOM.DOMComponent ( DComp
                               , mkComponent
                               , toNode
                               ) where

import           GHCJS.Foreign.QQ
import           GHCJS.Marshal.Pure
import           GHCJS.Types

import           GHCJS.VDOM.Internal.Types

import qualified GHCJS.VDOM.Internal       as I


toNode :: DComp -> VNode
toNode (DComp v) = VNode v
{-# INLINE toNode #-}

mkComponent :: (Int -> IO JSVal)     -- ^ mount action, return a DOM node
            -> (Int -> JSVal -> IO ()) -- ^ unmount action
            -> IO DComp
mkComponent mount unmount =
  let mountE   = I.unsafeExportValue (mountComponent mount)
      unmountE = I.unsafeExportValue (unmountComponent unmount)
  in  DComp <$> [jsu| h$vdom.c(null, `mountE, `unmountE, null) |]


mountComponent :: (Int -> IO JSVal) -> JSVal -> JSVal -> IO ()
mountComponent f mnt c = do
  node <- f (pFromJSVal mnt)
  [jsu| `c.updateMount(`mnt, `node); |]

unmountComponent :: (Int -> JSVal -> IO ()) -> JSVal -> JSVal -> IO ()
unmountComponent f mnt node = f (pFromJSVal mnt) node
