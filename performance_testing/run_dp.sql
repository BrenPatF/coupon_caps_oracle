DEFINE N_COU = &1
DEFINE N_CAP_PER_COU = &2
DEFINE N_CAP = &3
DEFINE N_VIEWS = &4
DEFINE XPLAN_YN = '&5'

PROMPT Create data - &N_COU coupons, &N_CAP_PER_COU caps per coupon, &N_CAP caps
TRUNCATE TABLE coupon_cap_mapping
/
TRUNCATE TABLE cap_data
/
TRUNCATE TABLE coupon_data
/
DECLARE
  l_n_cou               PLS_INTEGER := &N_COU;
  l_n_cap_per_cou       PLS_INTEGER := &N_CAP_PER_COU;
  l_n_cap               PLS_INTEGER := &N_CAP;
  l_n_views             PLS_INTEGER := &N_VIEWS;
  l_get_xplan           BOOLEAN := '&XPLAN_YN' = 'Y';
BEGIN

  Coupon_Caps.Run_Data_Point(
            p_n_cou           => l_n_cou,
            p_n_cap_per_cou   => l_n_cap_per_cou,
            p_n_cap           => l_n_cap,
            p_n_views         => l_n_views,
            p_ts              => :TIMER_SET,
            p_get_xplan       => l_get_xplan);
END;
/
