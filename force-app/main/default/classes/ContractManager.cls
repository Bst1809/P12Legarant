@RestResource(urlMapping='/Contracts/*')
global with sharing class ContractManager {
    @HttpPost
    global static Id createContract(Id accountId, String status, Date startDate, Integer contractTerm) {
        try {
            Contract thisContract = New Contract (
            AccountId=accountId,
            Status=status,
            StartDate=startDate,
            ContractTerm=contractTerm);

            insert thisContract;
            return thisContract.id;
        } catch (DmlException e) {
            System.debug('Error creating contract: ' + e.getMessage());
            return null;
        }
    }

    @HttpPatch
    global static ID updateContractFields() {
        try {
            RestRequest request = RestContext.request;
            // Grab the Id from the end of the URL
            String contractId = request.requestURI.substring(
                request.requestURI.lastIndexOf('/')+1);
            // Query the contact that matches
            Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
            // Deserialize the JSON string into name-value pairs
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            // Iterate through each parameter field and value
            for(String fieldName : params.keySet()) {
                // Set the field and value on the Contact sObject
                thisContract.put(fieldName, params.get(fieldName));
            }
            update thisContract;
            return thisContract.Id;
        } catch (DmlException e) {
            System.debug('Error updating contract fields: ' + e.getMessage());
            return null;
        }
    }
}