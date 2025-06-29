@..\install_prereq\initspool install_coupon_caps_tt

PROMPT Create package tt_coupon_caps
@tt_coupon_caps.pks
@tt_coupon_caps.pkb

PROMPT Add the tt_units record, reading in JSON file from INPUT_DIR
DECLARE

  l_api_lis L1_Chr_Arr := L1_Chr_Arr(
      'Coupon_Caps_MOD',
      'Coupon_Caps_RSF',
      'Coupon_Caps_RSF_Bug',
      'Coupon_Caps_PLF'
  );
  PROCEDURE Add_API (p_purely_wrap_api_function_nm  VARCHAR2) IS
  BEGIN
    Trapit.Add_Ttu(
            p_unit_test_package_nm         => 'TT_COUPON_CAPS',
            p_purely_wrap_api_function_nm  => p_purely_wrap_api_function_nm, 
            p_group_nm                     => 'coupon_caps',
            p_active_yn                    => 'Y', 
            p_input_file                   => 'tt_coupon_caps.purely_wrap_coupon_caps_inp.json',
            p_title                        => 'Coupon Caps - ' || CASE p_purely_wrap_api_function_nm
                                                                       WHEN 'Coupon_Caps_MOD'     THEN 'Model Clause'
                                                                       WHEN 'Coupon_Caps_RSF'     THEN 'Recursive Query'
                                                                       WHEN 'Coupon_Caps_RSF_Bug' THEN 'Recursive Query, with bug'
                                                                       ELSE                            'Pipelined Function' END
    );
  END Add_API;
BEGIN

  FOR i IN 1..l_api_lis.COUNT LOOP
    Add_API(l_api_lis(i));
  END LOOP;

END;
/
@..\install_prereq\endspool
exit