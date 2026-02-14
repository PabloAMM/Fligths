CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.



    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE header.


    METHODS get_latest_vbeln
      RETURNING VALUE(rv_vbeln) TYPE zde_vbeln.
    METHODS get_latest_vbeln_draft
      RETURNING VALUE(rv_vbeln) TYPE zde_vbeln.

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

ENDCLASS.
