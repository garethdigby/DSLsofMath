\begin{code}
{-# LANGUAGE ScopedTypeVariables #-}
import DSLsofMath.AbstractFOL
\end{code}
The scoped type variables extension is only needed to give
types to sub-proofs defined in where clauses.

In order to obtain sound proofs, we can only use the following
functions to manipulate terms of types representing logical
formulas.

andIntro       ::  p -> q -> And p q
andElimL       ::  And p q -> p
andElimR       ::  And p q -> q

orElim       ::  Or p q -> (p -> r) -> (q -> r) -> r
orIntroL     ::  p -> Or p q
orIntroR     ::  q -> Or p q

implIntro      ::  (p -> q) -> Impl p q
implElim       ::  Impl p q -> p -> q

notIntro     ::  (p -> And q (Not q)) -> Not p
notElim      ::  Not (Not p) -> p

\begin{code}
ex21a :: Impl (And p q) q
ex21a = implIntro andElimR

ex21b :: Or p q -> Or q p
ex21b opq = orElim opq (\p -> orIntroR p) (\q -> orIntroL q)
\end{code}

The last exercise is basically a machine-checked version of the following
pen-and-paper proof:

Assume that p ∨ q holds. We proceed by case distinction on this disjunction.

Case p: In this case, assume that p holds. Therefore, by rule orIntroR we know
that r ∨ p holds for any r; in particular, it holds for r=q, and hence q ∨ p
holds.

Case q: In this case, assume that q holds. Therefore, we know by rule orIntroL
that q ∨ r holds for any r, in particular also for r=p, therefore q ∨ p holds.

\begin{code}

ex21c :: forall p. Or p (Not p)
ex21c = notElim $ nnlem -- We show that it is not the case that `Or p (Not p)`
                        -- is false
  where nnlem :: Not (Not (Or p (Not p)))
        nnlem = notIntro $ \nlem -> nlemToContradiction nlem
        -- we show this by assuming that Or p (Not p) is false
        -- in other words, Not (Or p (Not p)) holds. Using
        -- this assumption, we derive a contradiction. Therefore
        -- Not (Or p (Not p)) must be false; in other words,
        -- Not (Not (Or p (Not p))) holds.
        nlemToContradiction :: Not (Or p (Not p))
                            -> And p (Not p)
        -- Showing this involves two cases:
        -- 1. Showing that Not (Or p (Not p)) implies p
        -- 2. Showing that Not (Or p (Not p)) implies Not p
        nlemToContradiction nlem = andIntro (p nlem) (np nlem)
        -- We can show the second case by assuming p and deriving
        -- a contradiction. Then Not p must hold
        np :: Not (Or p (Not p)) -> Not p
        -- We do this by showing And (Or p (Not p)) (Not (Or p (Not p))), given
        -- p Since the above statement is of the form And r (Not r), this is a
        -- contradiction. Therefore we conclude Not p.
        np nlem = notIntro (\p -> andIntro (orIntroL p) nlem)
        p :: Not (Or p (Not p)) -> p
        -- To show p when assuming (Not (Or p (Not p))), we again need
        -- show that p cannot be false; i.e. we show that Not (Not p)
        p nlem = notElim $ nnp nlem
        nnp :: Not (Or p (Not p)) -> Not (Not p)
        -- To show this, we assume Not p, then derive the same contradiction as
        -- above.
        nnp nlem = notIntro $ \np -> andIntro (orIntroR np) nlem

-- Alternative solution via And (Or p (Not p)) (Not (Or p(Not p)))
ex21c' :: forall p. Or p (Not p)
ex21c' = notElim $ nnlem
  where nnlem :: Not (Not (Or p (Not p)))
        nnlem = notIntro $ \nlem -> nlemToContradiction nlem
        nlemToContradiction :: Not (Or p (Not p))
                            -> And (Or p (Not p)) (Not (Or p (Not p)))
        nlemToContradiction nlem = andIntro (x nlem) nlem
        x :: Not (Or p (Not p)) -> Or p (Not p)
        x nlem = orIntroR $ y nlem
        y :: Not (Or p (Not p)) -> Not p
        y nlem = notIntro $ \p -> z nlem p
        z :: Not (Or p (Not p)) -> p -> And (Or p (Not p)) (Not (Or p (Not p)))
        z nlem p = andIntro (orIntroL p) nlem
\end{code}
