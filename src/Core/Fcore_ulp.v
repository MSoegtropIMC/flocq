Require Import Fcore_Raux.
Require Import Fcore_defs.
Require Import Fcore_rnd.
Require Import Fcore_generic_fmt.
Require Import Fcore_float_prop.

Section Fcore_ulp.

Variable beta : radix.

Notation bpow e := (bpow beta e).

Variable fexp : Z -> Z.

Variable prop_exp : valid_exp fexp.

Definition ulp x := bpow (fexp (projT1 (ln_beta beta x))).

Definition F := generic_format beta fexp.

Theorem ulp_pred_succ_pt_pos :
  forall x xd xu,
  Rlt 0 x -> ~ F x ->
  Rnd_DN_pt F x xd -> Rnd_UP_pt F x xu ->
  (xu = xd + ulp x)%R.
Proof.
intros x xd xu Hx1 Fx Hd1 Hu1.
unfold ulp.
destruct (ln_beta beta x) as (ex, Hx2).
simpl.
specialize (Hx2 (Rgt_not_eq _ _ Hx1)).
rewrite Rabs_pos_eq in Hx2.
destruct (Z_lt_le_dec (fexp ex) ex) as [He1|He1].
(* positive big *)
assert (Hd2 := generic_DN_pt_pos _ _ prop_exp _ _ Hx2).
assert (Hu2 := generic_UP_pt_pos _ _ prop_exp _ _ Hx2).
rewrite (Rnd_DN_pt_unicity _ _ _ _ Hd1 Hd2).
rewrite (Rnd_UP_pt_unicity _ _ _ _ Hu1 Hu2).
unfold F2R. simpl.
rewrite Zceil_floor_neq.
rewrite plus_Z2R, Rmult_plus_distr_r.
now rewrite Rmult_1_l.
intros Hx4.
assert (Hx5 : x = F2R (Float beta (Zfloor (x * bpow (- fexp ex))) (fexp ex))).
unfold F2R. simpl.
rewrite Hx4.
rewrite Rmult_assoc.
rewrite <- bpow_add.
rewrite Zplus_opp_l.
now rewrite Rmult_1_r.
apply Fx.
rewrite Hx5.
apply Hd2.
(* positive small *)
rewrite Rnd_UP_pt_unicity with F x xu (bpow (fexp ex)).
rewrite Rnd_DN_pt_unicity with F x xd R0.
now rewrite Rplus_0_l.
exact Hd1.
now apply generic_DN_pt_small_pos with ex.
exact Hu1.
now apply generic_UP_pt_small_pos.
(* . *)
now apply Rlt_le.
Qed.

Theorem ulp_pred_succ_pt :
  forall x xd xu,
  ~ F x ->
  Rnd_DN_pt F x xd -> Rnd_UP_pt F x xu ->
  (xu = xd + ulp x)%R.
Proof.
intros x xd xu Fx Hd1 Hu1.
destruct (Rdichotomy x 0) as [Hx2|Hx2].
(* zero *)
intros Hx.
elim Fx.
rewrite Hx.
apply generic_format_0.
(* negative *)
assert (Hu2 : Rnd_DN_pt F (-x) (-xu)).
apply Rnd_UP_DN_pt_sym.
now eapply generic_format_satisfies_any.
now rewrite 2!Ropp_involutive.
assert (Hd2 : Rnd_UP_pt F (-x) (-xd)).
apply Rnd_DN_UP_pt_sym.
now eapply generic_format_satisfies_any.
now rewrite 2!Ropp_involutive.
rewrite <- (Ropp_involutive xd).
rewrite ulp_pred_succ_pt_pos with (3 := Hu2) (4 := Hd2).
unfold ulp.
rewrite ln_beta_opp.
ring.
rewrite <- Ropp_0.
now apply Ropp_lt_contravar.
intros ((xm, xe), (H1, H2)).
apply Fx.
exists (Float beta (-xm) xe).
split.
rewrite <- opp_F2R.
rewrite <- H1.
now rewrite Ropp_involutive.
now rewrite <- ln_beta_opp.
(* positive *)
now apply ulp_pred_succ_pt_pos.
Qed.

Theorem ulp_error :
  forall rnd : R -> R,
  Rounding_for_Format F rnd ->
  forall x,
  (Rabs (rnd x - x) < ulp x)%R.
Proof.
intros rnd Hrnd x.
assert (Hs := generic_format_satisfies_any beta _ prop_exp).
destruct (proj1 (satisfies_any_imp_DN F Hs) x) as (d, Hd).
destruct (Rle_lt_or_eq_dec d x) as [Hxd|Hxd].
(* x <> rnd x *)
apply Hd.
assert (Fx : ~F x).
intros Fx.
apply Rlt_not_le with (1 := Hxd).
apply Req_le.
apply sym_eq.
now apply Rnd_DN_pt_idempotent with (1 := Hd).
destruct (proj1 (satisfies_any_imp_UP F Hs) x) as (u, Hu).
assert (Hxu : (x < u)%R).
destruct (Rle_lt_or_eq_dec x u) as [Hxu|Hxu].
apply Hu.
exact Hxu.
elim Fx.
rewrite Hxu.
apply Hu.
rewrite (ulp_pred_succ_pt _ _ _ Fx Hd Hu) in Hxu, Hu.
destruct (Rnd_DN_or_UP_pt _ _ Hrnd _ _ _ Hd Hu) as [Hr|Hr] ;
  rewrite Hr ; clear Hr.
