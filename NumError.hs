module NumError
  ( NumError (..)
  , scalar
  , instrument
  ) where

mul (v1, e1) (v2, e2) = (v1*v2, v1*v2*sqrt ((e1/v1)^2 + (e2/v2)^2))
suma (v1, e1) (v2, e2) = (v1+v2, sqrt (e1^2 + e2^2))
resta (v1, e1) (v2, e2) = (v1-v2, sqrt (e1^2 + e2^2))
divi (v1, e1) (v2, e2) = (v1/v2, v1/v2*sqrt ((e1/v1)^2 + (e2/v2)^2))

newtype NumError a = E (a, a)
  deriving (Eq, Ord)

instance (Floating a) => Num (NumError a) where
  E x + E y = E $ x `suma` y
  E x - E y = E $ x `resta` y
  E x * E y = E $ x `mul` y
  abs (E (v, e)) = E (abs v, e)
  signum (E (v, e)) = E (signum v, e)
  fromInteger i = E (fromInteger i, 0)

instance (Floating a) => Fractional (NumError a) where
  E x / E y = E $ x `divi` y
  fromRational r = E (fromRational r, 0)

instance (Show a) => Show (NumError a) where
  show (E a) = show a

scalar x = E (x, 0)

instrument factor x = E (x, x*factor)
