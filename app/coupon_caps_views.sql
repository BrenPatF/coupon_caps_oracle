PROMPT coupon_caps_plf_v: Pipelined function
CREATE OR REPLACE VIEW coupon_caps_plf_v AS
SELECT * FROM TABLE(caps)
/
PROMPT coupon_caps_mod_v: Model clause
CREATE OR REPLACE VIEW coupon_caps_mod_v AS
WITH cap_coupon_map AS (
SELECT Row_Number() OVER (ORDER BY cou.coupon, ccm.cap_sequence) ccm_ind,
       cou.coupon,
       cou.value,
       cap.cap_name,
       ccm.cap_sequence,
       cap.cap_limit
  FROM cap_data           cap
  JOIN coupon_cap_mapping ccm ON ccm.cap_name = cap.cap_name
  JOIN coupon_data        cou ON cou.coupon = ccm.coupon 
)
SELECT *
  FROM cap_coupon_map
MODEL 
  DIMENSION BY (ccm_ind)
  MEASURES (Lag(ccm_ind, 1, ccm_ind) OVER (PARTITION BY cap_name ORDER BY coupon) pri_ccm_ind, 
            coupon,
            Lag(coupon, 1, 'NA') OVER (ORDER BY ccm_ind) pri_coupon,
            value,
            cap_name,
            cap_sequence, 
            cap_limit,
            0 usage,
            value val_left,
            cap_limit cap_left)
  RULES UPDATE ITERATE (1000000) UNTIL coupon[ITERATION_NUMBER + 1] IS NULL (
    usage[ITERATION_NUMBER + 1]     = CASE WHEN coupon[ITERATION_NUMBER + 1] != pri_coupon[ITERATION_NUMBER + 1] THEN
                                                    Least (val_left[ITERATION_NUMBER + 1], cap_left[pri_ccm_ind[ITERATION_NUMBER + 1]])
                                           ELSE     Least (val_left[ITERATION_NUMBER], cap_left[pri_ccm_ind[ITERATION_NUMBER + 1]])
                                      END,
    val_left[ITERATION_NUMBER + 1]  = CASE WHEN coupon[ITERATION_NUMBER + 1] != pri_coupon[ITERATION_NUMBER + 1] THEN
                                                    val_left[ITERATION_NUMBER + 1] - usage[ITERATION_NUMBER + 1]
                                           ELSE     val_left[ITERATION_NUMBER] - usage[ITERATION_NUMBER + 1]
                                      END,
    cap_left[ITERATION_NUMBER + 1]  = cap_left[pri_ccm_ind[ITERATION_NUMBER + 1]] - usage[ITERATION_NUMBER + 1]
  )
