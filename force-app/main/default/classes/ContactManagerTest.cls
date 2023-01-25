@isTest
private class ContactManagerTest {
    // Helper method
    static Contact createTestRecord() {
        // Create test record
        Contact TestCon= new Contact(
        LastName='WasHereBefore',
        FirstName='Contact',
        Email='test@email.com');
        insert TestCon;
        return TestCon;
    }        
    @isTest static void testCreateContactWithoutEmailInDB(){
        // Call the method to test
        ID thisContactId = ContactManager.createContactWithEmail('Contact', 'WasJustCreated', 'new@email.com');
        // Verify results
        System.assert(thisContactId != null);
        Contact thisContact = [SELECT Id, Email FROM Contact WHERE Id=:thisContactId LIMIT 1];
        System.assert(thisContact != null);
        System.assertEquals(thisContact.Email, 'new@email.com');
    }
    
    @isTest static void testCreateContactWithEmailInDB(){
        // Create contact with the same email as the http request
        Contact existingContact = createTestRecord();
        // Call the method to test
        ID thisContactId = ContactManager.createContactWithEmail('Test', 'Contact', 'test@email.com');
        // Verify results
        System.assert(thisContactId != null);
        List <Contact> thisContact = [SELECT Id, Email, LastName FROM Contact WHERE Email= 'test@email.com'];
        System.debug(thisContact);
        System.assert(thisContact != null);
        System.assertEquals(1, thisContact.size());
    }
    
    @isTest static void testUpdateContactFields() {
        Contact contactTest = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://bastcompany-dev-ed.develop.lightning.force.com/services/apexrest/Contacts/'+ contactTest.id;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"Email": "newemailupdated@gmail.com"}');
        RestContext.request = request;
        // Update Email of existing record to "newemailupdated@gmail.com"
        ID thisContactId = ContactManager.updateContactFields();
        // Verify record was updated
        System.assert(thisContactId != null);
        Contact thisContact = [SELECT Id,Email FROM Contact WHERE Id=:thisContactId];
        System.assert(thisContact != null);
        System.assertEquals(thisContact.Email, 'newemailupdated@gmail.com');
    }
    
	@isTest static void testDeleteContact() {
        Contact contactTest = createTestRecord();
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://bastcompany-dev-ed.develop.lightning.force.com/services/apexrest/Contacts/'+ contactTest.id;
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        // Call the method to test
        ContactManager.deleteContact();
        // Verify record is updated
        Contact thisContact = [SELECT Id,Active__c FROM Contact WHERE Id=:contactTest.id];
        System.assert(thisContact != null);
        System.assertEquals(thisContact.Active__c, False);
    }
           
}