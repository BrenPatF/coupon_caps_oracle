@..\install_prereq\initspool get_plf_xplan
DECLARE 
  l_csr         SYS_REFCURSOR;
  l_cursor_rec  Utils.cursor_rec;
  l_res_lis     L1_chr_arr;
  l_count       PLS_INTEGER := 0;
BEGIN

Coupon_Caps.Create_Test_Data(            
            p_n_cou                        => 60000,
            p_n_cap                        => 22,
            p_n_cap_per_cou                => 12);
  OPEN l_csr FOR 
  '  SELECT /*+ gather_plan_statistics GET_PLF_XPLAN */
         cou.coupon,
         cou.value,
         cap.cap_name,
         ccm.cap_sequence,
         cap.cap_limit
    FROM cap_data           cap
    JOIN coupon_cap_mapping ccm ON ccm.cap_name = cap.cap_name
    JOIN coupon_data        cou ON cou.coupon = ccm.coupon
   ORDER BY cou.coupon, ccm.cap_sequence';

  l_cursor_rec := Utils.Prep_Cursor(x_csr => l_csr);
  FOR rec IN (
  SELECT COLUMN_VALUE
    BULK COLLECT INTO l_res_lis
    FROM TABLE(Utils.Pipe_Cursor(p_cursor_rec => l_cursor_rec))) LOOP
    l_count := l_count + 1;
  END LOOP;
  DBMS_SQL.Close_Cursor(l_cursor_rec.csr_id);

  Utils.W(Utils.Get_XPlan(p_sql_marker => 'GET_PLF_XPLAN'));
  Utils.W('Cursor returned ' || l_count || ' rows');
END;
/
@..\install_prereq\endspool