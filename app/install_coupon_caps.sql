@..\install_prereq\initspool install_coupon_caps

@coupon_caps_tables
@coupon_caps_function
@coupon_caps_views
@coupon_caps.pks
@coupon_caps.pkb
EXECUTE DBMS_Stats.Gather_Schema_Stats(ownname => 'APP');
@..\install_prereq\endspool
exit