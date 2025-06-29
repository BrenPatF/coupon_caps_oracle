@..\install_prereq\initspool c_test_data
PROMPT Create data
BEGIN
  Coupon_Caps.Create_Test_Data(            
            p_n_cou           => 50,
            p_min_cou         => 100,
            p_max_cou         => 200,
            p_n_cap           => 5,
            p_min_cap         => 1000,
            p_max_cap         => 5000,
            p_n_cap_per_cou   => 2);
END;
/
PROMPT coupon_data
SELECT * FROM coupon_data
/
PROMPT cap_data
SELECT * FROM cap_data
/
PROMPT coupon_cap_mapping
SELECT * FROM coupon_cap_mapping
/
@..\install_prereq\endspool