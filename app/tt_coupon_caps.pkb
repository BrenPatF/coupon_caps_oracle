CREATE OR REPLACE PACKAGE BODY TT_Coupon_Caps AS
/***************************************************************************************************
Name: TT_Coupon_Caps.pkb               Author: Brendan Furey                       Date: 10-May-2025

Component package script in ' in Oracle' project

    GitHub: https://github.com/BrenPatF/oracle_coupon_caps
    Blog:   https://brenpatf.github.io

PACKAGES
====================================================================================================
|  Package           | Notes                                                                       |
|==================================================================================================|
| *TT_Coupon_Caps*   | Unit testing the solution methods for the coupons and caps problem          |
====================================================================================================

This file has the TT_Coupon_Caps package body
***************************************************************************************************/
PROCEDURE add_Cous(
            p_cou_2lis                        L2_chr_arr) IS
BEGIN

  FOR i IN 1..p_cou_2lis.COUNT LOOP
    INSERT INTO coupon_data VALUES (p_cou_2lis(i)(1), p_cou_2lis(i)(2));
  END LOOP;

END add_Cous;

PROCEDURE add_Caps(
            p_cap_2lis                       L2_chr_arr) IS
BEGIN

  FOR i IN 1..p_cap_2lis.COUNT LOOP
    INSERT INTO cap_data VALUES (p_cap_2lis(i)(1), p_cap_2lis(i)(2));
  END LOOP;

END add_Caps;

PROCEDURE add_Cou_Caps(
            p_cou_cap_2lis                   L2_chr_arr) IS
BEGIN

  FOR i IN 1..p_cou_cap_2lis.COUNT LOOP
    INSERT INTO coupon_cap_mapping VALUES (p_cou_cap_2lis(i)(1), p_cou_cap_2lis(i)(2), p_cou_cap_2lis(i)(3));
  END LOOP;

END add_Cou_Caps;

FUNCTION purely_Wrap_Cou_Caps(
              p_view_name                    VARCHAR2,
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr IS
  l_act_2lis        L2_chr_arr := L2_chr_arr();
  l_result_lis      L1_chr_arr;
BEGIN

  DELETE coupon_data;
  DELETE cap_data;
  DELETE coupon_cap_mapping;

  add_Cous     (p_cou_2lis     => p_inp_3lis(1));
  add_Caps     (p_cap_2lis     => p_inp_3lis(2));
  add_Cou_Caps (p_cou_cap_2lis => p_inp_3lis(3));

  l_act_2lis.EXTEND;
  l_act_2lis(1) := Utils.View_To_List(
                                p_view_name     => p_view_name,
                                p_sel_value_lis => L1_chr_arr('coupon', 'cap_name', 'usage'),
                                p_where         => '1=1',
                                p_order_by      => 'coupon, cap_sequence');
  ROLLBACK;
  RETURN l_act_2lis;

END purely_Wrap_Cou_Caps;

FUNCTION Coupon_Caps_MOD(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr IS
BEGIN
    RETURN purely_Wrap_Cou_Caps(
              p_view_name   => 'coupon_caps_mod_v',
              p_inp_3lis    => p_inp_3lis);
END Coupon_Caps_MOD;

FUNCTION Coupon_Caps_RSF(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr IS
BEGIN
    RETURN purely_Wrap_Cou_Caps(
              p_view_name   => 'coupon_caps_rsf_v',
              p_inp_3lis    => p_inp_3lis);
END Coupon_Caps_RSF;

FUNCTION Coupon_Caps_RSF_Bug(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr IS
BEGIN
    RETURN purely_Wrap_Cou_Caps(
              p_view_name   => 'coupon_caps_rsf_bug_v',
              p_inp_3lis    => p_inp_3lis);
END Coupon_Caps_RSF_Bug;

FUNCTION Coupon_Caps_PLF(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr IS
BEGIN
    RETURN purely_Wrap_Cou_Caps(
              p_view_name   => 'coupon_caps_plf_v',
              p_inp_3lis    => p_inp_3lis);
END Coupon_Caps_PLF;

END TT_Coupon_Caps;
/
