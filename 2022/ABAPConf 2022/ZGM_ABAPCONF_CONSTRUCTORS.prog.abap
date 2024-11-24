******************************************************************************************
*  Program ID          : ZGM_ABAPCONF_CONSTRUCTORS                                       *
*  Version SAP         : S4CORE 104-06                                                   *
*  SAP Program Version : 1.0                                                             *
*  Program Name        : ZGM_ABAPCONF_CONSTRUCTORS                                       *
*  Author              : G.Manousaridis                                                  *
*  Created on          : 12/2022                                                         *
*  Description         : ABAP Conf 2022 Constructor Examples                             *
******************************************************************************************
REPORT zgm_abapconf_constructors.

TYPES: p_13_2 TYPE p LENGTH 13 DECIMALS 2.

TYPES: BEGIN OF ts_order,
         ord_num    TYPE n LENGTH 6,
         client_id  TYPE n LENGTH 4,
         name       TYPE c LENGTH 30,
         quantity   TYPE i,
         price      TYPE p_13_2,
         due        TYPE dats,
         company    TYPE bukrs,
         new_client TYPE abap_bool,
       END OF ts_order,

       BEGIN OF ts_timeframe,
         month TYPE n LENGTH 2,
         year  TYPE n LENGTH 4,
       END OF ts_timeframe,

       BEGIN OF ts_exclude,
         field TYPE string,
         value TYPE string,
       END OF ts_exclude.


TYPES: tt_orders    TYPE STANDARD TABLE OF ts_order WITH NON-UNIQUE KEY ord_num name,
       tt_exclude   TYPE STANDARD TABLE OF ts_exclude WITH NON-UNIQUE KEY field value,
       tt_timeframe TYPE STANDARD TABLE OF ts_timeframe WITH NON-UNIQUE KEY month year.

*******************************************************************************************************************************************
* UTILITIES
*******************************************************************************************************************************************
CLASS lcl_util DEFINITION FINAL.

  PUBLIC SECTION.

    TYPES:
      tr_string TYPE RANGE OF string .

    TYPES:
      BEGIN OF ts_stot,
        name  TYPE string,
        value TYPE string,
      END OF ts_stot .
    TYPES:
      tt_stot TYPE STANDARD TABLE OF ts_stot WITH NON-UNIQUE KEY name .

    METHODS:
      structure_to_table
        IMPORTING !structure   TYPE any
                  !is_deep     TYPE abap_bool DEFAULT abap_false
        RETURNING VALUE(table) TYPE tt_stot,

      condense
        IMPORTING !iv_string       TYPE string
                  !ib_gaps         TYPE abap_bool DEFAULT abap_false
        RETURNING VALUE(rv_string) TYPE string.


ENDCLASS.

CLASS lcl_util IMPLEMENTATION.

  METHOD structure_to_table.

    DATA(lr_structure) = cl_abap_datadescr=>describe_by_data( structure ).

    CHECK lr_structure->type_kind = cl_abap_datadescr=>typekind_struct1 OR is_deep = abap_true.

    LOOP AT CAST cl_abap_structdescr( lr_structure )->components ASSIGNING FIELD-SYMBOL(<ls_component>).
      ASSIGN COMPONENT <ls_component>-name OF STRUCTURE structure TO FIELD-SYMBOL(<lv_component_value>).
      table = VALUE #( BASE table ( name = <ls_component>-name value = CONV string( <lv_component_value> ) ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD condense.

    rv_string = iv_string.

    IF ib_gaps = abap_false.
      CONDENSE rv_string NO-GAPS.
    ELSE.
      CONDENSE rv_string.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA(lt_orders) = VALUE tt_orders(
    ( ord_num = 564897 client_id = 0010 name = 'Bob Sanders'         quantity = 2   price = '394.88'  due = '20220923' company = '3900' new_client = abap_false )
    ( ord_num = 564898 client_id = 0011 name = 'Antoine Boucher'     quantity = 12  price = '2961.13' due = '20230315' company = '3900' new_client = abap_false )
    ( ord_num = 564900 client_id = 0015 name = 'Earl Johnson'        quantity = 16  price = '1299.59' due = '20220112' company = '3900' new_client = abap_false )
    ( ord_num = 564901 client_id = 0013 name = 'Alex Athanasopoulos' quantity = 1   price = '161.70'  due = '20220508' company = '3900' new_client = abap_true  )
    ( ord_num = 564902 client_id = 0014 name = 'Krishna Reddy'       quantity = 3   price = '835.24'  due = '20220203' company = '3900' new_client = abap_true  )
    ( ord_num = 564903 client_id = 0015 name = 'Earl Johnson'        quantity = 10  price = '1320.00' due = '20220510' company = '3900' new_client = abap_false )
    ( ord_num = 564904 client_id = 0016 name = 'Bob Jones'           quantity = 6   price = '924.12'  due = '20230112' company = '3900' new_client = abap_false )
    ( ord_num = 564905 client_id = 0017 name = 'Hai Chun Zhao'       quantity = 5   price = '2829.55' due = '20230119' company = '3900' new_client = abap_false )
    ( ord_num = 564906 client_id = 0011 name = 'Antoine Boucher'     quantity = 3   price = '1340.92' due = '20230605' company = '3900' new_client = abap_false )
  ).

  DATA(lo_util) = NEW lcl_util( ).

