@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Delivery Items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_RAP_C_DELIVERY_I
  as projection on ZRAP_C_DELIVERY_I
{
  key Vbeln,
  key Posnr,
      @Semantics.quantity.unitOfMeasure : 'vrkme'
      Lfimg,
      Vrkme,
      Matnr,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      Locallastchangedat,
      /* Associations */
      _header : redirected to parent ZC_RAP_C_DELIVERY_H
}
