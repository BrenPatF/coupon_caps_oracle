DROP TYPE IF EXISTS caps_tab
/
CREATE OR REPLACE TYPE caps_obj AS OBJECT (
        coupon          VARCHAR2(10), 
        value           INTEGER,
        cap_name        VARCHAR2(10),
        cap_sequence    INTEGER, 
        cap_limit       INTEGER, 
        usage           INTEGER, 
        val_left        INTEGER,
        cap_left        INTEGER
)
/
CREATE OR REPLACE TYPE caps_tab AS TABLE OF caps_obj
/
CREATE OR REPLACE FUNCTION caps RETURN caps_tab PIPELINED IS
    CURSOR cap_coupon_csr IS
    SELECT cou.coupon,
           cou.value,
           cap.cap_name,
           ccm.cap_sequence,
           cap.cap_limit
      FROM cap_data           cap
      JOIN coupon_cap_mapping ccm ON ccm.cap_name = cap.cap_name
      JOIN coupon_data        cou ON cou.coupon = ccm.coupon
     ORDER BY cou.coupon, ccm.cap_sequence;
    l_pri_coupon            VARCHAR2(10) := 'NA';
    TYPE cap_left_ibt IS    TABLE OF NUMBER INDEX BY VARCHAR2(10);
    l_cap_left              cap_left_ibt;
    l_usage                 PLS_INTEGER;
    l_val_left              PLS_INTEGER;
BEGIN
    FOR rec IN (SELECT cap_name, cap_limit FROM cap_data) LOOP
        l_cap_left(rec.cap_name) := rec.cap_limit;
    END LOOP;
    FOR rec IN cap_coupon_csr LOOP
        IF rec.coupon != l_pri_coupon THEN
            l_val_left := rec.value;
        END IF;
        l_usage                  := Least (l_val_left, l_cap_left(rec.cap_name));
        l_val_left               := l_val_left - l_usage;
        l_cap_left(rec.cap_name) := l_cap_left(rec.cap_name) - l_usage;
        l_pri_coupon             := rec.coupon;
        PIPE ROW(caps_obj(rec.coupon,
                          rec.value,
                          rec.cap_name,
                          rec.cap_sequence,
                          rec.cap_limit,
                          l_usage,
                          l_val_left,
                          l_cap_left(rec.cap_name)));
    END LOOP;
END caps;
/
SHO ERR
