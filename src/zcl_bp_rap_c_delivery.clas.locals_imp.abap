

CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

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
    "...      this is calculated in method earlynumbering_create

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

ENDCLASS.
