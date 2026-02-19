CLASS lhc_items DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS rechange_total FOR MODIFY
      IMPORTING keys FOR ACTION Items~rechange_total.

    METHODS change_total FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Items~change_total.

ENDCLASS.

CLASS lhc_items IMPLEMENTATION.

  METHOD rechange_total.

    DATA: lv_total TYPE zde_lfimg,
          lv_unit  TYPE vrkme.

    "...Read entities Header
    READ ENTITIES OF zrap_c_delivery_h IN LOCAL MODE
    ENTITY Header
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result_header).

    "...Read entities Items
    READ ENTITIES OF zrap_c_delivery_h IN LOCAL MODE
    ENTITY header BY \_items
    FIELDS ( lfimg )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result_items).

    LOOP AT lt_result_items ASSIGNING FIELD-SYMBOL(<lfs_items>).
      lv_total = lv_total + <lfs_items>-Lfimg.
      lv_unit  =  <lfs_items>-Vrkme.
    ENDLOOP.

    "...Update status in header
    MODIFY ENTITIES OF zrap_c_delivery_h IN LOCAL MODE
    ENTITY header
    UPDATE FIELDS ( total Vrkme )
    WITH VALUE #( FOR ls_header IN lt_result_header
                    ( %tky  = ls_header-%tky
                      total = lv_total
                      vrkme = lv_unit
                      %control-total = if_abap_behv=>mk-on
                      %control-vrkme = if_abap_behv=>mk-on ) ) .


  ENDMETHOD.

  METHOD change_total.

    MODIFY ENTITIES OF zrap_c_delivery_h IN LOCAL MODE
    ENTITY items
    EXECUTE rechange_total
    FROM CORRESPONDING #( keys ).

  ENDMETHOD.

ENDCLASS.



CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.
    METHODS change_status FOR DETERMINE ON MODIFY
      IMPORTING keys FOR header~change_status.

    METHODS earlynumbering_cba_items FOR NUMBERING
      IMPORTING entities FOR CREATE header\_items.



    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE header.


    METHODS get_latest_vbeln
      RETURNING VALUE(rv_vbeln) TYPE zde_vbeln.

    METHODS get_latest_vbeln_draft
      RETURNING VALUE(rv_vbeln) TYPE zde_vbeln.

    METHODS get_latest_pos_by_vbeln
      IMPORTING iv_vbeln        TYPE zde_vbeln
      RETURNING
                VALUE(rv_posnr) TYPE posnr.

    METHODS get_latest_posnr_draft
      IMPORTING iv_vbeln        TYPE zde_vbeln
      RETURNING VALUE(rv_posnr) TYPE posnr.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD get_latest_vbeln.

    SELECT SINGLE MAX( vbeln )
     FROM ztrap_delivery_h
     INTO @rv_vbeln.

  ENDMETHOD.

  METHOD earlynumbering_create.


    DATA(lv_vbeln) = me->get_latest_vbeln( ).
    lv_vbeln = COND #( WHEN lv_vbeln IS INITIAL THEN '1000000000'
                                      ELSE lv_vbeln ).

    DATA(lv_vbeln_draft) = me->get_latest_vbeln_draft(  ).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<e>).

      INSERT VALUE #( %cid      = <e>-%cid
                      %is_draft = <e>-%is_draft
                      Vbeln     = COND #( WHEN <e>-%is_draft = if_abap_behv=>mk-off THEN <e>-Vbeln
                                          ELSE COND #( WHEN lv_vbeln_draft IS INITIAL THEN lv_vbeln + sy-tabix
                                                       ELSE lv_vbeln_draft + sy-tabix  ) )   )
        INTO TABLE mapped-header.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_latest_vbeln_draft.

    SELECT SINGLE MAX( vbeln )
         FROM ztrapdelivery_hd
         INTO @rv_vbeln.

  ENDMETHOD.

  METHOD earlynumbering_cba_Items.

    DATA(lv_posnr) =  me->get_latest_pos_by_vbeln( entities[ 1 ]-Vbeln  ).

    lv_posnr = COND #( WHEN lv_posnr IS INITIAL THEN '000000'
                                     ELSE lv_posnr ).

    DATA(lv_posnr_draft) = me->get_latest_posnr_draft( entities[ 1 ]-Vbeln  ) .

    LOOP AT entities[ 1 ]-%target ASSIGNING FIELD-SYMBOL(<e>).


      "...Items
      INSERT VALUE #( %cid      = <e>-%cid
                      %is_draft = <e>-%is_draft
                      Vbeln     = <e>-Vbeln
                      Posnr     = COND #( WHEN <e>-%is_draft = if_abap_behv=>mk-off THEN <e>-posnr
                                          ELSE COND #( WHEN lv_posnr_draft IS INITIAL THEN lv_posnr + sy-tabix * 10
                                                       ELSE lv_posnr_draft + sy-tabix * 10  ) )  )
        INTO TABLE mapped-items.

    ENDLOOP.

    "...NOTE: No modify mapped-header because generate dump,
    "         this is calculated in method earlynumbering_create

  ENDMETHOD.

  METHOD get_latest_pos_by_vbeln.

    SELECT SINGLE MAX( posnr )
      FROM ztrap_delivery_i
      WHERE vbeln = @iv_vbeln
      INTO @rv_posnr.


  ENDMETHOD.

  METHOD get_latest_posnr_draft.

    SELECT SINGLE MAX( posnr )
       FROM ztrapdelivery_id
       WHERE vbeln = @iv_vbeln
       INTO @rv_posnr.

  ENDMETHOD.

  METHOD change_status.

    DATA: lt_header TYPE TABLE FOR UPDATE zrap_c_delivery_h.

    "....Read entities header
    READ ENTITIES OF zrap_c_delivery_h IN LOCAL MODE
    ENTITY header
    FIELDS ( Ernam )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      <lfs_result>-Pgi = COND #( WHEN <lfs_result>-Ernam = 'SSINGH' THEN 'C' ELSE 'A' ).
    ENDLOOP.

    lt_header = CORRESPONDING #( lt_result ).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<lfs_header>).
      <lfs_header>-%control-Pgi = if_abap_behv=>mk-on.
    ENDLOOP.

    "...Modify Status
    MODIFY ENTITIES OF zrap_c_delivery_h IN LOCAL MODE
    ENTITY header
    UPDATE FIELDS ( Pgi )
    WITH lt_header.

  ENDMETHOD.

ENDCLASS.
