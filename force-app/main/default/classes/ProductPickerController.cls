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

    @AuraEnabled
    public static List<OpportunityLineItemWrapper> serverSaveOlis(String allOlisJSON) {
        System.debug('allOlisJSON: ' + allOlisJSON);
        List<OpportunityLineItemWrapper> allOlis = (List<OpportunityLineItemWrapper>) JSON.deserialize(allOlisJSON, List<OpportunityLineItemWrapper>.class);
        List<OpportunityLineItem> olisToUpsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> olisToDelete = new List<OpportunityLineItem>();
        for (OpportunityLineItemWrapper aWrapper : allOlis) {
            System.debug('a wrapper: ' + aWrapper);
            if (aWrapper.deleteFlag && String.isNotBlank(aWrapper.oli.Id)) {
                olisToDelete.add(aWrapper.oli);
            }
            else if (!aWrapper.deleteFlag) {
                olisToUpsert.add(aWrapper.oli);
            }
        }
        Savepoint sp = Database.setSavepoint();
        if (!olisToDelete.isEmpty()) {
            try {
                delete olisToDelete;
            }
            catch (DMLException e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        if (!olisToUpsert.isEmpty()) {
            try {
                upsert olisToUpsert;
            }
            catch (DMLException e) {
                Database.rollback(sp);
                throw new AuraHandledException(e.getMessage());
            }
        }
        List<OpportunityLineItemWrapper> olisToReturn = new List<OpportunityLineItemWrapper>();
        for (OpportunityLineItem anOli : olisToUpsert) {
            olisToReturn.add(new OpportunityLineItemWrapper(anOli));
        }
        
        return olisToReturn;
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