/
PROMPT coupon_caps_rsf_v: Recursive subquery factors
CREATE OR REPLACE VIEW coupon_caps_rsf_v AS
WITH coupons AS (
    SELECT cou.coupon,
           Row_Number() OVER (ORDER BY cou.coupon) cou_ind,
           cou.value
      FROM coupon_data cou
     WHERE EXISTS (SELECT 1 FROM coupon_cap_mapping ccm WHERE ccm.coupon = cou.coupon)
), rsf (coupon, cou_ind, value, cap_name, cap_sequence, cap_limit, usage, cap_left) AS (
    SELECT NULL coupon,
           0 cou_ind,
           0 value,
           cap_name,
           0 cap_sequence,
           cap_limit,
           0 usage, 
           cap_limit cap_left
      FROM cap_data
     UNION ALL
    SELECT cou.coupon,
           cou.cou_ind,
           cou.value,
           cap.cap_name,
           ccm.cap_sequence,
           rsf.cap_limit,
           Greatest(0, Least(cou.value - 
                Nvl(Sum(rsf.cap_left)
                    OVER (ORDER BY ccm.cap_sequence
                          ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0), rsf.cap_left)) usage, 
           rsf.cap_left - 
           Nvl2(ccm.cap_sequence, Greatest(0, Least(cou.value - 
                Nvl(Sum(rsf.cap_left)
                    OVER (ORDER BY ccm.cap_sequence
                          ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0), rsf.cap_left)), 0) cap_left
      FROM rsf
      JOIN coupons cou ON cou.cou_ind = rsf.cou_ind + 1
      JOIN cap_data cap ON cap.cap_name = rsf.cap_name
      LEFT JOIN coupon_cap_mapping ccm ON ccm.coupon = cou.coupon AND ccm.cap_name = rsf.cap_name
) 
SELECT coupon, cou_ind, value, cap_name, cap_sequence, cap_limit, usage, 
        value - Sum(usage) OVER (PARTITION BY coupon ORDER BY cap_sequence) val_left,
        cap_left
  FROM rsf
 WHERE coupon IS NOT NULL AND cap_sequence IS NOT NULL
/
PROMPT coupon_caps_rsf_bug_v: Recursive subquery factors, with bug
CREATE OR REPLACE VIEW coupon_caps_rsf_bug_v AS
WITH coupons AS (
    SELECT cou.coupon,
           Row_Number() OVER (ORDER BY cou.coupon) cou_ind,
           cou.value
      FROM coupon_data cou
     WHERE EXISTS (SELECT 1 FROM coupon_cap_mapping ccm WHERE ccm.coupon = cou.coupon)
), rsf (coupon, cou_ind, value, cap_name, cap_sequence, cap_limit, usage, cap_left) AS (
    SELECT NULL coupon,
           0 cou_ind,
           0 value,
           cap_name,
           0 cap_sequence,
           cap_limit,
           0 usage, 
           cap_limit cap_left
      FROM cap_data
     UNION ALL
    SELECT cou.coupon,
           cou.cou_ind,
           cou.value,
           cap.cap_name,
           ccm.cap_sequence,
           rsf.cap_limit,
           Greatest(0, Least(cou.value - 
                Nvl(Sum(rsf.cap_left)
                    OVER (ORDER BY ccm.cap_sequence
                          ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0), rsf.cap_left)) usage, 
           rsf.cap_left - 
           Greatest(0, Least(cou.value - 
                Nvl(Sum(rsf.cap_left)
                    OVER (ORDER BY ccm.cap_sequence
                          ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0), rsf.cap_left)) cap_left
      FROM rsf
      JOIN coupons cou ON cou.cou_ind = rsf.cou_ind + 1
      JOIN cap_data cap ON cap.cap_name = rsf.cap_name
      LEFT JOIN coupon_cap_mapping ccm ON ccm.coupon = cou.coupon AND ccm.cap_name = rsf.cap_name
) 
SELECT coupon, cou_ind, value, cap_name, cap_sequence, cap_limit, usage, 
        value - Sum(usage) OVER (PARTITION BY coupon ORDER BY cap_sequence) val_left,
        cap_left
  FROM rsf
 WHERE coupon IS NOT NULL AND cap_sequence IS NOT NULL
/
PROMPT coupon_caps_plf_agg_v: Pipelined function
CREATE OR REPLACE VIEW coupon_caps_plf_agg_v AS
SELECT Count(CASE WHEN usage > 0 THEN 1 END) n_pos_usages,
       Count(*) n_rows,
       Sum(usage) sum_usage
  FROM coupon_caps_plf_v
/
PROMPT coupon_caps_mod_agg_v: Model clause
CREATE OR REPLACE VIEW coupon_caps_mod_agg_v AS
SELECT Count(CASE WHEN usage > 0 THEN 1 END) n_pos_usages,
       Count(*) n_rows,
       Sum(usage) sum_usage
  FROM coupon_caps_mod_v
/
PROMPT coupon_caps_rsf_agg_v: Recursive subquery factors
CREATE OR REPLACE VIEW coupon_caps_rsf_agg_v AS
SELECT Count(CASE WHEN usage > 0 THEN 1 END) n_pos_usages,
       Count(*) n_rows,
       Sum(usage) sum_usage
  FROM coupon_caps_rsf_v
/
