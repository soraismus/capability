-- | A capability is a type class over a monad which specifies the effects that
-- a function is allowed to perform. Capabilities differ from traditional monad
-- transformer type classes, in that they do not specify how the monad is
-- constructed: a state capability can be implemented by accessing a field in a
-- larger state monad, or an error capability may be implemented by throwing
-- only a subset of the errors of an error monad.
--
-- This library defines several standard, reusable capabilities, to be used
-- instead of the mtl's monad-transformer type classes, when writing a program
-- with capabilities. Because capabilities are not tied to a particular
-- implementation of the monad, they cannot be discharged by instance
-- resolution. Instead this library provide combinators in the form of newtypes
-- with instances, to be used with deriving-via. To learn about deriving via,
-- watch Baldur Blondal's introductory video
-- <https://skillsmatter.com/skillscasts/10934-lightning-talk-stolen-instances-taste-just-fine>.
--
-- As comparison, with the mtl you would write something like
--
-- @
-- foo :: (MonadReader E, MonadState S) => a -> m ()
-- @
--
-- Then, you can use @foo@ at type @a -> ReaderT E (State S)@. But you can't use
-- @foo@ with the @ReaderT@ pattern
-- <https://www.fpcomplete.com/blog/2017/06/readert-design-pattern>. With
-- capability, you would instead have.
--
-- @
-- foo :: (HasReader "conf" E, HasState "st" S) => a -> m ()
-- @
--
-- Where @"conf"@ and @"st"@ are the names (also referred to as tags) of the
-- capabilities demanded by foo. Because, contrary to the mtl, capabilities are
-- named, rather than disambiguated by the type of their implied state, or
-- exception.
--
-- Then you need to provide these capabilities, for instance with the ReaderT
-- pattern as follows (for a tutorial which breaks the following down, check the
-- README <https://github.com/tweag/capability#readme>):
--
-- @
-- newtype MyM a = MyM (ReaderT (E, IORef s))
--   deriving (Functor, Applicative, Monad)
--   deriving (HasState "st" Int) via
--     ReaderIORef (Rename 2 (Pos 2 ()
--     (MonadReader (ReaderT (E, IORef s) IO))))
--   deriving (HasReader "conf" Int) via
--     (Rename 1 (Pos 1 ()
--     (MonadReader (ReaderT (E, IORef s) IO))))
-- @
--
-- Then you can use @foo@ at type @MyM@. Or any other type which can provide
-- these capabilites.
--
-- == Module structure
--
-- Each module introduces a capability type class (or several related type
-- classes). Each class comes with a number of instances on newtypes (each
-- newtype should be seen as a combinator to be used with deriving-via to
-- provide the capability). Many newtypes come from the common
-- "Capability.Accessors" module (re-exported by each of the main modules),
-- which contains, in particular, a number of way to address components of a
-- data type using the generic-lens library.
--
-- * "Capability.Reader" reader effects
-- * "Capability.State" state effects
-- * "Capability.Writer" writer effects
-- * "Capability.Error" throw and catch errors
-- * "Capability.Stream" streaming effect (aka generators)
--
-- Some of the capability module have a “discouraged” companion (such as
-- "Capability.Writer.Discouraged"). These modules contain deriving-via
-- combinators which you can use if you absolutely must: they are correct, but
-- inefficient, so we recommend that you do not.
--
-- Consider
--
-- == Further considerations
--
-- The tags of capabilities can be of any kind, they are not restricted to
-- symbols. When exporting function demanding capabilities libraries, it is
-- recommended to use a type as follows:
--
-- @
-- data Conf
--
-- foo :: HasReader Conf C => m ()
-- @
--
-- This way, @Conf@ can be qualified in case of a name conflict with another
-- library.

module Capability where
