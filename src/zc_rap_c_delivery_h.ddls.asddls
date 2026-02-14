@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Delivery Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['Vbeln']
define root view entity ZC_RAP_C_DELIVERY_H
//  provider contract transactional_query
  as projection on ZRAP_C_DELIVERY_H
{
  key Vbeln,
      Ernam,
      @Semantics.quantity.unitOfMeasure: 'vrkme'
      Total,
      Vrkme,
      Pgi,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      Locallastchangedat,
      /* Associations */
      _items : redirected to composition child ZC_RAP_C_DELIVERY_I
}
