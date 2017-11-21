global without sharing class ProductPickerController {
    @AuraEnabled
    public static ProductPickerResponseModel serverInit(Id opportunityId) {
        Opportunity thisOpp = [
            SELECT
                Id, Pricebook2Id
            FROM
                Opportunity
            WHERE
                Id = :opportunityId
        ];

        List<OpportunityLineItemWrapper> olis = new List<OpportunityLineItemWrapper>();
        for (OpportunityLineItem anOli : [
                                            SELECT
                                                Id, Product2Id, Quantity, UnitPrice
                                            FROM
                                                OpportunityLineItem
                                            WHERE
                                                OpportunityId = :opportunityId
        ]) {
            olis.add(new OpportunityLineItemWrapper(anOli));
        }

        List<PricebookEntry> pbes = [
            SELECT
                Id, Product2.Name, UnitPrice
            FROM
                PricebookEntry
            WHERE
                Pricebook2Id = :thisOpp.Pricebook2Id AND
                IsActive = true
        ];

        ProductPickerResponseModel responseModel = new ProductPickerResponseModel();
        responseModel.olis = olis;
        responseModel.pbes = pbes;
        
        return responseModel;
    }

    public class ProductPickerResponseModel {
        @AuraEnabled public List<OpportunityLineItemWrapper> olis;
        @AuraEnabled public List<PricebookEntry> pbes;
    }

    public class OpportunityLineItemWrapper {
        @AuraEnabled public OpportunityLineItem oli;
        @AuraEnabled public Boolean deleteFlag;

        public OpportunityLineItemWrapper(OpportunityLineItem oli) {
            this.oli = oli;
            this.deleteFlag = false;
        }
    }
}