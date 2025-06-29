CREATE OR REPLACE PACKAGE Coupon_Caps AS

PROCEDURE Create_Test_Data(            
            p_n_cou                        PLS_INTEGER,
            p_n_cap                        PLS_INTEGER,
            p_n_cap_per_cou                PLS_INTEGER);
PROCEDURE Run_Data_Point(
            p_n_cou                        PLS_INTEGER,
            p_n_cap_per_cou                PLS_INTEGER,
            p_n_cap                        PLS_INTEGER,
            p_n_views                      PLS_INTEGER,
            p_ts                           PLS_INTEGER,
            p_get_xplan                    BOOLEAN := FALSE);

END Coupon_Caps;
/
SHO ERR

