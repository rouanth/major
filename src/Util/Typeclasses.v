(* -*- coding: utf-8 -*- *)

Require Import Coq.Program.Basics.

Module Typeclasses.

Local Open Scope program_scope.

Reserved Notation "f <$> a" (at level 40).

Class Functor f := {
  fmap {A B} : (A -> B) -> f A -> f B where "f <$> a" := (fmap f a);
  functor_hom : forall {A B C} (g : B -> C) (h : A -> B) x,
    fmap (g ∘ h) x = (fmap g ∘ fmap h) x;
  functor_id : forall A x, @fmap A A id x = id x;
}.

Notation "f <$> a" := (fmap f a).

Reserved Notation "a <*> b" (at level 40).

Class Applicative f:= {
  applic_is_functor :> Functor f;
  pure : forall {A}, A -> f A;
  comb : forall {A B}, f (A -> B) -> f A -> f B where "a <*> b" := (comb a b);
  applic_id : forall {A} (x : f A), comb (pure id) x = x;
  applic_hom : forall {A B} (f : A -> B) x,
    pure f <*> pure x = pure (f x);
  applic_inter : forall {A B} (u : f (A -> B)) y,
    u <*> pure y = pure (fun f => f y) <*> u;
  applic_comp : forall {A B C} (u : f (B -> C)) (v : f (A -> B)) w,
    u <*> comb v w = pure compose <*> u <*> v <*> w;
}.

Notation "a <*> b" := (comb a b).

Notation "a <$ b" := ((comb ∘ pure ∘ const) a b) (at level 40).

Notation "a *> b" := ((id <$ a) <*> b) (at level 40).

Notation "a <* b" := (const <$> a <*> b) (at level 40).

Reserved Notation "a <+> b" (at level 30).

Class Monoid f := {
  mempty  : forall {A : Type}, f A;
  mappend : forall {A}, f A -> f A -> f A where "a <+> b" := (mappend a b);
  monoid_left_empty : forall {A} (x : f A),
    mempty <+> x = x;
  monoid_right_empty : forall {A} (x : f A),
    x <+> mempty = x;
  monoid_assoc : forall {A} (x y z : f A),
    (x <+> y) <+> z = x <+> (y <+> z);
}.

Notation "a <+> b" := (mappend a b).

Class Alternative f := {
  altern_is_applic :> Applicative f;
  altern_is_monoid :> Monoid f;
}.

Definition altern_or {f: Type -> Type} {falt: Alternative f}
  {A} (a b: f A) := mappend a b.

Notation "a <|> b" := (altern_or a b) (at level 30).

Instance option_Functor : Functor option := {
  fmap A B f m := match m with | None => None | Some m' => Some (f m') end;
}.
Proof.
  destruct x; auto...
  destruct x; auto...
Defined.

Instance option_Applicative : Applicative option := {
  pure A x := Some x;
  comb A B f x := match f with | None => None | Some f' => fmap f' x end;
}.
Proof.
  destruct x; auto...
  auto...
  auto...
  destruct w; destruct v; destruct u; auto...
Defined.

Instance option_Monoid : Monoid option := {
  mempty A := None;
  mappend A l r := match l with None => r | Some x => Some x end;
}.
Proof.
  auto...
  destruct x; auto...
  destruct x; auto...
Defined.

Instance option_Alternative : Alternative option := {}.

Local Close Scope program_scope.

End Typeclasses.

