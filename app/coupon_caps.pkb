CREATE OR REPLACE PACKAGE BODY Coupon_Caps AS

MIN_COU         CONSTANT PLS_INTEGER := 100;
MAX_COU         CONSTANT PLS_INTEGER := 300;
MIN_CAP         CONSTANT PLS_INTEGER := 1000;
MAX_CAP         CONSTANT PLS_INTEGER := 800000;

PROCEDURE Create_Test_Data(            
            p_n_cou                        PLS_INTEGER,
            p_n_cap                        PLS_INTEGER,
            p_n_cap_per_cou                PLS_INTEGER) IS
  l_int       PLS_INTEGER;
  l_count     PLS_INTEGER;
  l_cou       VARCHAR2(10);
  l_cap       VARCHAR2(10);
  FUNCTION Rand_Int (
              p_min                          PLS_INTEGER,
              p_max                          PLS_INTEGER)
              RETURN                         PLS_INTEGER IS
  BEGIN
    RETURN TRUNC(DBMS_RANDOM.VALUE(p_min, p_max + 1));
  END Rand_Int;
BEGIN

  DELETE coupon_cap_mapping;
  DELETE cap_data;
  DELETE coupon_data;

  FOR i IN 1..p_n_cou LOOP

    l_int := Rand_Int(MIN_COU, MAX_COU);
    l_cou := 'COU' || LPad(i - 1, 5, '0');
    INSERT INTO coupon_data ( coupon, value )
    VALUES (l_cou, l_int);

    FOR j IN 1..p_n_cap_per_cou LOOP

      l_count := 0;
      WHILE l_count = 0 LOOP

        l_int := Rand_Int(1, p_n_cap);
        l_cap := 'CAP' || LPad(l_int - 1, 2, '0');
        INSERT INTO coupon_cap_mapping
        SELECT l_cou, l_cap, j
          FROM DUAL
         WHERE NOT EXISTS (SELECT 1 FROM coupon_cap_mapping ccm
                            WHERE ccm.coupon = l_cou
                              AND ccm.cap_name = l_cap);
        l_count := SQL%ROWCOUNT;

      END LOOP;
    END LOOP;

  END LOOP;

  FOR i IN 1..p_n_cap LOOP

    l_int := Rand_Int(MIN_CAP, MAX_CAP);
    INSERT INTO cap_data VALUES ('CAP' || LPad(i - 1, 2, '0'), l_int);

  END LOOP;
  DBMS_Stats.Gather_Schema_Stats(ownname => 'APP');
  Utils.L('Create_Test_Data ' || p_n_cou || ' - ' || p_n_cap_per_cou || ' - ' || p_n_cap);

END Create_Test_Data;

PROCEDURE Run_Data_Point(
            p_n_cou                        PLS_INTEGER,
            p_n_cap_per_cou                PLS_INTEGER,
            p_n_cap                        PLS_INTEGER,
            p_n_views                      PLS_INTEGER,
            p_ts                           PLS_INTEGER,
            p_get_xplan                    BOOLEAN := FALSE) IS
  l_view_lis            L1_chr_arr := L1_chr_arr('coupon_caps_plf_agg_v', 'coupon_caps_mod_agg_v', 'coupon_caps_rsf_agg_v');
  l_dp_name             VARCHAR2(100) := p_n_cou || ' - ' || p_n_cap_per_cou || ' - ' || p_n_cap;

  PROCEDURE do_Run (
            p_view_name                    VARCHAR2, 
            p_get_xplan                    BOOLEAN,
            p_timer_detail                 BOOLEAN) IS
    l_act_lis             L1_chr_arr;
    l_timer_name          VARCHAR2(100) := 'Sum-' || p_view_name;
    l_timer_name_det      VARCHAR2(100) := p_view_name || ' ' || l_dp_name;
    l_search              VARCHAR2(100) := p_view_name || TRUNC(DBMS_RANDOM.VALUE(100000, 999999));
  BEGIN

    IF p_get_xplan THEN
      l_timer_name := 'XPLAN-' || l_timer_name;
      l_timer_name_det := 'XPLAN-' || l_timer_name_det;
    END IF;
    IF p_timer_detail THEN
      l_timer_name := l_timer_name_det;
    END IF;
    l_act_lis := Utils.View_To_List(
                                p_view_name     => p_view_name,
                                p_sel_value_lis => L1_chr_arr('n_pos_usages', 'n_rows', 'sum_usage'),
                                p_hint          => CASE WHEN p_get_xplan THEN 'gather_plan_statistics ' || l_search END);
    Timer_Set.Increment_Time(p_ts, l_timer_name);
    IF p_get_xplan THEN
      Utils.L(Utils.Get_XPlan(p_sql_marker => l_search));
    END IF;
    Utils.L('Result for ' || l_timer_name_det || ': ' || l_act_lis(1));

  END do_Run;
BEGIN

  Create_Test_Data(            
            p_n_cou           => p_n_cou,
            p_n_cap           => p_n_cap,
            p_n_cap_per_cou   => p_n_cap_per_cou);
  Timer_Set.Increment_Time(p_ts, 'Create_Test_Data: ' || l_dp_name);

  FOR i IN 1..p_n_views LOOP

    do_Run(p_view_name    => l_view_lis(i), 
           p_get_xplan    => FALSE, 
           p_timer_detail => CASE WHEN p_n_views = 3 AND i < 3 THEN FALSE ELSE TRUE END);
    IF p_get_xplan AND (p_n_views = 2 OR i = 3) THEN

      do_Run(p_view_name    => l_view_lis(i),
             p_get_xplan    => TRUE,
             p_timer_detail => TRUE);

    END IF;

  END LOOP;

END Run_Data_Point;

END Coupon_Caps;
/
SHO ERR
