@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactManager {
    // Create a contact if email does not exist in SF, otherwise, return SF ID
    @HttpPost
    global static Id createContactWithEmail(String lastName, String firstName, String contactEmail) {
        try {
        // Query the contact that matches the email
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Email =:ContactEmail LIMIT 1];
        if (!contactList.isEmpty()){
            Contact thisContact = contactList[0];
            return thisContact.Id;
        	}else{
                Contact thisContact = new Contact (
                    LastName=lastName,
                    FirstName=firstName,
                    Email=contactEmail);
                insert thisContact;
                return thisContact.Id;
        	}
     	} catch(Exception e) {
            // Log the exception
            System.debug('Error creating contact: ' + e.getMessage());
            return null;
        }
    }   
    // Update a contact
    @HttpPatch
    global static ID updateContactFields() {
        try {
            RestRequest request = RestContext.request;
            // Grab the Id from the end of the URL
            String contactId = request.requestURI.substring(
                request.requestURI.lastIndexOf('/')+1);
            // Query the contact that matches
            Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
            // Deserialize the JSON string into name-value pairs
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            // Iterate through each parameter field and value
            for(String fieldName : params.keySet()) {
                // Set the field and value on the Contact sObject
                thisContact.put(fieldName, params.get(fieldName));
            }
        update thisContact;
        return thisContact.Id;
     } catch(Exception e) {
            // Log the exception
            System.debug('Error updating contact: ' + e.getMessage());
            return null;
        }
    } 
    
    // Delete contact : Active__c field switches to false
    @HttpDelete
    global static void deleteContact(){
        try {
            RestRequest request = RestContext.request;
            // Grab the Id from the end of the URL
            String contactId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
            // Query the contact that matches
            Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
            // Change Active__c to false
            thisContact.Active__c = false;
            update thisContact;
        } catch(Exception e) {
            // Log the exception
            System.debug('Error deleting contact: ' + e.getMessage());
        }
    }
}