rewrite <- Ropp_minus_distr.
rewrite Rabs_Ropp, Rabs_pos_eq.
apply Rplus_lt_reg_r with d.
now replace (d + (x - d))%R with x by ring.
apply Rle_0_minus.
apply Hd.
rewrite Rabs_pos_eq.
apply Rplus_lt_reg_r with (x - ulp x)%R.
now ring_simplify.
apply Rle_0_minus.
apply Hu.
(* x = rnd x *)
rewrite Hxd in Hd.
rewrite (proj2 (proj2 Hrnd)).
unfold Rminus.
rewrite Rplus_opp_r.
rewrite Rabs_R0.
apply bpow_gt_0.
apply Hd.
Qed.

Theorem ulp_half_error_pt :
  forall x xr,
  Rnd_N_pt F x xr ->
  (Rabs (xr - x) <= /2 * ulp x)%R.
Proof.
intros x xr Hxr.
assert (Hs := generic_format_satisfies_any beta _ prop_exp).
destruct (proj1 (satisfies_any_imp_DN F Hs) x) as (d, Hd).
destruct (Rle_lt_or_eq_dec d x) as [Hxd|Hxd].
(* x <> rnd x *)
apply Hd.
assert (Fx : ~F x).
intros Fx.
apply Rlt_not_le with (1 := Hxd).
apply Req_le.
apply sym_eq.
now apply Rnd_DN_pt_idempotent with (1 := Hd).
destruct (proj1 (satisfies_any_imp_UP F Hs) x) as (u, Hu).
rewrite (ulp_pred_succ_pt _ _ _ Fx Hd Hu) in Hu.
destruct Hxr as (Hr1, Hr2).
assert (Hdx : (Rabs (d - x) = x - d)%R).
rewrite <- Ropp_minus_distr.
rewrite Rabs_Ropp.
apply Rabs_pos_eq.
apply Rle_0_minus.
apply Hd.
assert (Hux : (Rabs (d + ulp x - x) = d + ulp x - x)%R).
apply Rabs_pos_eq.
apply Rle_0_minus.
apply Hu.
destruct (Rle_or_lt (x - d) (d + ulp x - x)) as [H|H].
(* . rnd(x) = rndd(x) *)
apply Rle_trans with (1 := Hr2 _ (proj1 Hd)).
rewrite Hdx.
apply Rmult_le_reg_l with 2%R.
now apply (Z2R_lt 0 2).
rewrite Rmult_plus_distr_r.
rewrite Rmult_1_l.
apply Rle_trans with (1 := Rplus_le_compat_l (x - d) _ _ H).
field_simplify.
apply Rle_refl.
(* . rnd(x) = rndu(x) *)
apply Rle_trans with (1 := Hr2 _ (proj1 Hu)).
rewrite Hux.
apply Rmult_le_reg_l with 2%R.
now apply (Z2R_lt 0 2).
rewrite Rmult_plus_distr_r.
rewrite Rmult_1_l.
apply Rlt_le.
apply Rlt_le_trans with (1 := Rplus_lt_compat_l (d + ulp x - x) _ _ H).
field_simplify.
apply Rle_refl.
(* x = rnd x *)
rewrite Hxd in Hd.
rewrite Rnd_N_pt_idempotent with (1 := Hxr).
unfold Rminus.
rewrite Rplus_opp_r.
rewrite Rabs_R0.
apply Rmult_le_pos.
apply Rlt_le.
apply Rinv_0_lt_compat.
now apply (Z2R_lt 0 2).
apply bpow_ge_0.
apply Hd.
Qed.

Theorem ulp_monotone :
  ( forall m n, (m <= n)%Z -> (fexp m <= fexp n)%Z ) ->
  forall x y: R,
  (0 < x)%R -> (x <= y)%R ->
  (ulp x <= ulp y)%R.
Proof.
intros Hm x y Hx Hxy.
apply -> bpow_le.
apply Hm.
now apply ln_beta_monotone.
Qed.

Theorem ulp_bpow :
  forall e, ulp (bpow e) = bpow (fexp (e + 1)).
intros e.
unfold ulp.
rewrite (ln_beta_unique beta (bpow e) (e + 1)).
easy.
rewrite Rabs_pos_eq.
split.
apply -> bpow_le.
omega.
apply -> bpow_lt.
apply Zlt_succ.
apply bpow_ge_0.
Qed.

Theorem ulp_DN_pt_eq :
  forall x d : R,
  (0 < d)%R ->
  Rnd_DN_pt F x d ->
  ulp d = ulp x.
Proof.
intros x d Hd Hxd.
unfold ulp.
apply (f_equal (fun e => bpow (fexp e))).
apply ln_beta_unique.
rewrite (Rabs_pos_eq d).
destruct (ln_beta beta x) as (ex, He).
simpl.
assert (Hx: (0 < x)%R).
apply Rlt_le_trans with (1 := Hd).
apply Hxd.
specialize (He (Rgt_not_eq _ _ Hx)).
rewrite Rabs_pos_eq in He. 2: now apply Rlt_le.
split.
assert (Rnd_DN_pt F (bpow (ex - 1)) (bpow (ex - 1))).
apply Rnd_DN_pt_refl.
apply generic_format_bpow.
destruct (Zle_or_lt ex (fexp ex)).
elim Rgt_not_eq with (1 := Hd).
apply Rnd_DN_pt_unicity with (1 := Hxd).
now apply generic_DN_pt_small_pos with (2 := He).
ring_simplify (ex - 1 + 1)%Z.
omega.
apply (Rnd_DN_pt_monotone _ _ _ _ _ H Hxd (proj1 He)).
apply Rle_lt_trans with (2 := proj2 He).
apply Hxd.
now apply Rlt_le.
Qed.

End Fcore_ulp.