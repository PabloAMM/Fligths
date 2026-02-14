@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Delivery Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZRAP_C_DELIVERY_H
  as select from ztrap_delivery_h
  composition [0..*] of ZRAP_C_DELIVERY_I as _items
{
  key vbeln              as Vbeln,
      ernam              as Ernam,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      total              as Total,
      vrkme              as Vrkme,
      pgi                as Pgi,
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
      _items // Make association public
}
