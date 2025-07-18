DEFINE lib=&1
/***************************************************************************************************
Name: c_utils_syns.sql                 Author: Brendan Furey                       Date: 08-Jun-2019

Creates synonyms for Utils components in app schema to lib schema.

This module comprises a set of generic user-defined Oracle types and a PL/SQL package of functions
and procedures of general utility.

    GitHub: https://github.com/BrenPatF/oracle_plsql_utils

There are install scripts for sys, lib and app schemas. However the base code alone can be installed
via install_utils.sql in an existing schema without executing the other scripts.

If the unit test code is to be installed, trapit_oracle_tester module must be installed after the 
base install: https://github.com/BrenPatF/trapit_oracle_tester.
====================================================================================================
|  Script                  |  Notes                                                                |
|==================================================================================================|
|  install_sys.sql         |  sys script creates: lib and app schemas; input_dir directory; grants |
|--------------------------|-----------------------------------------------------------------------|
|  install_utils.sql       |  Creates base components, including Utils package, in lib schema      |
|--------------------------|-----------------------------------------------------------------------|
|  install_utils_tt.sql    |  Creates unit test components that require a minimum Oracle database  |
|                          |  version of 12.2 in lib schema                                        |
|--------------------------|-----------------------------------------------------------------------|
|  grant_utils_to_app.sql  |  Grants privileges on Utils components from lib to app schema         |
|--------------------------|-----------------------------------------------------------------------|
|  install_col_group.sql   |  Creates components for the Col_Group example in app schema           |
|--------------------------|-----------------------------------------------------------------------|
| *c_utils_syns.sql*       |  Creates synonyms for Utils components in app schema to lib schema    |
====================================================================================================

Creates synonyms for Utils components in app schema to lib schema.

Synonyms created:

    Synonym             Object Type
    ==================  ============================================================================
    L1_chr_arr          Array (VARRAY)
    L1_num_arr          Array (VARRAY)
    chr_int_rec         Object
    chr_int_arr         Array (VARRAY)
    Utils               Package
    log_lines           Table

***************************************************************************************************/
PROMPT Creating synonyms for &lib Utils components...
CREATE OR REPLACE SYNONYM L1_chr_arr FOR &lib..L1_chr_arr
/
CREATE OR REPLACE SYNONYM L1_num_arr FOR &lib..L1_num_arr
/
CREATE OR REPLACE SYNONYM chr_int_rec FOR &lib..chr_int_rec
/
CREATE OR REPLACE SYNONYM chr_int_arr FOR &lib..chr_int_arr
/
CREATE OR REPLACE SYNONYM Utils FOR &lib..Utils
/
CREATE OR REPLACE SYNONYM log_lines FOR &lib..log_lines
/