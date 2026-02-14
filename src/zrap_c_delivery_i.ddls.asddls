@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZRAP_C_DELIVERY_I
  as select from ztrap_delivery_i
  association to parent ZRAP_C_DELIVERY_H as _header on $projection.Vbeln = _header.Vbeln
{
  key vbeln              as Vbeln,
  key posnr              as Posnr,
      @Semantics.quantity.unitOfMeasure : 'vrkme'
      lfimg              as Lfimg,
      vrkme              as Vrkme,
      matnr              as Matnr,
      @Semantics.user.createdBy: true
      createdby          as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat          as Createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby      as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      as Lastchangedat,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as Locallastchangedat,
      _header // Make association public
}
