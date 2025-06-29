CREATE OR REPLACE PACKAGE TT_Coupon_Caps AS
/***************************************************************************************************
Name: TT_Coupon_Caps.pks               Author: Brendan Furey                       Date: 10-May-2025

Component package script in ' in Oracle' project

    GitHub: https://github.com/BrenPatF/oracle_coupon_caps
    Blog:   https://brenpatf.github.io

PACKAGES
====================================================================================================
|  Package           | Notes                                                                       |
|==================================================================================================|
| *TT_Coupon_Caps*   | Unit testing the solution methods for the coupons and caps problem          |
====================================================================================================

This file has the TT_Coupon_Caps package spec
***************************************************************************************************/
FUNCTION Coupon_Caps_MOD(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;
FUNCTION Coupon_Caps_RSF(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;
FUNCTION Coupon_Caps_RSF_Bug(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;
FUNCTION Coupon_Caps_PLF(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;

END TT_Coupon_Caps;
/