*******************************************************************************************************************************************
*
* REDUCE
*
*******************************************************************************************************************************************

** MAX VALUES *****************************************************************************************************************************
  "Max Integer
  DATA(lv_max_quantity) = REDUCE i( INIT max_quant TYPE i
                                    FOR ls_order IN lt_orders
                                    NEXT max_quant = COND #( WHEN max_quant > ls_order-quantity THEN max_quant ELSE ls_order-quantity ) ).

  "Max Packed Number (identical with integer - only difference is predefined type)
  DATA(lv_max_price) = REDUCE p_13_2( INIT max_price TYPE p_13_2
                                      FOR ls_order IN lt_orders
                                      NEXT max_price = COND #( WHEN max_price > ls_order-price THEN max_price ELSE ls_order-price ) ).

  "Latest date
  DATA(lv_latest_date) = REDUCE dats( INIT latest TYPE dats
                                      FOR ls_order IN lt_orders
                                      NEXT latest = COND #( WHEN latest > ls_order-due THEN latest ELSE ls_order-due ) ).

** MIN VALUES *****************************************************************************************************************************
  "Min Integer
  DATA(lv_min_quantity) = REDUCE i( INIT min_quant = 99999
                                    FOR ls_order IN lt_orders
                                    NEXT min_quant = COND #( WHEN min_quant < ls_order-quantity THEN min_quant ELSE ls_order-quantity ) ).

  "Min Packed Number (Here the init price has to be set to the max possible defined by the type)
  DATA(lv_min_price) = REDUCE p_13_2( INIT min_price = '999999999.99'
                                      FOR ls_order IN lt_orders
                                      NEXT min_price = COND #( WHEN min_price < ls_order-price THEN min_price ELSE ls_order-price ) ).

  "Earliest date (Date must be set to the maximum possible for comparison)
  DATA(lv_earliest_date) = REDUCE dats( INIT earliest = '99991231'
                                        FOR ls_order IN lt_orders
                                        NEXT earliest = COND #( WHEN earliest < ls_order-due THEN earliest ELSE ls_order-due ) ).

** BOOLEAN IDENTIFIERS ********************************************************************************************************************
  "Column value is same for all lines
  DATA(lb_is_company_3900) = REDUCE abap_bool( INIT is_3900 = abap_true
                                               FOR ls_order IN lt_orders
                                               NEXT is_3900 = xsdbool( is_3900 = abap_true AND ls_order-company = '3900' ) ).

** CALCULATIONS ***************************************************************************************************************************

  "Count lines
  DATA(lv_total_orders) = REDUCE i( INIT n TYPE i
                                    FOR ls_order IN lt_orders WHERE ( name = 'Earl Johnson' )
                                    NEXT n = n + 1 ).

  "Sum Integer
  DATA(lv_total_items) = REDUCE i( INIT i TYPE i
                                   FOR ls_order IN lt_orders WHERE ( name = 'Earl Johnson' )
                                   NEXT i = i + ls_order-quantity ).

  "Sum Packed Number
  DATA(lv_total_sales) = REDUCE p_13_2( INIT p TYPE p_13_2
                                        FOR ls_order IN lt_orders WHERE ( name = 'Earl Johnson' )
                                        NEXT p = p + ls_order-price ).

** STRING MANIPULATIONS *******************************************************************************************************************

  "Construct txt (e.g. for dynamic where conditions)
  DATA(lv_overdue_names) = REDUCE string( INIT s TYPE string
                                          FOR ls_order IN lt_orders WHERE ( due < sy-datum )
                                          NEXT s = |{ COND #( WHEN s IS NOT INITIAL THEN |{ s }, | ) }{ ls_order-name }| ).


** COMBINATIONS OF REDUCE USAGES **********************************************************************************************************

  "String + Calculation
  DATA(lv_sales_per_customer) = REDUCE string(
    INIT s TYPE string
    FOR GROUPS lg_order1
    OF ls_order IN lt_orders
    GROUP BY ( client_id = ls_order-client_id
               name      = ls_order-name )
    LET total_sales = REDUCE p_13_2( INIT p TYPE p_13_2
                                     FOR <ls_order>
                                     IN GROUP lg_order1
                                     NEXT p = p + <ls_order>-price )
    IN
    NEXT s = |{ COND #( WHEN s IS NOT INITIAL THEN |{ s }, | ) }{ lg_order1-name }: { total_sales } €|
  ).

  "Boolean + Calculation
  DATA(lv_client_milestone) = CONV p_13_2( 2500 ).
  DATA(lb_client_reached_milestone) = REDUCE abap_bool(
    INIT client_reached_milestone TYPE abap_bool
    FOR GROUPS lg_order2
    OF ls_order
    IN lt_orders
    GROUP BY ( client_id = ls_order-client_id )
    LET total_sales = REDUCE p_13_2( INIT p TYPE p_13_2
                                     FOR <ls_order>
                                     IN GROUP lg_order2
                                     NEXT p = p + <ls_order>-price )
    IN
    NEXT client_reached_milestone = xsdbool( client_reached_milestone = abap_true OR total_sales >= lv_client_milestone )
  ).

  BREAK-POINT.

*******************************************************************************************************************************************
*
* VALUE
*
*******************************************************************************************************************************************

** VALUE COMBINED WITH REDUCE IN ORDER TO MERGE TABLE LINES *******************************************************************************

  DATA(lt_total_orders_per_client) = VALUE tt_orders(
    FOR GROUPS lg_client
    OF <ls_client>
    IN lt_orders
    GROUP BY ( client_id = <ls_client>-client_id )
    LET price_total = REDUCE p_13_2( INIT p TYPE p_13_2
                                     FOR <ls_order> IN GROUP lg_client
                                     NEXT p = p + <ls_order>-price )
        quantity_total = REDUCE i( INIT i TYPE i
                                   FOR <ls_order> IN GROUP lg_client
                                   NEXT i = i + <ls_order>-quantity )
        ls_client = lt_orders[ client_id = lg_client-client_id ] "No need to check for non existend line
    IN
    ( VALUE #( BASE ls_client
                    price    = price_total
                    quantity = quantity_total ) )
  ).

** AVOID LINE NOT FOUND EXCEPTION *********************************************************************************************************

  DATA(lv_order_price) = VALUE p_13_2( lt_orders[ ord_num = 898211 ]-price OPTIONAL ).

** VALUE FOR ITTERATING DATES *************************************************************************************************************
  "Gather Month/Year pairs between dates
  TRY .

      DATA(lv_last_day_latest_date) = cl_epmh_dgut_date_calc=>add_days( iv_no_of_days = -1
                                                                        iv_date       = cl_epmh_dgut_date_calc=>add_months( iv_date         = lv_latest_date
                                                                                                                            iv_no_of_months = 1 ) ).

      DATA(lt_timeframe) = VALUE tt_timeframe( FOR date = lv_earliest_date
                                               THEN cl_epmh_dgut_date_calc=>add_months( iv_date = date iv_no_of_months = 1 )
                                               UNTIL date > lv_last_day_latest_date
                                               ( month = date+4(2) year = date+0(4) ) ).
    CATCH cx_epmh_dg_exception.
  ENDTRY.

  "Gather Single dates from Select Options
  TRY.
      DATA(lt_workdates) = VALUE sztg_datst(
        BASE VALUE #( FOR ls_workdate IN lr_workdate WHERE ( option = 'EQ' ) ( CONV dats( ls_workdate-low ) ) )
        FOR ls_workdate IN lr_workdate WHERE ( option = 'BT' )
        FOR date = ls_workdate-low
        THEN cl_epmh_dgut_date_calc=>add_days( iv_date = date iv_no_of_days = 1 )
        UNTIL date > ls_workdate-high
        ( CONV dats( date ) )
      ).
    CATCH cx_epmh_dg_exception.
  ENDTRY.

** FUNCTIONAL METHODS IN CONSTRUCTORS ******************************************************************************************************
  "Use of ABAP commands & Features within Constructor with the help of functional methods

  "ABAP Commands e.g. SPLIT, CONDENSE, etc.
  DATA(lt_condensed_client_names) = VALUE tt_orders( FOR ls_order IN lt_orders ( VALUE #( BASE ls_order name = lo_util->condense( CONV #( ls_order-name ) ) ) ) ).

  "Iterate on structure - Normally with the help of CL_ABAP_STRUCTDESCR --> GET_COMPONENTS within a loop

  "e.g. we have the following (dynamic) input from the user with pairs of fields-values to nullify the price as gift to the client

  DATA(lt_gifts) = VALUE tt_exclude(
    ( field = 'NAME'       value = 'Bob Sanders' )
    ( field = 'ORD_NUM'    value = '564906' )
    ( field = 'NAME'       value = 'Hai Chun Zhao' )
    ( field = 'NEW_CLIENT' value = 'X' )
  ).

  DATA(lt_apply_gifts) = VALUE tt_orders(
    FOR ls_order IN lt_orders
    LET lt_gift_client = VALUE tt_exclude( FOR ls_field IN lo_util->structure_to_table( ls_order )
                                           FOR ls_gift IN lt_gifts WHERE ( field = ls_field-name AND value = ls_field-value )
                                           ( ls_gift ) )
    IN
    ( VALUE #( BASE ls_order price = COND #( WHEN lt_gift_client IS INITIAL THEN ls_order-price ELSE 0 ) ) )
  ).
