@IsTest
private class ContractManagerTest {
    
    // Helper methods
    static Account createTestAccount() {
        Account accTest = new Account(
        Name='TestAccount');
        insert accTest;
        return accTest;
    }
    
    static Contract createTestContract() {
        Account accTest = createTestAccount();
        Contract contractTest = new Contract(
        AccountId=accTest.id,
        Status='Draft',
        StartDate=system.today(),
        ContractTerm=12);
        insert contractTest;
        return contractTest;
    }
    
    // Test Methods
    @isTest static void testCreateContract(){
        // Create Account first
        Account accTest = createTestAccount();
        // Call the method to test
        ID thisContractId = ContractManager.createContract(accTest.id, 'Draft', system.today(), 12);
        // Verify results
        System.assert(thisContractId != null);
        Contract thisContract = [SELECT Id, AccountId FROM Contract WHERE Id=:thisContractId LIMIT 1];
        System.assert(thisContract != null);
        System.assertEquals(thisContract.AccountId, accTest.id);
    }
    
	@isTest static void testUpdateContractFields() {
        Contract contractTest = createTestContract();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://bastcompany-dev-ed.develop.lightning.force.com/services/apexrest/Contracts/'+ contractTest.id;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"ContractTerm": 24}');
        RestContext.request = request;
        // Update Contract Term of existing record to 24 months instead of 12
        ID thisContractId = ContractManager.updateContractFields();
        // Verify record was updated
        System.assert(thisContractId != null);
        Contract thisContract = [SELECT Id, ContractTerm FROM Contract WHERE Id=:thisContractId];
        System.assert(thisContract != null);
        System.assertEquals(thisContract.ContractTerm, 24);
    }
}